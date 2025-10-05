
FROM nvidia/cuda:13.0.1-runtime-ubuntu24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility,display
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# Install SSH, basics (nano/python for manual steps), and unminimize tool (but don't run it yet)
RUN apt-get update && apt-get install -y --no-install-recommends \
    openssh-server \
    ubuntu-minimal \
    nano \
    python3 python3-pip \
    locales \
    && locale-gen en_US.UTF-8 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# SSH setup (for access/tunneling)
RUN mkdir /var/run/sshd && ssh-keygen -A && \
    echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config && \
    echo 'X11Forwarding yes' >> /etc/ssh/sshd_config && \
    echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config && \
    echo 'GatewayPorts yes' >> /etc/ssh/sshd_config

# User "fritz" with full perms
RUN useradd -m -s /bin/bash fritz && \
    usermod -aG sudo,audio,video fritz && \
    echo 'fritz:fritz' | chpasswd && \
    echo 'fritz ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/fritz && \
    chmod 0440 /etc/sudoers.d/fritz

# Copy entrypoint from scripts/ dir
COPY scripts/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

WORKDIR /home/fritz
EXPOSE 22

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/sbin/sshd", "-D"]
