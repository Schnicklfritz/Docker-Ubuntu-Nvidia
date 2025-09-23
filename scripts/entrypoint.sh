#!/bin/bash
# Dynamic user creation and SSH key handling
SSH_USER=${SSH_USER:-user}
SSH_PASSWORD=${SSH_PASSWORD:-user}

if ! id "$SSH_USER" &>/dev/null; then
    useradd -m -G audio,sudo $SSH_USER
fi

if [ -n "$SSH_PASSWORD" ]; then
    echo "$SSH_USER:$SSH_PASSWORD" | chpasswd
fi

# Handle public keys if provided
if [ -n "$PUBLIC_KEY" ]; then
    HOME_DIR=$(getent passwd "$SSH_USER" | cut -d: -f6)
    mkdir -p $HOME_DIR/.ssh
    echo $PUBLIC_KEY > $HOME_DIR/.ssh/authorized_keys
    chown -R $SSH_USER:$SSH_USER $HOME_DIR/.ssh
    chmod 700 $HOME_DIR/.ssh
    chmod 600 $HOME_DIR/.ssh/authorized_keys
fi

exec /usr/sbin/sshd -D
