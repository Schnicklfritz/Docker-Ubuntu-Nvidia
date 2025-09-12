# Ubuntu 24.04 + CUDA 13.0 + XFCE + X2Go Base Docker Image

/ _ )___ / /__ / / / / /_/ // // / ____
/ _ / _ / / -) _ / // __/ __/ __/ __/ / -) __/
//_//_////__/_/_/_/_//_/_/


This Docker image provides a **base Ubuntu 24.04 desktop environment** with **Nvidia CUDA 13.0 development toolkit, XFCE desktop**, and **X2Go server** for remote GUI access. It is tailored for GPU-accelerated workloads, AI/ML development, multimedia, and general desktop use on cloud or local systems.

---

## Features

- Ubuntu 24.04 LTS base
- Full Nvidia CUDA 13.0 development environment (`devel` image)
- XFCE desktop environment with goodies
- X2Go server configured for remote desktop sessions (XFCE auto-start)
- PulseAudio setup for audio forwarding
- Commonly used utilities, Python 3 and scientific/ML libraries installed
- Non-root user `user` with sudo privileges (password: `user`)
- SSH server configured on default port 22

---

## Usage

### Build the image locally

docker build -t yourusername/ubuntu24-cuda-xfce-x2go:latest .

### Run the container

docker run -d --gpus all -p 2222:22
-v /host/home/user:/home/user
-v /host/datasets:/mnt/data
yourusername/ubuntu24-cuda-xfce-x2go:latest


- Connect to the container via X2Go client using SSH on port 2222.
- Username: `user`
- Password: `user`

### Access and Development

- X2Go will start the XFCE desktop automatically upon connection.
- Audio is forwarded through PulseAudio.
- You can extend this base image with your specific apps and tools.

---

## GPU and CUDA

This image exposes all GPUs and driver capabilities to the container. Use the `--gpus all` option in `docker run` to pass GPU access.

---

## Contributing

Feel free to fork and create derived images for your specific needs like voice cloning, Reaper, ComfyUI, or dataset processing.

---

## License

This project is licensed under the MIT License.

---

## Contact

For questions and feedback, please contact [your-email@example.com].

