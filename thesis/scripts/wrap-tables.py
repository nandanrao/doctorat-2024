#!/usr/bin/env python3
"""Wrap outermode tabular environments with \adjustbox{max width=\textwidth}
so tables don't overflow into margins."""

import re, sys, os, glob

def fix_file(path):
    with open(path) as f:
        content = f.read()

    if '\\adjustbox{max width=' in content:
        return False
    if '\\begin{tabular}' not in content or '\\end{tabular}' not in content:
        return False

    # Use the FIRST \begin{tabular} (outermost) and LAST \end{tabular}
    # This handles nested tabulars inside \multicolumn cells.
    m_begin = re.search(r'\\begin\{tabular\}', content)
    # Find all \end{tabular} matches, use the last one
    all_ends = list(re.finditer(r'\\end\{tabular\}', content))
    if not m_begin or not all_ends:
        return False

    m_end = all_ends[-1]  # last (outermost) closing

    tab_start = m_begin.start()
    tab_end = m_end.end()

    new_content = (
        content[:tab_start] +
        '\\adjustbox{max width=\\textwidth}{%\n' +
        content[tab_start:tab_end] +
        '\n}%\n' +
        content[tab_end:]
    )

    with open(path, 'w') as f:
        f.write(new_content)
    return True


def main():
    dirs = sys.argv[1:] if len(sys.argv) > 1 else ['.']
    count = 0
    for d in dirs:
        for pattern in ['*.tex', '*.te']:
            for path in sorted(glob.glob(os.path.join(d, pattern))):
                if fix_file(path):
                    print(f"  wrapped: {os.path.basename(path)}")
                    count += 1
    print(f"  {count} tables fixed")


if __name__ == '__main__':
    main()
