#!/bin/bash
set -e

# ---------------------------------------------------------------------------- #
#                          Function Definitions                                #
# ---------------------------------------------------------------------------- #

print_header() {
    echo "=========================================="
    echo "$1"
    echo "=========================================="
}

setup_ssh() {
    print_header "Setting up SSH..."

    # Create SSH directories
    mkdir -p /var/run/sshd /root/.ssh
    chmod 700 /root/.ssh

    # Enable password authentication (Quickpod requirement)
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/g' /etc/ssh/sshd_config
    sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config

    # Setup public key if provided (Quickpod env variable)
    if [[ -n "$PUBLIC_KEY" ]]; then
        echo "$PUBLIC_KEY" >> /root/.ssh/authorized_keys
        chmod 600 /root/.ssh/authorized_keys
        echo "✓ Added public key for root"
    fi

    # Start SSH service (Quickpod method)
    service ssh start
    echo "✓ SSH service started"
}

setup_user() {
    local username="${SSH_USER:-admin}"
    local password="${SSH_PASSWORD:-admin}"

    print_header "Setting up user: $username..."

    # Create user if doesn't exist
    if ! id -u "$username" >/dev/null 2>&1; then
        useradd -m -s /bin/bash "$username"
    fi

    # Set password
    echo "$username:$password" | chpasswd

    # Add to sudo group with no password
    usermod -aG sudo "$username"
    mkdir -p /etc/sudoers.d
    echo "$username ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$username
    chmod 0440 /etc/sudoers.d/$username

    # Setup SSH directory
    mkdir -p /home/$username/.ssh
    chmod 700 /home/$username/.ssh

    # Copy shell configs
    for file in .bashrc .profile .bash_logout; do
        cp /etc/skel/$file /home/$username/ 2>/dev/null || true
    done

    # Add public key if provided
    if [[ -n "$PUBLIC_KEY" ]]; then
        echo "$PUBLIC_KEY" >> /home/$username/.ssh/authorized_keys
        chmod 600 /home/$username/.ssh/authorized_keys
    fi

    # Fix ownership
    chown -R $username:$username /home/$username

    echo "✓ User configured"
}

setup_python_venv() {
    local username="${SSH_USER:-admin}"

    if [[ ! -d /home/$username/venv ]]; then
        print_header "Setting up Python venv..."
        su - $username -c "python3 -m venv /home/$username/venv"
        su - $username -c "/home/$username/venv/bin/pip install --upgrade pip setuptools wheel"
        echo "✓ Virtual environment ready"
    fi
}

print_info() {
    print_header "Container Ready"

    local username="${SSH_USER:-admin}"
    local password="${SSH_PASSWORD:-admin}"

    echo "SSH: Port 22"
    echo "  Root: root / root"
    echo "  User: $username / $password"
    echo ""

    if command -v nvidia-smi &> /dev/null; then
        echo "GPU: $(nvidia-smi --query-gpu=name --format=csv,noheader 2>/dev/null || echo 'Unknown')"
    fi

    echo "Python: $(python3 --version 2>/dev/null || echo 'Not found')"

    if [[ -d /home/$username/venv ]]; then
        echo "Venv: /home/$username/venv"
    fi

    print_header ""
}

# ---------------------------------------------------------------------------- #
#                               Main Program                                   #
# ---------------------------------------------------------------------------- #

print_header "Pod Starting..."

setup_ssh
setup_user
setup_python_venv
print_info

echo "Keeping container alive..."
sleep infinity
