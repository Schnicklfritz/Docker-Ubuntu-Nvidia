FROM nvidia/cuda:13.0.1-runtime-ubuntu24.04

# Essential utilities that every container needs
RUN apt update && apt install -y \
    # Archive/compression tools
    tar gzip unzip zip p7zip-full \
    # Network utilities (netcat-bsd is ESSENTIAL for SSH)
    netcat-bsd openssh-server \
    # File transfer/download
    curl wget rsync \
    # Text processing
    nano vim-tiny less \
    # System utilities
    htop procps \
    # Development basics
    git build-essential \
    # Python (almost everything needs it)
    python3 python3-pip \
    # Desktop infrastructure
    x2goserver x2goserver-xsession \
    xfce4-session xfce4-panel xfwm4 xfdesktop4 xfce4-terminal \
    # Audio support
    alsa-utils \
    && apt clean && rm -rf /var/lib/apt/lists/*

# Fix SSH setup (hostkeys + proper netcat)
RUN mkdir /var/run/sshd && ssh-keygen -A && \
    echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config && \
    echo 'X11Forwarding yes' >> /etc/ssh/sshd_config

# User setup with proper groups
RUN useradd -m -G audio,sudo user && echo "user:user" | chpasswd

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
