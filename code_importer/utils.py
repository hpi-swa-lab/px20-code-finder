from pathlib import Path

import polyglot


_eval_limited = None


def get_eval_limited():
    global _eval_limited
    if _eval_limited is None:
        path = Path(__file__).absolute()
        eval_file = path.parent / "eval_limited.rb"
        # Reading the file via polyglot does not work for whatever reason.
        code = "".join(open(eval_file).readlines())
        _eval_limited = polyglot.eval(language="ruby", string=code)
    return _eval_limited


def eval_limited(language, string):
    return get_eval_limited()(language, string)
