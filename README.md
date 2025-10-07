# CUDA Base Image

▄████▄ █ ██ ▓█████▄ ▄▄▄ ▄▄▄▄ ▄▄▄ ██████ ▓█████
▒██▀ ▀█ ██ ▓██▒▒██▀ ██▌▒████▄ ▓█████▄ ▒████▄ ▒██ ▒ ▓█ ▀
▒▓█ ▄ ▓██ ▒██░░██ █▌▒██ ▀█▄ ▒██▒ ▄██▒██ ▀█▄ ░ ▓██▄ ▒███
▒▓▓▄ ▄██▒▓▓█ ░██░░▓█▄ ▌░██▄▄▄▄██ ▒██░█▀ ░██▄▄▄▄██ ▒ ██▒▒▓█ ▄
▒ ▓███▀ ░▒▒█████▓ ░▒████▓ ▓█ ▓██▒ ░▓█ ▀█▓ ▓█ ▓██▒▒██████▒▒░▒████▒
░ ░▒ ▒ ░░▒▓▒ ▒ ▒ ▒▒▓ ▒ ▒▒ ▓▒█░ ░▒▓███▀▒ ▒▒ ▓▒█░▒ ▒▓▒ ▒ ░░░ ▒░ ░
░ ▒ ░░▒░ ░ ░ ░ ▒ ▒ ▒ ▒▒ ░ ▒░▒ ░ ▒ ▒▒ ░░ ░▒ ░ ░ ░ ░ ░
░ ░░░ ░ ░ ░ ░ ░ ░ ▒ ░ ░ ░ ▒ ░ ░ ░ ░
░ ░ ░ ░ ░ ░ ░ ░ ░ ░ ░ ░
░ ░ ░


**Minimal NVIDIA CUDA 13.0.1 runtime base image for building specialized GPU workloads.**  
Ubuntu 24.04 with Python, Chrome, and audio support.

---

## Purpose

This is a **base image** designed to be extended for specific projects. Common dependencies are included here; project-specific packages go in derived images.

**Philosophy**: If a package is needed by 2+ projects, it gets added to this base.

---

## What's Included

- **CUDA 13.0.1 Runtime**: GPU compute without development bloat
- **Ubuntu 24.04 LTS**: Minimal system packages
- **Python 3.12 + venv**: Ready for ML/AI packages
- **Google Chrome**: For web automation/scraping
- **PulseAudio**: Audio processing support
- **Admin user**: Non-root with sudo access

---

## Quick Start

### Deploy to Quickpod

1. Use image: `schnicklbob/cuda-desktop-base:latest`
2. SSH via Quickpod's connection string
3. Switch to admin user: `su - admin`

### Access

SSH using Quickpod's UUID (from dashboard)

ssh -p <PORT> <UUID>@<HOST>
Inside container, switch to admin

su - admin
Work in the venv (already in PATH)

pip install your-packages

---

## Validation Tests

All tests passed on **RTX 5090** with **CUDA 13.0** and **driver 580.82.09**:

After SSH into container

su - admin
✅ Test Chrome

google-chrome --version
google-chrome --headless --no-sandbox --dump-dom https://example.com
✅ Test PulseAudio

pulseaudio --check || pulseaudio --start
pulseaudio --check
✅ Test GPU

nvidia-smi
✅ Test Python venv

which pip
pip install selenium torch

---

## System Requirements

- **NVIDIA Driver**: 580.65.06+
- **Supported GPUs**: Blackwell (RTX 5090), Hopper (H100), Ada (RTX 4000), Ampere (RTX 3000)
- **Not Supported**: Maxwell, Pascal, Volta (CUDA 13 dropped support)

---

## Build Locally

git clone https://github.com/Schnicklfritz/Docker-Ubuntu-Nvidia.git
cd Docker-Ubuntu-Nvidia
docker build -t cuda-base:local .


---

## Extending This Image

FROM schnicklbob/cuda-desktop-base:latest

USER admin
WORKDIR /home/admin
Add your project-specific dependencies

RUN pip install transformers accelerate
Copy your code

COPY --chown=admin:admin . /home/admin/project

CMD ["python", "project/main.py"]

---

## Use Cases

- **Base for LLM projects**: Add transformers, vLLM
- **Base for web scraping**: Selenium already has Chrome
- **Base for audio AI**: TTS, STT with PulseAudio
- **Base for vision tasks**: Add OpenCV, PIL

---

## Installed Packages

**System:**
- openssh-server
- python3, python3-pip, python3-venv
- pulseaudio
- google-chrome-stable
- netcat-openbsd, wget, sudo

**Python:**
- pip (upgraded to latest)
- Virtual environment at `/home/admin/venv`

**Not included:**
- No CUDA development tools (nvcc)
- No Jupyter
- No GUI/desktop
- No specific ML frameworks (add in derived images)

---

## Evolution Strategy

This base will grow based on usage:
- Used in 2+ projects → Add to base
- Single-use dependency → Keep in derived image
- Breaking changes → New major version tag

---

## Size & Performance

- **Image size**: ~5GB (runtime vs ~8GB devel)
- **Startup**: <10 seconds on Quickpod
- **Memory**: Minimal overhead (~200MB)
- **Tested on**: NVIDIA RTX 5090, 32GB VRAM

---

## Project Structure

Docker-Ubuntu-Nvidia/
├── Dockerfile # Base image definition
├── scripts/
│ └── entrypoint.sh # Startup script
└── README.md # This file

---

## Troubleshooting

### Chrome issues

Always use these flags in headless mode

--headless --no-sandbox --disable-dev-shm-usage
dbus errors are expected and harmless in containers

### PulseAudio not running

pulseaudio --start --log-target=syslog
pulseaudio --check # Should return 0



### GPU not detected

nvidia-smi # Check driver version (need 580.65.06+)
Verify CUDA runtime

python -c "import subprocess; print(subprocess.run(['nvidia-smi', '--query-gpu=name', '--format=csv,noheader'], capture_output=True, text=True).stdout)"


### Need CUDA development tools?
Switch base image to `nvidia/cuda:13.0.1-devel-ubuntu24.04` in your Dockerfile.

---

## Contributing

This is a living base image. Submit PRs for:
- Common dependencies (used in 2+ projects)
- Security improvements
- Size optimization
- Bug fixes

**Not accepted:**
- Project-specific packages
- Breaking changes without version bump
- Bloated dependencies

---

## Versioning

- `latest`: Tracks current stable
- `13.0.1`: CUDA version pinned
- `13.0.1-v1`: Base image iteration

---

## License

MIT License

---

## Related

- [Docker Hub](https://hub.docker.com/r/schnicklbob/cuda-desktop-base)
- [GitHub](https://github.com/Schnicklfritz/Docker-Ubuntu-Nvidia)
- [Quickpod Docs](https://docs.quickpod.io)

---

════════════════════════════════════════════════════════════════════════════════
Crafted with precision by AI assistance | Base image - Extend - Deploy
════════════════════════════════════════════════════════════════════════════════


**Status**: Base image - extend for projects  
**CUDA**: 13.0.1 Runtime  
**OS**: Ubuntu 24.04 LTS  
**Platform**: Quickpod optimized  
**Validated**: RTX 5090, 32GB VRAM, Driver 580.82.09

