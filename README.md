# CUDA Desktop Base Image

Production-ready NVIDIA CUDA development environment optimized for Quickpod deployment. Provides a minimal, secure Ubuntu-based container with GPU support, SSH access, and Python development tools.

## Features

- **NVIDIA CUDA Support**: Multiple CUDA versions (11.8, 12.4, 12.6) with cuDNN
- **SSH Access**: Secure remote access via Quickpod's authentication system
- **Python Environment**: Pre-configured with virtual environment and modern tooling
- **Development Tools**: Git, vim, build tools, FFmpeg with hardware acceleration
- **Optimized Memory**: TCMalloc for improved performance
- **Clean & Minimal**: No GUI bloat, focused on compute workloads

## Quick Start

### Deploy to Quickpod

1. Use Docker Hub image: `schnicklbob/cuda-desktop-base:latest`
2. Connect via Quickpod-provided SSH credentials
3. Start developing immediately

### SSH Access

