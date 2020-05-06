require 'nokogiri'
require 'coderay'

class CodeHighlighter
  def self.is_valid(code)
    raise NotImplementedError, "Abstract method should be implemented by subclasses."
  end

  def self.highlight(code)
    raise NotImplementedError, "Abstract method should be implemented by subclasses."
  end
end

class CodeRayHighlighter < CodeHighlighter
  def self.is_valid(code)
    highlighted_code = highlight(String(code))
    html = Nokogiri::HTML(highlighted_code)
    html.search('error')
    errors = html.css('span.error')
    errors.length == 0
  end

  def self.highlight(code)
    raise NotImplementedError, "Abstract method should be implemented by subclasses."
  end
end

class JavascriptHighlighter < CodeRayHighlighter
  def self.highlight(code)
    CodeRay.scan(code, :javascript).page
  end
end

class PythonHighlighter < CodeRayHighlighter
  def self.highlight(code)
    CodeRay.scan(code, :python).page
  end
end

class RubyHighlighter < CodeRayHighlighter
  def self.highlight(code)
    CodeRay.scan(code, :ruby).page
  end
end

class RHighlighter < CodeHighlighter
  # TODO: add via rouge
  def self.is_valid(code)
    true
  end
end

class SmalltalkHighlighter < CodeHighlighter
  # TODO: add via rouge
  def self.is_valid(code)
    true
  end
end
