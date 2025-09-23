FROM nvidia/cuda:13.0.1-runtime-ubuntu24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility,graphics,video,display
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# Install system dependencies including Python dev packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates locales tzdata sudo dbus-x11 x11-xserver-utils xauth \
    xfce4 xfce4-goodies xfce4-terminal \
    x2goserver x2goserver-xsession x2goserver-x2gokdrive \
    pulseaudio pavucontrol alsa-utils \
    openssh-server lsb-release curl wget git vim nano htop less \
    build-essential cmake python3 python3-pip python3-venv python3-dev libffi-dev libssl-dev libbz2-dev liblzma-dev \
    netcat-traditional iputils-ping \
 && rm -rf /var/lib/apt/lists/*

RUN locale-gen en_US.UTF-8

# Create user and setup sudo privileges
RUN useradd -m -s /bin/bash user \
 && usermod -aG sudo,audio,video user \
 && echo "user:user" | chpasswd \
 && echo "user ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/user

# Copy scripts and adjust permissions
COPY scripts /home/user/scripts
RUN chmod +x /home/user/scripts/*.sh || true

USER user
WORKDIR /home/user

# Create Python virtual environment
RUN python3 -m venv /home/user/venv

ENV PATH="/home/user/venv/bin:$PATH"

# Upgrade pip & install Python dependencies inside virtual environment
RUN pip install --upgrade pip setuptools wheel \
 && pip install numpy scipy torch torchvision torchaudio transformers diffusers pillow ffmpeg-python soundfile librosa

RUN echo "startxfce4" > /home/user/.xsession

EXPOSE 22

ENTRYPOINT ["/home/user/scripts/entrypoint.sh"]
CMD []
