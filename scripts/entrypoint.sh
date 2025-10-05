#!/bin/bash
# Minimal entrypoint: GPU/audio setup + SSH

export NVIDIA_VISIBLE_DEVICES=all
export NVIDIA_DRIVER_CAPABILITIES=compute,utility,display
export DISPLAY=${DISPLAY:-:0}
export PYTHONPATH=/workspace:$PYTHONPATH
export PATH=/home/admin/.local/bin:$PATH

SSH_USER=${SSH_USER:-admin}
SSH_PASSWORD=${SSH_PASSWORD:-admin}

if [ -n "$SSH_PASSWORD" ]; then
    echo "$SSH_USER:$SSH_PASSWORD" | chpasswd
fi

if [ -n "$PUBLIC_KEY" ]; then
    HOME_DIR=$(getent passwd "$SSH_USER" | cut -d: -f6)
    mkdir -p $HOME_DIR/.ssh
    echo $PUBLIC_KEY > $HOME_DIR/.ssh/authorized_keys
    chown -R $SSH_USER:$SSH_USER $HOME_DIR/.ssh
    chmod 700 $HOME_DIR/.ssh
    chmod 600 $HOME_DIR/.ssh/authorized_keys
fi

# Optional PulseAudio (for voice translation forwarding)
su - admin -c "pulseaudio --start --exit-idle-time=-1" || echo "PulseAudio skipped"

echo "=== Ready: SSH on 22, GPU $(nvidia-smi 2>/dev/null | head -n1 || echo 'available with --gpus all') ==="

ssh-keygen -A
exec /usr/sbin/sshd -D
