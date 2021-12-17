sudo dnf -y install moby-engine podman wireguard-tools
systemctl enable --now podman
systemctl enable --now docker
curl -OL# ${kind_url}
sudo mv kind* /usr/bin/kind
sudo chmod +x /usr/bin/kind
sudo kind create cluster
sudo cp /root/.kube/config kubeconfig
sudo chown ${username}:${username} kubeconfig