# AI Translation Base (Minimal GPU Setup)

Minimal Ubuntu 24.04 + CUDA 13.0.1 base, unminimized for tools, with SSH for access. Tailored for GPU-accelerated translation (en/hi/ne/ta) prototyping via sshuttle tunneling.

## Features
- Ubuntu 24.04 LTS, unminimized
- NVIDIA CUDA 13.0.1 runtime (x86_64)
- SSH on 22 (user: fritz, pw: fritz; sudo/GPU/audio perms)
- Optional PulseAudio for voice
- Python 3 ready for torch/transformers
- No GUI—use sshuttle for secure tunneling

## Usage
### Build/Push (via GitHub Actions)
- Commit/push to main: Auto-builds/pushes to Docker Hub (YOUR_USERNAME/ai-translation-base:latest).
- Manual: Repo > Actions > Build and Push > Run workflow.

### Run on QuickPod
- Template: Image YOUR_USERNAME/ai-translation-base:latest, expose 22, env SSH_PASSWORD=fritz or PUBLIC_KEY=your-pubkey.
- Pod: --gpus all equivalent (QuickPod handles), volumes /workspace for code.
- Tunnel: `sshuttle -r fritz@POD_IP 0/0` (or specific ports like 5000 for API).

### Access
- SSH: `ssh fritz@host -p 22` (install deps: `pip install torch --index-url https://download.pytorch.org/whl/cu121`).
- Test GPU: `python3 -c "import torch; print(torch.cuda.is_available())"`.
- Extend: Add Flask/Redis for cached translation API.

## GPU Support
QuickPod pods expose all GPUs; test with nvidia-smi over SSH.

## Contributing
Fork for variants (e.g., add XFCE/X2Go from old template for GUI).

## License
MIT License.

## Contact
Schnicklfritz@users.noreply.github.com
