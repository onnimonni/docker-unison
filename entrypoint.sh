#!/usr/bin/env bash

UNISON_UID=1000 # user id for user wordpress (set this to web container also)
UNISON_GID=1001 # group id for group web (set this to web container also)

# Create user and group for wordpress
addgroup -g $UNISON_GID web
adduser -u $UNISON_UID -g $UNISON_GID wordpress

# Create directory for filesync
if [ ! -d "$UNISON_DIR" ]; then
    echo "Creating $UNISON_DIR directory for sync..."
    mkdir -p $UNISON_DIR >> /dev/null 2>&1
fi

# Change data owner
chown -R wordpress:web $UNISON_DIR

# Start process on path which we want to sync
cd $UNISON_DIR

# Gracefully stop the process on 'docker stop'
trap 'kill -TERM $PID' TERM INT

# Run unison server as user wordpress
su -c "unison -socket 5000" wordpress &

# Wait until the process is stopped
PID=$!
wait $PID
trap - TERM INT
wait $PID
EXIT_STATUS=$?
