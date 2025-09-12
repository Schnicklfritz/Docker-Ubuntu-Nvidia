#!/bin/bash

# Start PulseAudio (user mode)
pulseaudio --start

# Start SSH daemon
/usr/sbin/sshd -D

