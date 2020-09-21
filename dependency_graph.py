# dependency_graph.py
#
# This script walks over a C project and pretty prints all the includes per
# .c/.h file.
import os
import sys
import re

project_path = sys.argv[1]

# Excludes the last '/', because it leads to duplicate '/'s for files in the
# provided directory.
if project_path[-1].endswith(r'/'):
    project_path = project_path[:-1]

stack = list()
indent = 0

for root, _, files in os.walk(project_path, followlinks=False):
    for filename in files:
        if filename.endswith(r'.c') or filename.endswith(r'.h'):
            absolute_path = root + r'/' + filename
            # latin-1 = iso-8859-1
            with open(absolute_path, r'rt', encoding=r'latin-1') as source:
                print(source.name + r':')

                indent = 1
                stack = []

                for line in source:
                    include_match = re.findall(r'#include [<"](.+.h(?:pp)?)[>"]', line, re.ASCII)
                    if include_match:
                        print(r' '*indent + include_match[0])

                    identifier_match = re.search(r'#ifdef (\w+)', line, re.ASCII)
                    if identifier_match:
                        im = identifier_match.group(1)
                        stack.append(im)
                        print(r' '*indent + im)
                        indent += 1
                    elif line.startswith(r'#endif'):
                        try:
                            stack.pop()
                        except IndexError:
                            continue

                        indent -= 1
