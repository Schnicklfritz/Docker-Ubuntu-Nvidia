#!/bin/bash
# Example interactive hardware or environment configuration script

echo "Configuring environment variables for optimal container runtime..."

# Example: Detect number of CPU cores and set environment variable
CPU_CORES=$(nproc)
echo "Detected CPU cores: $CPU_CORES"

# Export environment variables (adjust as needed)
export CONTAINER_CPU_CORES=$CPU_CORES

# Set DISPLAY for GUI apps if not already set
if [ -z "$DISPLAY" ]; then
  export DISPLAY=:0
  echo "DISPLAY not set, defaulting to :0"
fi

# You can add GPU detection or other settings here as needed

echo "Environment configuration complete."
