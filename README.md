# Minimal NVIDIA CUDA 13.0.1 Runtime Base Image

This repository contains a lightweight, headless Docker base image built on NVIDIA's official CUDA 13.0.1 runtime for Ubuntu 24.04 LTS. It's designed for GPU-accelerated compute tasks, such as AI/ML workflows (e.g., music generation with transformers, LLM inference), web scraping/automation via headless browser, and server-side applications. The image is strictly minimal—no GUI, desktop environments, or unnecessary bloat—to ensure fast builds (~1-2 minutes via GitHub Actions) and small size (~1.2 GB compressed). It includes a non-root user ("admin"), SSH access, a pre-configured Python 3.12 virtual environment (venv) for quick package installations, and headless Chromium for browser-based tasks common in LLMs or data collection.

This base serves as a foundation for specialized variants (e.g., music AI or LLM setups), allowing extensions with minimal changes (e.g., one `RUN` line for pip installs). All builds and pushes are handled via GitHub Actions—no local Docker required.

## Features
- **NVIDIA CUDA 13.0.1 Runtime**: Full GPU support (compute/utility capabilities) for PyTorch/TensorFlow/Transformers without development tools (saves ~1 GB).
- **Ubuntu 24.04 LTS Base**: Stable, non-interactive setup with locales (en_US.UTF-8) and tzdata for global compatibility.
- **User "admin"**: Non-root user with sudo privileges (password: "admin") for secure operations; home directory at `/home/admin` with pre-setup venv at `/home/admin/venv`.
- **SSH Server**: Enabled for remote access (port 22); simple authentication for development/pod testing.
- **Python 3.12 Ready**: Includes `python3`, `pip`, and `venv`—pip upgraded, ready for instant adds (e.g., `torch`, `transformers` for AI/music cascades).
- **Headless Chromium**: Included for browser automation (e.g., Selenium scraping for LLM data input)—runs without display via flags like `--headless --no-sandbox`.
- **Optimization**: No X11, audio, X2Go, or desktop packages; apt caches cleaned; multi-arch support (linux/amd64) via Actions.
- **Entrypoint Flexibility**: Starts SSH and executes passed commands—ideal for Actions testing or script runs.
- **Security**: Non-root default, sudo NOPASSWD for admin, minimal exposed ports.

Image tags: `:latest` (always current), `:<commit-sha>` (versioned).

## Prerequisites
- **Host Setup**: NVIDIA GPU with driver >= 535 (check: `nvidia-smi`). For runtime, install NVIDIA Container Toolkit (`nvidia-docker2` package).
- **GitHub**: Repo with Actions enabled; secrets for pushes:
  - `GITHUB_TOKEN`: Auto-generated (for GHCR).
  - `DOCKERHUB_USERNAME` and `DOCKERHUB_TOKEN`: For Docker Hub mirroring (optional).
- **Testing Environment**: Pod/VM with Docker >=24 and NVIDIA runtime (e.g., `docker run --gpus all ...`).
- **No Local Build**: All handled by GitHub Actions—commit to `main` or dispatch manually.

## Building and Pushing (GitHub Actions Only)
This repo uses `.github/workflows/publish.yml` for automated CI/CD:
- **Trigger**: Push to `main` or manual workflow dispatch (Actions tab > Run workflow).
- **Process**:
  1. Checks out code.
  2. Logs into GHCR (GitHub Container Registry).
  3. Builds with Docker Buildx (multi-platform: linux/amd64).
  4. Pushes tags to GHCR (e.g., `ghcr.io/yourusername/cuda-minimal:latest`).
  5. Mirrors to Docker Hub (e.g., `yourdhusername/cuda-minimal:latest`) with retries if secrets set.
- **Customization**: Edit `IMAGE_NAME` in publish.yml (default: "cuda-minimal"). Add platforms (e.g., `linux/arm64`) for ARM support.
- **Monitor**: View logs in Actions tab. Build time: ~1-2 mins on GitHub runners.
- **Example Output**: After push, pull from `docker pull ghcr.io/yourusername/cuda-minimal:latest` (or Docker Hub equivalent).

To extend for a variant repo (e.g., music AI):
1. Create new repo (e.g., "cuda-music-variant").
2. Copy Dockerfile, entrypoint.sh, and publish.yml.
3. Add extensions (see below).
4. Commit to `main`—Actions handles the rest.

## Usage
### Pulling and Running
Pull from registry (post-Actions build):
```
# GHCR (primary)
docker pull ghcr.io/yourusername/cuda-minimal:latest

# Docker Hub (mirrored)
docker pull yourdhusername/cuda-minimal:latest
```

Run examples (use `--gpus all` for CUDA):
- **Interactive Shell** (as admin):
  ```
  docker run -it --gpus all -p 2222:22 --name cuda-test cuda-minimal:latest /bin/bash
  ```
  - Inside: `sudo su -` if root needed; password "admin".
- **SSH Access** (remote):
  ```
  docker run -d --gpus all -p 2222:22 cuda-minimal:latest
  ssh admin@localhost -p 2222  # Password: admin
  ```
- **Python Test** (headless compute):
  ```
  docker run --rm --gpus all cuda-minimal:latest python3 -c "import sys; print('Python:', sys.version); from venv import create; create('/tmp/test')"; echo 'Venv ready'"
  ```
- **CUDA Verification**:
  ```
  docker run --rm --gpus all cuda-minimal:latest nvidia-smi  # Shows GPU
  docker run --rm --gpus all cuda-minimal:latest python3 -c "import os; print('CUDA_VISIBLE_DEVICES:', os.environ['CUDA_VISIBLE_DEVICES'])"
  ```

### Headless Browser Usage
Chromium is pre-installed for tasks like web data for LLMs (e.g., scrape music lyrics).
- **Basic Headless Run**:
  ```
  docker run --rm cuda-minimal:latest chromium-browser --headless --no-sandbox --dump-dom https://example.com
  ```
  - Outputs HTML—pipe to file: `... > output.html`.
- **With Python/Selenium** (extend venv first, see Customization):
  ```
  # Example script in container
  python3 -c "
  from selenium import webdriver
  from selenium.webdriver.chrome.options import Options
  options = Options()
  options.add_argument('--headless')
  options.add_argument('--no-sandbox')
  driver = webdriver.Chrome(options=options)
  driver.get('https://perplexity.ai')
  print(driver.title)
  driver.quit()
  "
  ```
- **For LLMs**: Scrape sites to feed data (e.g., BeautifulSoup parse for prompts). Install: `/home/admin/venv/bin/pip install selenium beautifulsoup4` (~20s).

### SSH and Remote Development
- Default: Port 2222 mapped; user "admin"/"admin".
- In pod/VM: Use for iterative adds (e.g., pip installs, script runs) without rebuilding.
- Security Note: Change password in Dockerfile (`echo "admin:newpass" | chpasswd`) and rebuild for production.

## Customization (Minimal Time Adds)
Extend this base for specific tasks—additions take <1 min in Dockerfile, <2 mins build via Actions.
- **Python Packages** (e.g., for music AI/LLMs):
  ```
  # In Dockerfile, after USER admin block
  RUN /home/admin/venv/bin/pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121 \
    transformers librosa soundfile mido pretty_midi openai langchain selenium beautifulsoup4
  ```
  - For cascades/mashups: Includes MusicGen deps.
  - For LLMs: `openai` + `langchain` for API/chains; browser feeds web data.
- **Other Tools** (e.g., Git, htop already in; add Jupyter for notebook):
  ```
  # Root RUN (before USER admin)
  RUN apt-get update && apt-get install -y --no-install-recommends \
    jupyterlab \
    && rm -rf /var/lib/apt/lists/*
  RUN /home/admin/venv/bin/pip install jupyter
  ```
- **Entrypoint Override** (for specific runs):
  ```
  docker run --gpus all -p 8888:8888 cuda-minimal:latest jupyter lab --ip=0.0.0.0 --no-browser --allow-root
  ```
- **Variant Repos**: Copy base files to new repo, add RUN lines, commit—Actions pushes new image (e.g., "cuda-llm:latest").

Build delta: Each pip/apt add ~30s-1min; cache in Actions speeds repeats.

## Repository Structure
```
.
├── Dockerfile          # Core build script (minimal CUDA base + admin user + Chromium)
├── entrypoint.sh       # Startup: SSH + exec
├── .github/
│   └── workflows/
│       └── publish.yml # GitHub Actions: Build/push to GHCR + Docker Hub mirror
├── README.md           # This file
└── .gitignore          # (Optional: Ignore .DS_Store, etc.)
```
- Commit changes to `main` for auto-build.
- For multi-image: Separate repos per variant (e.g., "cuda-music", "cuda-llm").

## Troubleshooting
- **Actions Failures**:
  - "No GPU in runner": GitHub runners don't have NVIDIA; test pulls on GPU host/pod.
  - "Login Error": Verify secrets in repo Settings > Secrets > Actions.
  - "Build Timeout": Add `cache-from` in publish.yml for faster layers.
- **Runtime Issues**:
  - CUDA Not Detected: Ensure `--gpus all` and host driver >=535 (`nvidia-smi` on host).
  - SSH Fails: Check port mapping; default password "admin"—change via Dockerfile.
  - Chromium Crashes: Use `--no-sandbox --disable-dev-shm-usage` flags; for Selenium, add `options.add_argument('--disable-gpu')`.
  - Venv Not Found: `source /home/admin/venv/bin/activate` or use full path.
- **Size Bloat**: If >1.5 GB, remove Chromium (`apt remove chromium-browser`) and rebuild.
- **Logs**: Actions > Workflow runs; container: `docker logs <container-id>`.

## License
MIT License—free for use/modification. Based on NVIDIA's Apache 2.0 CUDA images. No warranties; test in your environment.

For questions/extensions (e.g., LLM-specific adds), open an issue or reference in commits. Pull and extend for your music/AI cascades!
