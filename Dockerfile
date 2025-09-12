
FROM nvidia/cuda:13.0.1-runtime-ubuntu24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility,graphics,video,display
ENV CUDA_VERSION=13.0

# Fix NVIDIA CUDA apt repo keys and URLs for Ubuntu 24.04
RUN apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/3bf863cc.pub && \
    sed -i 's/ubuntu1604/ubuntu2404/g' /etc/apt/sources.list.d/cuda*.list || true && \
    rm -rf /var/lib/apt/lists/* && apt-get update

# Install software-properties-common separately
RUN apt-get install -y software-properties-common

# Add universe and multiverse separately
RUN add-apt-repository universe
RUN add-apt-repository multiverse
RUN apt-get update

# Install base packages in smaller groups
RUN apt-get install -y netcat iputils-ping curl wget
RUN apt-get install -y ssh openssh-server lsb-release
RUN apt-get install -y python3 python3-pip
RUN apt-get install -y build-essential cmake git
RUN apt-get install -y zip unzip tar vim nano htop less screen
RUN apt-get install -y pulseaudio pavucontrol alsa-utils xfce4 xfce4-goodies
RUN apt-get install -y x2goserver x2goserver-xsession dbus-x11 x11-xserver-utils sudo adduser passwd

RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Upgrade pip and install Python AI/ML packages
RUN python3 -m pip install --upgrade pip
RUN pip install numpy scipy pandas scikit-learn matplotlib seaborn \
                torch tensorflow opencv-python wheel setuptools cython requests \
                jupyterlab notebook soundfile librosa torchaudio h5py tqdm \
                pytest flask pillow

# Create standard user and add to sudoers
RUN useradd -m -s /bin/bash user && \
    usermod -aG sudo,audio,video user && \
    echo "user:user" | chpasswd && \
    adduser user sudo

# Allow passwordless sudo for convenience
RUN echo "user ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/user

# Setup PulseAudio config directory permissions
RUN mkdir -p /home/user/.config/pulse && chown -R user:user /home/user/.config

# Switch to user and configure X2Go session startup
USER user
WORKDIR /home/user
RUN echo "startxfce4" > /home/user/.xsession

# Switch back to root user
USER root

# Expose SSH port
EXPOSE 22

# Copy and set permissions for entrypoint script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

CMD ["/usr/local/bin/entrypoint.sh"]
