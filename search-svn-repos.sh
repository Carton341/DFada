#!/bin/bash

# Search in SVN repositores -- by Juanga 2019
#                              Based on https://svn.haxx.se/users/archive-2006-09/1016.shtml

echo " "
echo -n "*** Will search "$1" in PHP code inside all SVN repositories "

if [[ -z $1 ]]; then

        echo " "
        echo "Usage: $0 string"
        exit 1
fi

# get a list of repos
#  -mindeoth 1  to not include given directory to search in
#  -maxdepth 1  to just list one level inside
#  grep -v DEPRECATED to EXCLUDE those dirs that contain DEPRECATED in dir name
DIRS=$(find /usr/local/svn/repos/ -mindepth 1 -maxdepth 1 -type d | grep -v DEPRECATED)

N_DIRS=$(echo -n "$DIRS" | grep -c '^')

echo "($N_DIRS repos)."

for REPO_DIR in $DIRS; do

        # escape dot to really get .php files only
        FILES=$(svn ls -rHEAD -R file://${REPO_DIR} | grep "\.php")

        N_FILES=$(echo -n "$FILES" | grep -c '^')

        echo "*** Searching in $REPO_DIR ($N_FILES files) ... "

        for FILE in $FILES; do

        # grep --label  to set the "file" since we are filtering standard input, not directly a filename
        # grep --line-number  to force printing the line number since is not default when using standard input
        # grep --no-mesages  to avoid error messages
        # grep -i  case insensitive
        # supress svn cat errors (paths not found) using 2> /dev/null
        CONTENT=$(svn cat -rHEAD file://${REPO_DIR}/${FILE} 2> /dev/null | grep --label=$FILE --color --no-messages --line-number $1)

        if [[ ! -z $CONTENT ]]; then
                echo "--- ${FILE}"
                echo $CONTENT
        fi

        done

done

exit 0

