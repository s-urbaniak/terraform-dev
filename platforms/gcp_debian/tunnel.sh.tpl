#!/bin/sh
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -N -L ${port}:127.0.0.1:${port} ${username}@${public_ip}
