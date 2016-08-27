#!/usr/bin/env bash

# Create user and group for wordpress
addgroup -g $UNISON_GID $UNISON_GROUP
adduser -u $UNISON_UID -g $UNISON_GID $UNISON_USER

# Create directory for filesync
if [ ! -d "$UNISON_DIR" ]; then
    echo "Creating $UNISON_DIR directory for sync..."
    mkdir -p $UNISON_DIR >> /dev/null 2>&1
fi

# Create directory for unison meta
if [ ! -d "$UNISON_DIR/.unison" ]; then
    mkdir -p /unison >> /dev/null 2>&1
    chown -R $UNISON_USER:$UNISON_GROUP /unison
fi

# Symlink .unison folder from user home directory to sync directory so that we only need 1 volume
if [ ! -h "$UNISON_DIR/.unison" ]; then
    ln -s /unison /home/$UNISON_USER/.unison >> /dev/null 2>&1
fi

# Change data owner
chown -R $UNISON_USER:$UNISON_GROUP $UNISON_DIR

# Start process on path which we want to sync
cd $UNISON_DIR

# Gracefully stop the process on 'docker stop'
trap 'kill -TERM $PID' TERM INT

# Run unison server as user wordpress
su -c "unison -socket 5000 " $UNISON_USER &

# Wait until the process is stopped
PID=$!
wait $PID
trap - TERM INT
wait $PID
EXIT_STATUS=$?
