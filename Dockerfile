FROM nvidia/cuda:13.0.1-runtime-ubuntu24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# Minimal installs: SSH, Python basics + headless Chromium for LLM/web tasks
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates locales tzdata \
    openssh-server \
    python3 python3-pip python3-venv \
    chromium-browser \
    && rm -rf /var/lib/apt/lists/*

RUN locale-gen en_US.UTF-8

# User "admin" (non-root, sudo-enabled)
RUN useradd -m -s /bin/bash admin \
 && usermod -aG sudo admin \
 && echo "admin:admin" | chpasswd \
 && mkdir -p /etc/sudoers.d \
 && echo "admin ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/admin \
 && mkdir -p /var/run/sshd

# Venv setup (pip ready for selenium/torch adds)
RUN python3 -m venv /home/admin/venv \
 && /home/admin/venv/bin/pip install --upgrade pip
ENV PATH="/home/admin/venv/bin:$PATH"


EXPOSE 22/tcp

COPY scripts/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
USER admin
WORKDIR /home/admin
CMD ["/usr/local/bin/entrypoint.sh"]
