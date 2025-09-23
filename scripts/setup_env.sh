#!/bin/bash

echo "Configuring container environment..."

CPU_CORES=$(nproc)
echo "Detected CPU cores: $CPU_CORES"

export CONTAINER_CPU_CORES=$CPU_CORES

if [ -z "$DISPLAY" ]; then
  export DISPLAY=:0
  echo "DISPLAY not set; defaulted to :0"
fi

echo "Environment configuration done."
