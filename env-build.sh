#!/bin/bash
# env-build.sh - Build Environment Configuration and Validation

set -e

# Build configuration
export DOCKER_BUILDKIT=1
export BUILDKIT_PROGRESS=plain

# Image configuration
export BASE_IMAGE="nvidia/cuda:13.0.1-runtime-ubuntu24.04"
export IMAGE_NAME="cuda-desktop-base"
export IMAGE_TAG="13.0.1-ubuntu24.04"

# Build arguments (passed to Dockerfile)
export BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ')
export VCS_REF=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
export VERSION="1.0.0"

# Build-time package versions (for reproducible builds)
export XFCE_VERSION="4.18"
export OPENSSH_VERSION="8.9"
export PYTHON_VERSION="3.12"

# Validation checks
echo "=== Build Environment Validation ==="

# Check Docker version
if ! command -v docker &> /dev/null; then
    echo "ERROR: Docker not installed"
    exit 1
fi

DOCKER_VERSION=$(docker --version | cut -d' ' -f3 | cut -d',' -f1)
echo "Docker version: $DOCKER_VERSION"

# Check for NVIDIA Docker support
if ! docker run --rm --gpus all nvidia/cuda:13.0.1-base-ubuntu24.04 nvidia-smi &> /dev/null; then
    echo "WARNING: NVIDIA Docker support not available"
    echo "GPU features will be disabled in container"
fi

# Check available disk space (need ~4GB for build)
AVAILABLE_SPACE=$(df . | awk 'NR==2 {print $4}')
if [ $AVAILABLE_SPACE -lt 4000000 ]; then
    echo "WARNING: Less than 4GB disk space available"
fi

# Check for required files
REQUIRED_FILES=("Dockerfile" "scripts/entrypoint.sh" "scripts/setup-ssh.sh")
for file in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "$file" ]; then
        echo "ERROR: Required file missing: $file"
        exit 1
    fi
done

echo "=== Environment Variables Set ==="
echo "BASE_IMAGE: $BASE_IMAGE"
echo "IMAGE_NAME: $IMAGE_NAME"
echo "IMAGE_TAG: $IMAGE_TAG"
echo "BUILD_DATE: $BUILD_DATE"
echo "VCS_REF: $VCS_REF"
echo "VERSION: $VERSION"

echo "=== Ready for build ==="
echo "Run: source env-build.sh && ./build.sh"
