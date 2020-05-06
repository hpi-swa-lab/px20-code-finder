import json
import os
import re

from abc import ABC, abstractmethod
from pathlib import Path
from typing import List

import polyglot


class CodeSnippet(ABC):
    """ Representation of a code snippet """

    __highlighter_for_language = {}
    snippet_language = None

    def __init__(self,
                 code: str,
                 author: str = None,
                 question_url: str = None,
                 answer_url: str = None,
                 question_score: int = None,
                 answer_score: int = None,
                 is_accepted_answer: bool = None,
                 index: int = None):
        self.code = self.normalize_indent(code)
        self.function_object = None

        # Metadata fields
        self.author = author
        self.question_url = question_url
        self.answer_url = answer_url
        # https://stackoverflow.com/help/licensing
        self.license = 'CC BY-SA 3.0'
        self.question_score = question_score
        self.answer_score = answer_score
        self.is_accepted_answer = is_accepted_answer
        self.index = index

        # Store the decision of the user if this snippet should be compiled
        self.should_compile: bool = None

    def __call__(self, *args):
        """
        If the code snippet represents a function, it gets executed with the given data as argument.
        :param data: parameter for the function
        :return: result of the code snippet function applied on the data parameter
        """
        if self.function_object is None:
            self.build_function_object()
        return self.function_object(*args)

    def __str__(self):
        shortened_code = self.code[:min(len(self.code), 20)].replace("\n", "\\n")
        return "{}(code={}, author={}, question_url={}, answer_url={})".format(
            self.__class__.__name__, shortened_code, self.author, self.question_url, self.answer_url)

    __repr__ = __str__

    def set_code(self, code):
        """
        This method is called from squeak and overwrites the code content with a user edited version. This edited
        version can contain multiple kinds of newlines. Thus, they are first replaced with \n.
        :param code: the smalltalk code string
        """
        code = str(code)
        code = code.replace('\r\n', '\n').replace('\r', '\n')
        self.code = code

    def header(self) -> str:
        """
        :return: a short string representation of the code snippet
        """
        return self.code.splitlines(keepends=False)[0]

    def code_with_license(self):
        """
        :return: string representation of the code snippets with licesing information in header format
        """
        url = self.make_comment("Answer URL: {}".format(self.answer_url))
        author = self.make_comment("Author: {}".format(self.author))
        license = self.make_comment("License: {}".format(self.license))
        display = [url, author, license, self.code]
        return "\n".join(display)

    def source_lines_of_code(self):
        return len([line for line in self.code.split("\n") if not self._is_code_comment(line)])

    def normalize_indent(self, code: str):
        """
        Normalize the indentation of the given code
        :param code: code that should be normalized
        :return: normalized code
        """
        lines = code.splitlines(keepends=True)
        lines = {line: len(line) - len(line.lstrip(" ")) for line in lines}
        indent_size = 0
        for line_indent_size in lines.values():
            if line_indent_size > 0:
                indent_size = line_indent_size
                break
        normalized_code = ""
        for line, line_indent_size in lines.items():
            if line_indent_size == 0:
                normalized_code += line
            else:
                num_indents = int(line_indent_size / indent_size)
                if line_indent_size % indent_size == 0:
                    normalized_line = ("\t" * num_indents) + line.lstrip(" ")
                else:
                    normalized_line = ("\t" * num_indents) + (" " * (line_indent_size % indent_size)) + line.lstrip(" ")
                normalized_code += normalized_line
        return str(normalized_code)

    @classmethod
    def highlighter_for_language(cls, language: str):
        """
        Get the Ruby code highlighter object for the given language. This method caches previously used highlighter
        objects in a dictionary to avoid calling the Polyglot API for every single snippet.
        :param language: Polyglot language id for which the highlighter is returned
        :return: code highlighter, which is a Ruby object, for the given language
        """
        language_to_import_name = {
            "js": "JavascriptHighlighter",
            "python": "PythonHighlighter",
            "R": "RHighlighter",
            "ruby": "RubyHighlighter",
            "smalltalk": "SmalltalkHighlighter"
        }
        if language not in cls.__highlighter_for_language:
            highlighter_import = language_to_import_name[language]
            project_path = Path(os.path.realpath(__file__)).parent.parent
            highlighter_path = project_path / "highlighters" / "code_highlighter"
            ruby_code = "require '{}'; {}".format(highlighter_path, highlighter_import)
            highlighter = polyglot.eval(language='ruby', string=ruby_code)
            cls.__highlighter_for_language[language] = highlighter
        return cls.__highlighter_for_language[language]

    def is_valid_code(self):
        """
        Checks if the code is valid code in the target language
        :return: True iff the code is valid
        """
        highlighter = CodeSnippet.highlighter_for_language(self.snippet_language)
        return highlighter.is_valid(self.code)

    def is_valid_beginning(self):
        """
        Checks if the code snippets begins with a function, import, class or comment definition
        :return: True iff the code snippets represents one of the concepts
        """
        return self.is_function() or self.is_import() or self.is_class() or self.is_comment() or self.is_unstructured_code()

    @abstractmethod
    def is_function(self):
        """
        Checks if the code snippet represents a function
        :return: True iff the code snippet represents a function
        """
        raise NotImplementedError

    @abstractmethod
    def is_class(self):
        """
        Checks if the code snippet represents a class
        :return: True iff the code snippet represents a class
        """
        raise NotImplementedError

    @abstractmethod
    def is_import(self):
        """
        Checks if the code snippet represents an import
        :return: True iff the code snippet represents an import
        """
        raise NotImplementedError

    @abstractmethod
    def _is_code_comment(self, code: str):
        """
        Checks if the passed code represents a comment
        :param code the code that is tested
        :return: True if the code represents a comment
        """
        raise NotImplementedError

    def is_comment(self):
        """
        Checks if the code snippet represents a comment
        :return: True iff the code snippet represents a comment
        """
        return self._is_code_comment(self.code)

    def is_unstructured_code(self):
        """
        Checks if the code snippet represents unstructured code (starts with an alphabetic character)
        :return: True if the code snippet represents unstructured code
        """
        return re.match("[a-zA-Z]", self.code) is not None

    @abstractmethod
    def make_comment(self, line):
        """
        Transform a given line in a line comment for the target language
        :param line: line that should be commented
        :return: line comment for the given line
        """
        raise NotImplementedError

    @abstractmethod
    def function_return_statement(self):
        """
        :return: line that has to be added to the end of the snippet to return the function object
        """
        raise NotImplementedError

    @classmethod
    @abstractmethod
    def _stringify_polyglot_eval(cls, language: str, value: str):
        """
        Create a polyglot eval string that compiles the string input into an object of the snippets language. This
        string must escape quotes in the input.
        :param language: the language in which the object will be interpreted
        :param value: the input object as string
        :return: the polyglot eval call with escaped quotes as string
        """
        raise NotImplementedError

    def is_invalid_snippet(self):
        return False

    def function_arguments(self):
        """
        Parse the function arguments in the code snippet as list
        :return: list of function arguments
        """
        if not self.is_function():
            return False
        function_args_reg = '\((?P<args>(?P<arg>[\w=]+(,\s?)?)+)\)'
        match = re.search(function_args_reg, self.code)
        if not match:
            return None
        args = map(str.strip, match.group('args').split(','))
        return list(args)

    def function_argument_count(self):
        """
        Count the number of function arguments
        :return: number of function arguments
        """
        args = self.function_arguments()
        if args:
            return len(args)
        else:
            return 0

    def build_function_object(self):
        """
        Build function object and assign it to the instance variable `function_object`
        """
        eval_string = self.code + '\n' + self.function_return_statement()
        self.function_object = polyglot.eval(language=self.snippet_language, string=eval_string.__str__())

    def test_function(self, language: str, input_code: str, output_code: str) -> bool:
        """
        Test if this snippet produces the correct output with the given input. The execution of the snippets is
        sandboxed (can't access the host system and also limited in execution time).
        :param language: the language id of the language of input and output code snipper
        :param input_code: when evaluated produces a list of arguments passed to this snippet
        :param output_code: when evaluated produces the output that this snippet should produce
        :return: True of this snippet fulfills the constraints, False otherwise
        """
        language = str(language)
        input_data = polyglot.eval(language=language, string=str(input_code))
        output_data = polyglot.eval(language=language, string=str(output_code))

        # First filter if the number of arguments don't align
        if len(input_data) != self.function_argument_count():
            return False

        # Don't test snippets with data from other languages since that might crash the squeak image
        if self.snippet_language != language:
            return False

        # Temporarily ask the user for verification while we don't have sandboxing
        if self.should_compile is None:
            print("Will compile the following snippet:\n{}".format(self.code))
            while True:
                user_input = input("Use this snippet (y/n)?").lower()
                if user_input == "y" or user_input == "n":
                    self.should_compile = True
                    break
            if user_input == "n":
                self.should_compile = False
                return False
        elif not self.should_compile:
            return False

        # Catch any exception produced by compiling and testing the function. If anything is raised, this snippet
        # does not pass the test.
        try:
            result = self(*input_data)
        except:
            return False
        return self.compare_objects(result, output_data)

    # def test_in_sandbox(self, language: str, input_code: str, output_code: str) -> bool:
    #     language = str(language)
    #     input_eval = self._stringify_polyglot_eval(language, str(input_code))
    #     output_eval = self._stringify_polyglot_eval(language, str(output_code))
    #
    #     # Compile input data for testing
    #     input_data = polyglot.eval(language=language, string=str(input_code))
    #     # First filter if the number of arguments don't align
    #     if len(input_data) != self.function_argument_count():
    #         return False
    #
    #     eval_string = self.code + '\n' + self.function_return_statement()
    #
    #     args = ""
    #     input_json = json.load()
    #     for index, _ in enumerate(input_data):
    #
    #     f"{self.function_return_statement()}()"
    #
    #     self.function_object = polyglot.eval(language=self.snippet_language, string=eval_string.__str__())
    #
    #     if self.function_object is None:
    #         self.build_function_object()
    #     return self.function_object(*args)

    @classmethod
    def compare_objects(cls, object1, object2) -> bool:
        """
        Compare two objects in this snippet's language.
        :param object1: first object
        :param object2: second object
        :return: True if both objects equal each other (in their language)
        """
        raise NotImplementedError

    @classmethod
    def create(cls,
               code: str,
               tags: List[str],
               author: str,
               question_url: str,
               answer_url: str,
               question_score: int,
               answer_score: int,
               is_accepted_answer: bool,
               index: int):
        """
        Instance creation method, which handles e.g. language selection and code validation
        :param code: code that should be transformed in a code snippet
        :param tags: list of tags associated with the code snippet
        :param author: name of the author
        :param question_url: url to the question source
        :param answer_url: url to the answer source
        :param question_score: number of upvotes of the question
        :param answer_score: number of upvotes of the answer
        :param is_accepted_answer: if the answer was the accepted answer
        :param index: the position in the result set (determined by when the snippet was produced)
        :return: a code snippet
        """
        code = str(code)
        author = str(author)
        question_url = str(question_url)
        answer_url = str(answer_url)
        tags = [str(tag).lower() for tag in tags]
        language_to_subclass = {subclass.snippet_language.lower(): subclass
                                for subclass in cls.__subclasses__()
                                if subclass.snippet_language is not None}
        language_to_subclass["javascript"] = language_to_subclass["js"]
        language_intersection = set(language_to_subclass.keys()).intersection(tags)

        metadata = dict(author=author,
                        question_url=question_url,
                        answer_url=answer_url,
                        question_score=question_score,
                        answer_score=answer_score,
                        is_accepted_answer=is_accepted_answer,
                        index=index)
        if len(language_intersection) == 0:
            from .invalid_code_snippet import InvalidCodeSnippet
            return InvalidCodeSnippet(code=code, tags=tags, **metadata)
        elif len(language_intersection) == 1:
            language = list(language_intersection)[0]
            return language_to_subclass[language](code=code, **metadata)
        else:
            from .invalid_code_snippet import InvalidCodeSnippet
            return InvalidCodeSnippet(code=code, tags=tags, **metadata)
