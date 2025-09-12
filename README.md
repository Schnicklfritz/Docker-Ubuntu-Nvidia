# Ubuntu 24.04 + CUDA 13.0.1 + XFCE + X2Go Base Docker Image

This Docker image provides a **base Ubuntu 24.04 desktop environment** with the **Nvidia CUDA 13.0.1 runtime environment, XFCE desktop environment**, and an **X2Go server** for remote GUI access. It is tailored for GPU-accelerated workloads, AI/ML development, multimedia, and general desktop use on cloud or local systems.

---

## Features

- Ubuntu 24.04 LTS base
- Full Nvidia CUDA 13.0.1 runtime environment (x86_64) 
- XFCE desktop environment with common utilities and goodies
- X2Go server configured for remote desktop sessions with XFCE auto-start
- PulseAudio configured for audio forwarding
- Python 3 and scientific/ML libraries installed
- Non-root user `user` with sudo privileges (default password: `user`)
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


- Connect using X2Go client via SSH on port `2222`.
- Username: `user`
- Password: `user`

---

## Access and Development

- X2Go automatically starts the XFCE desktop session upon connection.
- Audio is forwarded via PulseAudio to support multimedia applications.
- The base image can be extended with additional apps and tools as needed.

---

## GPU and CUDA Support

This image exposes all GPUs and driver capabilities to the container. Use the `--gpus all` option with `docker run` to enable GPU access.

---

## Contributing

You are welcome to fork this repository and create derived images tailored to your specific use cases such as voice cloning, Reaper, ComfyUI, dataset processing, or other GPU-accelerated applications.

---

## License

This project is licensed under the MIT License.

---

## Contact

For questions or feedback, please contact [Schnicklfritz@users.noreply.github.com].
