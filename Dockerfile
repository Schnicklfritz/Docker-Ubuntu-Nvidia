# Base image providing Ubuntu 24.04 with CUDA 13.0.1 runtime and XFCE desktop

FROM nvidia/cuda:13.0.1-runtime-ubuntu24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility,graphics,video,display
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# Install base packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates locales tzdata sudo dbus-x11 x11-xserver-utils xauth \
    xfce4 xfce4-goodies xfce4-terminal \
    x2goserver x2goserver-xsession x2goserver-x2gokdrive \
    pulseaudio pavucontrol alsa-utils \
    openssh-server lsb-release curl wget git vim nano htop less \
    build-essential cmake python3 python3-pip python3-venv \
    netcat-traditional iputils-ping \
 && rm -rf /var/lib/apt/lists/*

# Generate locale
RUN locale-gen en_US.UTF-8

# Create default user with sudo privileges
RUN useradd -m -s /bin/bash user \
 && usermod -aG sudo,audio,video user \
 && echo "user:user" | chpasswd \
 && echo "user ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/user

# Prepare SSH daemon directory
RUN mkdir -p /var/run/sshd

# Set user environment
USER user
WORKDIR /home/user

# Setup XFCE autostart
RUN echo "startxfce4" > /home/user/.xsession

# Copy helper scripts
COPY scripts /home/user/scripts
RUN chmod +x /home/user/scripts/*.sh

# Setup Python environment with common packages
RUN python3 -m pip install --upgrade pip setuptools wheel \
 && python3 -m pip install \
    numpy scipy torch torchvision torchaudio transformers diffusers pillow \
    ffmpeg-python soundfile librosa

# Expose SSH default port
EXPOSE 22

# Set entrypoint script
ENTRYPOINT ["/home/user/scripts/entrypoint.sh"]

# Default command (keeps sshd running)
CMD []
