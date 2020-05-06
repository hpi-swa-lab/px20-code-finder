from .code_snippet import CodeSnippet


class InvalidCodeSnippet(CodeSnippet):
    """
    Null Object to represent an invalid code snippet
    """
    snippet_language = None

    def __init__(self, tags, **kwargs):
        super(InvalidCodeSnippet, self).__init__(**kwargs)
        self.tags = tags

    def __str__(self):
        string = super(InvalidCodeSnippet, self).__str__()
        return "{}, tags={})".format(string[:-1], self.tags)

    __repr__ = __str__

    def is_invalid_snippet(self):
        return True

    def is_valid_code(self):
        return False

    def is_function(self):
        return False

    def is_import(self):
        return False

    def is_class(self):
        return False

    def _is_code_comment(self, code: str):
        return False

    def is_valid_beginning(self):
        return False
