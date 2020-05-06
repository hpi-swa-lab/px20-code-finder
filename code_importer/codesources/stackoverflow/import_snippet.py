# This is a helper script that imports the CodeSnippet class independent of the working directory. It is called from
# the ruby files in the same directory.

# First get the absolute path to the code_importer directory. This is the "root" directory of our python project.
from pathlib import Path
import os
file_path = Path(os.path.realpath(__file__))
directory_path = file_path.parent
# The path needs to be a string and not a Path object.
code_importer_project_path = str(directory_path.parent.parent.parent)

# Now we add the the path to the code_importer project to the python path.
import sys
if code_importer_project_path not in sys.path:
    sys.path.append(code_importer_project_path)

# Finally, we can import from the code_importer directory as usual and return the CodeSnippet class.
from code_importer.codesnippets import CodeSnippet
CodeSnippet
