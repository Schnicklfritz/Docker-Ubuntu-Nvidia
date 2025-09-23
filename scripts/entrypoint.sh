#!/bin/bash

pulseaudio --start

if [ -x /home/user/scripts/setup_env.sh ]; then
  /home/user/scripts/setup_env.sh
fi

/usr/sbin/sshd -D
