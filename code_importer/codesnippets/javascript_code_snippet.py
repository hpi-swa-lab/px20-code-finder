import json
import re
import polyglot

from .code_snippet import CodeSnippet


class JavascriptCodeSnippet(CodeSnippet):
    """
    Code snippet for the JavaScript language
    """
    snippet_language = "js"

    def is_function(self):
        return self.code.startswith("function")

    def is_import(self):
        return self.code.startswith("import ")

    def is_class(self):
        return self.code.startswith("class ")

    def _is_code_comment(self, code: str):
        return code.startswith("//") or code.startswith("/*")

    def function_name(self):
        if not self.is_function():
            return None
        function_name_reg = '(?<=function).*(?=\()'
        match = re.search(function_name_reg, self.code)
        if not match:
            return None
        return match.group(0).strip()

    def function_return_statement(self):
        return self.function_name()

    def make_comment(self, line):
        return "// {}".format(line)

    @classmethod
    def compare_objects(cls, object1, object2) -> bool:
        # Stringify objects so that complex objects like lists can be compared
        func = polyglot.eval(language=cls.snippet_language, string="(x, y) => JSON.stringify(x) === JSON.stringify(y)")
        return func(object1, object2)

    @classmethod
    def _stringify_polyglot_eval(cls, language: str, value: str):
        escaped = json.dumps(value)
        return f'Polyglot.eval("{language}", {escaped})'
