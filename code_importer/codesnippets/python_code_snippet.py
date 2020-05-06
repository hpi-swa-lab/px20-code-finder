import json
import re

from .code_snippet import CodeSnippet


class PythonCodeSnippet(CodeSnippet):
    """
    Code snippet for the Python language
    """
    snippet_language = "python"

    def is_function(self):
        return self.code.startswith("def")

    def is_import(self):
        return self.code.startswith("import ") or self.code.startswith("from ")

    def is_class(self):
        return self.code.startswith("class ")

    def _is_code_comment(self, code: str):
        return code.startswith("#") or code.startswith('"""')

    def function_name(self):
        if not self.is_function():
            return None
        function_name_reg = '(?<=def).*(?=\()'
        match = re.search(function_name_reg, self.code)
        if not match:
            return None
        return match.group(0).strip()

    def function_return_statement(self):
        return self.function_name()

    def make_comment(self, line):
        return "# {}".format(line)

    @classmethod
    def compare_objects(cls, object1, object2) -> bool:
        return object1 == object2

    @classmethod
    def _stringify_polyglot_eval(cls, language: str, value: str):
        escaped = json.dumps(value)
        return f'import polyglot\npolyglot.eval(language="{language}", string={escaped})'
