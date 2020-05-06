require 'concurrent'

require 'net/http'
require 'json'

require_relative 'stackoverflow_question'

API_URL = 'https://api.stackexchange.com'

# Set this flag to avoid threads failing silently.
Thread.abort_on_exception = true


class ParallelQuery
  attr_reader :question_hash, :errors

  # Create a new parallel query object. This object queries stackoverflow in parallel and passes the results to a
  # callback function.
  # @param [Integer]  max_question_pages The maximum number of pages that are queried for a keyword
  # @param [Integer]  question_batch_size The maximum number of questions for which all the answers are queried at once
  # @param [Integer]  num_threads The number of threads that should be used in a threadpool
  def initialize(max_question_pages = 10, question_batch_size = 15, num_threads = 20)
    @pool = Concurrent::FixedThreadPool.new(num_threads)
    @max_question_pages = max_question_pages
    @question_batch_size = question_batch_size

    @question_hash = Concurrent::Hash.new

    @errors = Concurrent::Array.new
  end

  # Check if the thread pool as any open tasks or if every scheduled task has been finished.
  # @return [Boolean] true if every task has finished, false if there are open tasks remaining
  def finished?
    @pool.scheduled_task_count > 0 && @pool.scheduled_task_count == @pool.completed_task_count
  end

  # Query Stackoverflow with a keyword and a number of language tags. The callback has to handle the answer Hashes
  # returned by the Stackoverflow API.
  # @param [String]  keyword the keyword that is queried
  # @param [Array]  language_tags array of languages for which results are queried
  # @param [Object]  answer_callback function that will be called with a Hash containing multiple answers
  def query(keyword, language_tags, &answer_callback)
    question_callback = Proc.new {|questions|
      questions = questions.map {|post| StackoverflowQuestion.new(post)}
      questions.each do |question|
        @question_hash[question.question_id] = question
      end
      query_answers(questions.map(&:question_id), &answer_callback)
    }
    query_questions(keyword, language_tags, &question_callback)
  end

  # Query Stackoverflow for the questions to a keyword. The questions are filtered by the tags passed to this method.
  # The callback function is called with a list of questions as parameter.
  # For the API usage refer to https://api.stackexchange.com/docs/search.
  # @param [Object]  keyword the keyword that is queried
  # @param [Object]  language_tags array of languages for which results are queried
  # @param [Object]  callback function that will be called with a Hash containing multiple questions
  def query_questions(keyword, language_tags, &callback)
    query_uri = URI(API_URL + '/search')
    query_params = {
        :order => 'desc',
        :sort => 'votes',
        :tagged => language_tags.join(';'),
        :site => 'stackoverflow',
        :intitle => keyword,
        :answers => 'true'
    }
    query_pages_parallel(query_uri, query_params, batch_size = @max_question_pages, &callback)
  end

  # Retrieve the answers for the passed questions. If the passed array is empty, nothing is queried.
  # @question_batch_size questions are queried at once (which can be 100 at most).
  # The callback has to handle the answer Hashes returned by the Stackoverflow API.
  # @param [Object]  question_ids an array of question ids
  # @param [Object]  callback function that will be called with a Hash containing multiple answers
  def query_answers(question_ids, &callback)
    if question_ids.empty?
      return
    end
    question_ids = question_ids.map {|id| String(id)}
    batches = question_ids.each_slice(@question_batch_size).to_a
    batches.each do |batch|
      @pool.post do
        query_uri = URI("#{API_URL}/questions/#{batch.join(';')}/answers")
        query_params = {
            :site => 'stackoverflow',
            :sort => 'votes',
            :order => 'desc',
            :filter => 'withbody',
        }
        query_pages_parallel(query_uri, query_params, max_pages = 5, &callback)
      end
    end
  end

  # Query multiple pages of a single query in parallel. At most the first max_pages are queried. The response of each
  # query is passed to the callback as parameter.
  # @param [Object]  query_uri the URI that is queried
  # @param [Object]  query_params the GET parameters of the query that are used
  # @param [Object]  max_pages the maximum number of pages that will be queried
  # @param [Object]  callback function that will be called with the results of each API query as parameter
  def query_pages_parallel(query_uri, query_params, max_pages = 5, &callback)
    # Query the current batch and store the results with the page number.
    (1..max_pages).each do |page|
      @pool.post do
        begin
          local_uri = query_uri.clone
          local_params = query_params.clone
          local_params[:page] = page
          response_body = query_endpoint(local_uri, local_params)
          callback.call(response_body.fetch('items', Array.new))
        rescue ArgumentError => e
          @errors << e
        end
      end
    end
    nil
  end

  # Query the stackoverflow endpoint. If the HTTP request returns with an error, an ArgumentError is thrown.
  #
  # @param [String] query_uri The uri path of the Stackoverflow API.
  # @param [String] query_params The get parameters that should be sent to the endpoint.
  # @return [Hash] The response body of the HTTP request.
  def query_endpoint(query_uri, query_params)
    query_uri.query = URI.encode_www_form(query_params)
    response = Net::HTTP.get_response(query_uri)
    response_body = JSON.parse(response.body)
    raise ArgumentError, "#{response_body['error_message']} " unless response.is_a?(Net::HTTPSuccess)
    response_body
  end
end
