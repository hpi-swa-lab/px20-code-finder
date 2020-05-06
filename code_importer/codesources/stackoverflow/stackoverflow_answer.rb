require 'nokogiri'


# Create the path to the "import_snippet.py" file in the same directory. This path is a relative path from the current
# working directory and points to the directory this file is in. The name of the "import_snippet.py" file is then
# appended.
#
# @return [String] Path (relative to the current working directory) to the "import_snippet.py" file.
def import_snippet_path
  file_directory_path = File.dirname(__FILE__)
  file_directory_path + "/import_snippet.py"
end


class StackoverflowAnswer
  attr_reader :code_blocks, :tags
  attr_writer :tags, :question_score

  def initialize(metadata)
    @metadata = metadata
    @code_blocks = Array.new
    @tags = Array.new
    @question_score = nil
    self.extract_code_blocks
  end

  def is_accepted
    @metadata['is_accepted']
  end

  def score
    @metadata['score']
  end

  def author
    @metadata['owner']['link']
  end

  def question_id
    @metadata['question_id']
  end

  def answer_id
    @metadata['answer_id']
  end

  def question_url
    "https://stackoverflow.com/questions/#{self.question_id}"
  end

  def answer_url
    "https://stackoverflow.com/a/#{self.answer_id}"
  end

  def extract_code_blocks
    page = Nokogiri::HTML(@metadata['body'])
    code_blocks = page.search('code').map(&:text)
    return nil if code_blocks.empty?
    @code_blocks = code_blocks.sort_by {|code| -code.length}
  end

  def code_snippet(index)
    snippet_object = Polyglot.eval_file("python", import_snippet_path)
    snippet_object.create(code_blocks.first, tags, author, question_url, answer_url, @question_score, score,
                          is_accepted, index)
  end
end
