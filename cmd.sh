#!/bin/bash

# Create a new user,
# then launch a shell session with this user.

# This script's path
SELF_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Print usage information
usage() {
    echo "Usage: $0 UID GID" 1>&2
    exit 1
}

# Parse command line arguments
# to get specified UID and GID
if [ $# -ne 2 ]
then
    usage
fi
NEW_UID=$1
NEW_GID=$2

$SELF_DIR/create_user.sh $NEW_UID $NEW_GID
