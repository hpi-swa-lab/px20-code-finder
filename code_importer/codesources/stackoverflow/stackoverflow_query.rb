require 'net/http'
require 'json'

require_relative 'stackoverflow_answer'
require_relative 'stackoverflow_question'
require_relative 'stackoverflow_parallel_query'


class StackoverflowQuery
  attr_reader :code_snippets, :parallel_query, :status

  def initialize(keyword, language_tags)
    @keyword = keyword.downcase
    @keyword.sub!('_', ' ')
    @language_tags = Array(language_tags)
    @code_snippets = Array.new
    @snippet_queue = Queue.new

    @squeak_callback = nil
    @squeak_mutex = Mutex.new

    @tries = 0
    @max_tries = 100
    # Query only the first 10 pages of questions and only the answers for 15 questions at once.
    @parallel_query = ParallelQuery.new(max_question_pages = 10, question_batch_size = 15)

    @status = "Processing query..."
  end

  def initialize_squeak_callback(code_finder)
    @squeak_callback = Proc.new do |query_object|
      code_finder.updateCodeSnippets_(query_object)
    end
  end

  # Select all code snippets that are functions. If the number of arguments are set, then only functions with that many
  # arguments will be returned.
  #
  # @param [Integer] arg_count The number of arguments the functions should have. If unset, any function is selected.
  # @return [Array] An array of code snippets.
  def select_functions(arg_count = nil)
    @code_snippets
        .select {|snippet| snippet.is_valid_code}
        .select {|snippet| snippet.is_function}
        .select {|snippet| arg_count.nil? || (snippet.function_argument_count == arg_count)}
  end

  # Select all code snippets that are valid. Valid means, that they don't contain syntax errors, and that they start
  # with one of the defined starting patterns.
  #
  # @return [Array] An array of code snippets.
  def select_valid_snippets
    @code_snippets
        .select {|snippet| snippet.is_valid_code}
        .select {|snippet| snippet.is_valid_beginning}
  end

  # Select all function code snippets f that fulfill the constraint f(input) == output.
  # @param [String] input The code that returns the input for the functions that will be tested when it is executed.
  # @param [String] output The code that returns the output for the functions that will be tested when it is executed.
  # @return [Array] An array of code snippets.
  def select_method_finder_snippets(language, input, output)
    @code_snippets
        .select {|snippet| snippet.is_valid_code}
        .select {|snippet| snippet.is_function}
        .filter {|snippet| snippet.test_function(language, input, output)}
  end

  def query
    answer_callback = Proc.new do |answers|
      answers = answers.map {|item| StackoverflowAnswer.new(item)}
      answers.each do |answer|
        question = @parallel_query.question_hash[answer.question_id]
        question.add_answer(answer)
        answer.tags = question.tags
        answer.question_score = question.score
      end
      new_snippets = answers.select {|answer| answer.code_blocks.any?}

      if !new_snippets.empty?
        @snippet_queue << new_snippets
      end
    end

    @parallel_query.query(@keyword, @language_tags, &answer_callback)
  end

  # Poll the result queue for new results. This method is called by the squeak UI to check if new results are there.
  # If the queue contains new results, they are processed into python CodeSnippet objects and a callback to squeak,
  # which notifies it of the new results, is called.
  # @return [Boolean] true if more results will be produced, false if the querying is finished and the result queue is
  #                   empty
  def query_step
    begin
      batch = @snippet_queue.pop(true)
      offset = @code_snippets.size
      new_snippets = batch.each_with_index
                         .map { |snippet, index| snippet.code_snippet(index + offset) }
                         .select {|snippet| not snippet.is_invalid_snippet()}
      @code_snippets.push(*new_snippets)
      @squeak_callback.call(self)
    rescue ThreadError
      # Do nothing (no new result in the queue)
    end
    if !@parallel_query.errors.empty?
      @status = "Aborted! Too many requests."
      puts "Querying failed! Received following errors:"
      puts @parallel_query.errors
      return false
    elsif finished
      @status = "Completed query!"
    end
    !finished
  end

  def finished
    @snippet_queue.empty? && @parallel_query.finished?
  end
end
