#!/usr/bin/env bash

ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -N -L "16443:${public_ip}:16443" "$@" ${username}@${public_ip}
