from argparse import ArgumentParser, Namespace
from random import randint
from pathlib import Path
import os

import polyglot


project_path = Path(os.path.realpath(__file__)).parent
ruby_path = project_path / "codesources" / "stackoverflow" / "stackoverflow_query"
StackoverflowQuery = polyglot.eval(language="ruby", string="require '{}'; StackoverflowQuery".format(ruby_path))


def compile_top_function(query):
    """
    Interactive snippet selection for the top function objects
    :param query: query
    :return: selected code snippet
    """
    function_input = input("Function input")
    function_output = input("Function Output")

    # function_snippets = query.select_functions(1)
    function_snippets = query.select_method_finder_snippets(function_input, function_output)

    for snippet in function_snippets:
        print("Will compile the following snippet:\n{}".format(snippet.code))
        while True:
            user_input = input("Use this snippet (y/n)?").lower()
            if user_input == "y" or user_input == "n":
                break

        if user_input == "n":
            continue

        snippet.build_function_object()
        if snippet.function_object is None:
            print("The code did not compile correctly.")
            continue

        return snippet


def sort_command():
    """
    Interactive searching and executing of search functions
    """
    num_numbers = None
    while num_numbers is None:
        num_numbers = input("How many numbers should be generated?").strip()
        num_numbers = int(num_numbers) if num_numbers.isnumeric() else None

    data = [randint(0, 100) for _ in range(num_numbers)]
    print("The following data will be sorted:\n{}".format(data))

    query = None
    while query is None:
        query = input("Which sort function should be searched (i.e., the query)?").strip()
        query = query if query else None

    stackoverflow_query = StackoverflowQuery(query, ['python', 'js', 'ruby'])

    sort_function = compile_top_function(stackoverflow_query)

    if sort_function is not None:
        data = sort_function(data)
        print("Sorted data:\t{}".format(data))
    else:
        print("Did not receive any answers")


def query_command():
    """
    Interactive querying of code snippets
    """
    keyword = input("What do you want to query: ").lower().strip()
    query = StackoverflowQuery(keyword, ['python', 'js', 'ruby'])
    for snippet in query.code_snippets():
        print("=======================")
        print("Language: " + snippet.snippet_language)
        print("Author: " + snippet.author)
        print("Question URL: " + snippet.question_url)
        print("Answer URL: " + snippet.answer_url)
        print("License: " + snippet.license)
        print("=======================")
        print(snippet.code)
        command = input("Do you want to show the next result or execute a new query? (n/q)")
        if command == 'n':
            continue
        elif command == 'q':
            break


def cli_args() -> Namespace:
    """
    Parse CLI arguments
    :return: parsed argument
    """
    parser = ArgumentParser(description="Example usage of the automatic code re-use project. Query stackoverflow for"
                                        "implementations of popular problems (such as sorting) and use them directly.")
    parser.add_argument("--sorting", dest='sorting', action='store_true', help="Sort a list of randomly generated "
                                                                               "numbers with an implementation from"
                                                                               "stackoverflow.")
    parser.add_argument("--searching", dest='searching', action='store_true', help="Search stackoverlflow for "
                                                                                   "implementations and browse them.")
    return parser.parse_args()


def main():
    args = cli_args()
    if args.sorting:
        print("This program will sort a randomly generated list of numbers.")
        while True:
            sort_command()
    elif args.searching:
        print("This program will search stackoverflow for a custom query and display the results.")
        while True:
            query_command()
    else:
        print("No mode chosen. Select either --sorting or --searching")


if __name__ == '__main__':
    main()
