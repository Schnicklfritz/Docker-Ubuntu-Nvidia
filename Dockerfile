FROM nvidia/cuda:13.0.1-runtime-ubuntu24.04

ENV DEBIAN_FRONTEND=noninteractive

# Install minimal essentials
RUN apt update && apt install -y \
    # SSH essentials (MUST work first)
    openssh-server \
    netcat-openbsd \
    nano \
    # Minimal XFCE desktop
    xfce4-session \
    xfce4-panel \
    xfce4-terminal \
    xfwm4 \
    && apt clean && rm -rf /var/lib/apt/lists/*

# SSH setup
RUN mkdir /var/run/sshd && ssh-keygen -A && \
    echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config && \
    echo 'X11Forwarding yes' >> /etc/ssh/sshd_config

# User setup
RUN useradd -m user && echo "user:user" | chpasswd

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
