#!/bin/bash
set -e  # Exit on any error

# ---------------------------------------------------------------------------- #
#                          Function Definitions                                #
# ---------------------------------------------------------------------------- #

# Print header
print_header() {
    echo "=========================================="
    echo "$1"
    echo "=========================================="
}

# Setup SSH
setup_ssh() {
    print_header "Setting up SSH..."

    # Create SSH directory structure
    mkdir -p /var/run/sshd /root/.ssh
    chmod 700 /root/.ssh

    # Enable password authentication
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
    sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config

    # Setup public key if provided
    if [[ $PUBLIC_KEY ]]; then
        echo "Adding public key for root"
        echo "$PUBLIC_KEY" >> /root/.ssh/authorized_keys
        chmod 600 /root/.ssh/authorized_keys
    fi

    # Start SSH service
    service ssh start
    echo "✓ SSH service started on port 22"
}

# Create and setup admin user
setup_admin_user() {
    print_header "Setting up admin user..."

    local username="${SSH_USER:-admin}"
    local password="${SSH_PASSWORD:-admin}"

    # Create user if doesn't exist
    if ! id -u "$username" >/dev/null 2>&1; then
        useradd -m -s /bin/bash "$username"
        echo "✓ Created user: $username"
    fi

    # Set password
    echo "$username:$password" | chpasswd

    # Add to sudo group
    usermod -aG sudo "$username"

    # Grant passwordless sudo
    mkdir -p /etc/sudoers.d
    echo "$username ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$username
    chmod 0440 /etc/sudoers.d/$username

    # Setup SSH directory
    mkdir -p /home/$username/.ssh
    chmod 700 /home/$username/.ssh

    # Copy shell config files
    cp /etc/skel/.bashrc /home/$username/.bashrc 2>/dev/null || true
    cp /etc/skel/.profile /home/$username/.profile 2>/dev/null || true
    cp /etc/skel/.bash_logout /home/$username/.bash_logout 2>/dev/null || true

    # Setup public key if provided
    if [[ $PUBLIC_KEY ]]; then
        echo "$PUBLIC_KEY" >> /home/$username/.ssh/authorized_keys
        chmod 600 /home/$username/.ssh/authorized_keys
    fi

    # Fix ownership
    chown -R $username:$username /home/$username

    echo "✓ User '$username' configured with password access"
}

# Setup Python virtual environment
setup_python_venv() {
    local username="${SSH_USER:-admin}"

    if [[ ! -d /home/$username/venv ]]; then
        print_header "Setting up Python virtual environment..."
        su - $username -c "python3 -m venv /home/$username/venv"
        su - $username -c "/home/$username/venv/bin/pip install --upgrade pip setuptools wheel"
        echo "✓ Virtual environment created at /home/$username/venv"
    fi
}

# Print system info
print_system_info() {
    print_header "Container Ready"

    local username="${SSH_USER:-admin}"
    local password="${SSH_PASSWORD:-admin}"

    echo "SSH Access:"
    echo "  Port: 22"
    echo "  Root: root / root"
    echo "  User: $username / $password"
    echo ""

    if command -v nvidia-smi &> /dev/null; then
        local gpu_name=$(nvidia-smi --query-gpu=name --format=csv,noheader 2>/dev/null || echo "Unknown")
        echo "GPU: $gpu_name"
    else
        echo "GPU: No NVIDIA GPU detected"
    fi

    local python_version=$(python3 --version 2>/dev/null || echo "Python not found")
    echo "Python: $python_version"

    if [[ -d /home/$username/venv ]]; then
        echo "Virtual Environment: /home/$username/venv"
        echo "  Activate: source /home/$username/venv/bin/activate"
    fi

    print_header ""
}

# ---------------------------------------------------------------------------- #
#                               Main Program                                   #
# ---------------------------------------------------------------------------- #

print_header "Pod Starting..."

# Run setup functions
setup_ssh
setup_admin_user
setup_python_venv

# Print info
print_system_info

# Keep container running
echo "Container is ready. Keeping alive..."
sleep infinity
