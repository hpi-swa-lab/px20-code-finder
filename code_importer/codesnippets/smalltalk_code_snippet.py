import json

import polyglot

from .code_snippet import CodeSnippet


class SmalltalkCodeSnippet(CodeSnippet):
    """
    Code snippet for the Squeak/Smalltalk language
    """
    def is_function(self):
        return False

    def is_import(self):
        return False

    def is_class(self):
        return False

    def _is_code_comment(self, code: str):
        return code.startswith('"')

    def make_comment(self, line):
        return "\"{}\"".format(line)

    @classmethod
    def compare_objects(cls, object1, object2) -> bool:
        func = polyglot.eval(language=cls.snippet_language, string="[:x :y | x = y]")
        return func(object1, object2)

    @classmethod
    def _stringify_polyglot_eval(cls, language: str, value: str):
        escaped = json.dumps(value).replace("\"", "'")
        return f"Polyglot eval: '{language}' string: {escaped}"
