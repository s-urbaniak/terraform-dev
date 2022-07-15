#!/usr/bin/env bash

PORT=$(ssh \
    -o StrictHostKeyChecking=no \
    -o UserKnownHostsFile=/dev/null \
    ${username}@${public_ip} \
    "sudo sh -c '/usr/local/bin/kind get kubeconfig | grep server | cut -d: -f4'"
)

ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -N -L "$${PORT}":127.0.0.1:"$${PORT}" "$@" ${username}@${public_ip}
