import json
import re
import polyglot

from .code_snippet import CodeSnippet


class RubyCodeSnippet(CodeSnippet):
    """
    Code snippet for the Ruby language
    """
    snippet_language = "ruby"

    def is_function(self):
        return self.code.startswith("def")

    def is_import(self):
        return self.code.startswith("require ") or self.code.startswith("relative_require ")

    def is_class(self):
        return self.code.startswith("class ")

    def _is_code_comment(self, code: str):
        return code.startswith("#")

    def function_name(self):
        if not self.is_function():
            return ''
        function_name_reg = '(?<=def).*(?=\()'
        match = re.search(function_name_reg, self.code)
        if not match:
            return None
        return match.group(0).strip()

    def function_return_statement(self):
        return "method(:{})".format(self.function_name())

    def make_comment(self, line):
        return "# {}".format(line)

    @classmethod
    def compare_objects(cls, object1, object2) -> bool:
        func = polyglot.eval(language=cls.snippet_language, string="lambda {|x, y| x == y}")
        return func(object1, object2)

    @classmethod
    def _stringify_polyglot_eval(cls, language: str, value: str):
        escaped = json.dumps(value)
        return f'Polyglot.eval("{language}", {escaped})'

    def test_function(self, language: str, input_code: str, output_code: str) -> bool:
        from code_importer.utils import eval_limited
        language = str(language)
        input_code = str(input_code)
        output_code = str(output_code)

        # Sandboxing only works for ruby snippets with ruby code at the moment
        if language != self.snippet_language:
            return super().test_function(language, input_code, output_code)

        # Compile input data for testing
        input_data = polyglot.eval(language=language, string=str(input_code))
        # First filter if the number of arguments don't align
        if len(input_data) != self.function_argument_count():
            return False

        eval_string = f"{self.code}\n{self.function_return_statement()}.call(*{input_code}) == {output_code}"
        try:
            return eval_limited(self.snippet_language, eval_string)
        except:
            return False
