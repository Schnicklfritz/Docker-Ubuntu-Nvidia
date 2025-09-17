FROM nvidia/cuda:13.0.1-runtime-ubuntu24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility,graphics,video,display
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates locales tzdata \
    sudo dbus-x11 x11-xserver-utils xauth \
    xfce4 xfce4-goodies xfce4-terminal \
    x2goserver x2goserver-xsession x2goserver-x2gokdrive \
    pulseaudio pavucontrol alsa-utils \
    openssh-server lsb-release \
    curl wget git vim nano htop less \
    build-essential cmake \
    python3 python3-pip \
    netcat-traditional iputils-ping \
 && rm -rf /var/lib/apt/lists/*

RUN locale-gen en_US.UTF-8

RUN useradd -m -s /bin/bash user \
 && usermod -aG sudo,audio,video user \
 && echo "user:user" | chpasswd \
 && echo "user ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/user

RUN mkdir -p /var/run/sshd
USER user
RUN echo "startxfce4" > /home/user/.xsession
WORKDIR /home/user
USER root

RUN python3 -m pip install --upgrade pip

EXPOSE 22/tcp

CMD ["/usr/sbin/sshd","-D"]
