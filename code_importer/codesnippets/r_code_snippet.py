import json
import re
import polyglot

from .code_snippet import CodeSnippet


class RCodeSnippet(CodeSnippet):
    """
    Code snippet for the R language
    """
    snippet_language = "R"

    def is_function(self):
        return re.match(r"\A.+? <- function\(.*?\)", self.code) is not None

    def is_import(self):
        return re.match(r"\A(library|require)\(.*?\)", self.code) is not None

    def is_class(self):
        return re.match(r"\AsetClass\(.*?\)", self.code) is not None

    def _is_code_comment(self, code: str):
        return code.startswith("#")

    def make_comment(self, line):
        return "# {}".format(line)

    @classmethod
    def compare_objects(cls, object1, object2) -> bool:
        func = polyglot.eval(language=cls.snippet_language, string="function(x, y) identical(x, y)")
        return func(object1, object2)

    @classmethod
    def _stringify_polyglot_eval(cls, language: str, value: str):
        escaped = json.dumps(value)
        return f'eval.polyglot("{language}", {escaped})'
