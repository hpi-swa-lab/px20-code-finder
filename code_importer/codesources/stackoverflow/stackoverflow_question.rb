class StackoverflowQuestion
  attr_reader :answers

  def initialize(metadata)
    @metadata = metadata
    @answers = []
  end

  def tags
    @metadata['tags']
  end

  def url
    @metadata['link']
  end

  def question_id
    @metadata['question_id']
  end

  def score
    @metadata['score']
  end

  def add_answer(answer)
    @answers.push(answer)
  end

end

