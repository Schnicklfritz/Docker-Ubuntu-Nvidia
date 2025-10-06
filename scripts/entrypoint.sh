#!/bin/bash
# Minimal entrypoint: GPU/audio setup + SSH
set -e   # exit on error

# Ensure running as root
if [ "$(id -u)" -ne 0 ]; then
    echo "ERROR: Entrypoint must run as root to start sshd"
    exit 1
fi

export NVIDIA_VISIBLE_DEVICES=all
export NVIDIA_DRIVER_CAPABILITIES=compute,utility,display
export DISPLAY=${DISPLAY:-:0}
export PYTHONPATH=/workspace:$PYTHONPATH
export PATH=/home/admin/.local/bin:$PATH

SSH_USER=${SSH_USER:-admin}
SSH_PASSWORD=${SSH_PASSWORD:-admin}

# Update password if env var provided
if [ "$SSH_PASSWORD" != "admin" ]; then
    echo "$SSH_USER:$SSH_PASSWORD" | chpasswd
fi

# Public key authentication setup
if [ -n "$PUBLIC_KEY" ]; then
    HOME_DIR=$(getent passwd "$SSH_USER" | cut -d: -f6)
    mkdir -p "$HOME_DIR/.ssh"
    echo "$PUBLIC_KEY" > "$HOME_DIR/.ssh/authorized_keys"
    chown -R "$SSH_USER:$SSH_USER" "$HOME_DIR/.ssh"
    chmod 700 "$HOME_DIR/.ssh"
    chmod 600 "$HOME_DIR/.ssh/authorized_keys"
fi

# PulseAudio for audio forwarding (run as admin user)
su - admin -c "pulseaudio --start --exit-idle-time=-1 2>/dev/null" || echo "PulseAudio not started (optional)"

# Display GPU info
GPU_INFO=$(nvidia-smi --query-gpu=name --format=csv,noheader 2>/dev/null || echo "No GPU detected - use --gpus all flag")

echo "=========================================="
echo "Container Ready"
echo "=========================================="
echo "SSH: Port 22 (user: $SSH_USER, pass: $SSH_PASSWORD)"
echo "GPU: $GPU_INFO"
echo "Python: $(python3 --version) in venv at /home/admin/venv"
echo "=========================================="

# Generate SSH host keys if missing
ssh-keygen -A

# Start SSH daemon (blocks, keeps container running)
exec /usr/sbin/sshd -D -e
