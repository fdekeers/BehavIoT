#!/bin/bash

# Create a user with the given UID and GID,
# then switch to the newly created user.

# VARIABLES
NEW_USER="user"
NEW_GROUP="user"
USER_HOME="/home/user"

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
echo "Using UID ${NEW_UID} and GID ${NEW_GID}"

# Check if group with given GID already exists
if ! getent group "$NEW_GID" &>/dev/null
then
    groupadd --gid ${NEW_GID} ${NEW_GROUP}
fi

# Check if user with given UID already exists
if ! id "$NEW_UID" &>/dev/null
then
    # User does not already exist
    # Create new user with given UID
    useradd --uid ${NEW_UID} --gid ${NEW_GID} --create-home -s /bin/bash ${NEW_USER}
fi

# Update PATH for given user
echo 'export PATH=/home/user/jdk1.7/bin:/home/user/ant1.9/bin:$PATH' >> $USER_HOME/.bashrc

# Switch to new user
su - ${NEW_USER}
