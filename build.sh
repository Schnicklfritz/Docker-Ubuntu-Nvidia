#!/bin/bash
# build.sh - Docker Image Build Script

set -e

# Source build environment
if [ ! -f "env-build.sh" ]; then
    echo "ERROR: env-build.sh not found"
    exit 1
fi

source env-build.sh

echo "Building ${IMAGE_NAME}:${IMAGE_TAG}..."

# Build with all build args
docker build \
    --build-arg BASE_IMAGE="$BASE_IMAGE" \
    --build-arg BUILD_DATE="$BUILD_DATE" \
    --build-arg VCS_REF="$VCS_REF" \
    --build-arg VERSION="$VERSION" \
    --build-arg XFCE_VERSION="$XFCE_VERSION" \
    --build-arg PYTHON_VERSION="$PYTHON_VERSION" \
    --tag ${IMAGE_NAME}:${IMAGE_TAG} \
    --tag ${IMAGE_NAME}:latest \
    --tag ${IMAGE_NAME}:${VCS_REF} \
    .

echo "Build complete!"
echo "Image: ${IMAGE_NAME}:${IMAGE_TAG}"
echo "Size: $(docker images ${IMAGE_NAME}:${IMAGE_TAG} --format "table {{.Size}}" | tail -n1)"
echo ""
echo "Test run: docker-compose up -d"
