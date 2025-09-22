#!/bin/bash

# Start PulseAudio in user mode
pulseaudio --start

# Execute optional setup script if exists
if [ -x /home/user/scripts/setup_env.sh ]; then
  /home/user/scripts/setup_env.sh
fi

# Start SSH daemon in foreground
/usr/sbin/sshd -D
