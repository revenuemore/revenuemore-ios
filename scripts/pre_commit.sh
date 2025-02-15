#!/bin/bash



echo "*********************************************************"
echo "Running git pre-commit hook. Making sure that its a valid branch..."
echo "*********************************************************"


# Branch

branch="$(git rev-parse --abbrev-ref HEAD)"

echo ""
echo "Current Branch: $branch"
echo ""

if [ "$branch" = "dev" ]; then
  echo "You can't commit directly to dev branch"
  exit 1
fi

if [ "$branch" = "uat" ]; then
  echo "You can't commit directly to uat branch"
  exit 1
fi

if [ "$branch" = "main" ]; then
  echo "You can't commit directly to main branch"
  exit 1
fi

echo ""
echo "The branch is valid, moving onto next step..."
echo ""


echo "*********************************************************"
echo "Running git pre-commit hook. Running Swift Lint... "
echo "*********************************************************"

# Gather the staged files - to make sure changes are saved only for these files.
stagedFiles=$(git diff --staged --name-only)

# This line is required to make sure it works on Apple Silicon.
if [[ "$(uname -m)" == arm64 ]]; then
    export PATH="/opt/homebrew/bin:$PATH"
fi

# Type a script or drag a script file from your workspace to insert its path.
if which swiftlint >/dev/null; then
  swiftlint --fix
else
  echo "warning: SwiftLint not installed, download from https://github.com/realm/SwiftLint"
fi

status=$?

if [ "$status" = 0 ] ; then
    echo "Static analysis found no problems."
    # Add staged file changes to git
    for file in $stagedFiles; do
      if test -f "$file"; then
        git add $file
      fi
    done
    #Exit
    exit 0
else
    echo "*********************************************************"
    echo "       ********************************************      "
    echo 1>&2 "SwiftLint found violations it could not fix."
    echo "Run swiftlint --fix in your terminal and fix the issues before trying to commit again."
    echo "       ********************************************      "
    echo "*********************************************************"
    #Exit
    exit 1
fi
