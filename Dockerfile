FROM nvidia/cuda:13.0.1-runtime-ubuntu24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility,graphics,video,display
ENV CUDA_VERSION=13.0


# Update and install GUI, X2Go, audio, and utilities
RUN apt-get update && apt-get install -y \
    netcat iputils-ping curl wget ssh openssh-server lsb-release \
    python3 python3-pip build-essential cmake git \
    zip unzip tar vim nano htop less screen \
    pulseaudio pavucontrol alsa-utils xfce4 xfce4-goodies \
    x2goserver x2goserver-xsession dbus-x11 x11-xserver-utils \
    sudo adduser passwd \
    && apt-get clean && rm -rf /var/lib/apt/lists/* && \
    python3 -m pip install --upgrade pip && \
    pip install numpy scipy pandas scikit-learn matplotlib seaborn \
                torch tensorflow opencv-python wheel setuptools cython requests \
                jupyterlab notebook soundfile librosa torchaudio h5py tqdm \
                pytest flask pillow


# Create standard user and add to sudoers
RUN useradd -m -s /bin/bash user \
    && usermod -aG sudo,audio,video user \
    && echo "user:user" | chpasswd \
    && adduser user sudo


# Allow sudo without password for user (optional, convenient for dev)
RUN echo "user ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/user

# Setup PulseAudio for the user (allow network clients and local)
RUN mkdir -p /home/user/.config/pulse && chown -R user:user /home/user/.config

# Switch to user to configure X2Go home
USER user
WORKDIR /home/user
RUN echo "startxfce4" > /home/user/.xsession

# Switch back to root
USER root

# Expose SSH port
EXPOSE 22

# Entry point script will start SSH and PulseAudio services
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

CMD ["/usr/local/bin/entrypoint.sh"]
