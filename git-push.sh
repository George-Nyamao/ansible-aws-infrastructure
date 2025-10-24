#!/bin/bash

# Check if commit message is provided
if [ $# -eq 0 ]; then
    echo "Error: Please provide a commit message"
    echo "Usage: ./git-push.sh \"Your commit message\""
    exit 1
fi

COMMIT_MESSAGE="$1"

echo "Starting git operations..."
echo

# Git add all changes
echo "Step 1: Adding all changes..."
git add .
if [ $? -ne 0 ]; then
    echo "Error: Failed to add changes"
    exit 1
fi

# Git commit with the provided message
echo "Step 2: Committing changes with message: \"$COMMIT_MESSAGE\"..."
git commit -m "$COMMIT_MESSAGE"
if [ $? -ne 0 ]; then
    echo "Error: Failed to commit changes"
    exit 1
fi

# Git push to main branch
echo "Step 3: Pushing to origin/main..."
git push origin main
if [ $? -ne 0 ]; then
    echo "Error: Failed to push to origin/main"
    exit 1
fi

echo
echo "Success! All changes have been added, committed, and pushed."
echo "Commit message: \"$COMMIT_MESSAGE\""
