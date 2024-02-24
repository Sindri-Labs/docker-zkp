#! /bin/bash

# Parse the arguments and log usage.
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 username/repository"
    exit 1
fi
REPO_URL="https://github.com/$1.git"

# Make a temporary directory to clone the repo and ensure it's cleaned up after.
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

# Clone the repository.
git clone --bare --depth 1 $REPO_URL $TEMP_DIR > /dev/null 2>&1
cd $TEMP_DIR
git fetch --depth=1 origin +refs/tags/*:refs/tags/* > /dev/null 2>&1

# List and sort tags by date, from oldest to newest.
git for-each-ref --sort=creatordate --format '%(refname:short)' refs/tags
