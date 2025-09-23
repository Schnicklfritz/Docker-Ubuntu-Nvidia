#!/bin/bash
# GPU and CUDA environment setup
export NVIDIA_VISIBLE_DEVICES=all
export NVIDIA_DRIVER_CAPABILITIES=compute,utility,display
export DISPLAY=${DISPLAY:-:0}

# Python environment
export PYTHONPATH=/workspace:$PYTHONPATH
export PATH=/home/user/.local/bin:$PATH

echo "=== Environment Configured ==="
nvidia-smi 2>/dev/null || echo "GPU not available"
