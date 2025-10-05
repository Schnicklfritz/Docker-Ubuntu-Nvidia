FROM nvidia/cuda:13.0.1-runtime-ubuntu24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility,display
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# Run unminimize to expand the base (adds apt, utils, etc.)
RUN unminimize

# Install SSH server (minimal for comms/tunneling)
RUN apt-get update && apt-get install -y --no-install-recommends \
    openssh-server \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# SSH setup (for local terminal/sshuttle)
RUN mkdir /var/run/sshd && ssh-keygen -A && \
    echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config && \
    echo 'X11Forwarding yes' >> /etc/ssh/sshd_config && \
    echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config && \
    echo 'GatewayPorts yes' >> /etc/ssh/sshd_config

# User "fritz" with full perms
RUN useradd -m -s /bin/bash fritz && \
    usermod -aG sudo,audio,video fritz && \
    echo 'fritz:fritz' | chpasswd && \
    echo 'fritz ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/fritz

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

WORKDIR /home/fritz
EXPOSE 22

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/sbin/sshd", "-D"]
