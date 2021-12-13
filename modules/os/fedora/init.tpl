sudo dnf -y install moby-engine podman
systemctl enable dockers
systemctl start docker
curl -OL# ${kind_url}
sudo mv kind* /usr/bin/kind
sudo chmod +x /usr/bin/kind
sudo kind create cluster
sudo cp /root/.kube/config kubeconfig
sudo chown ${username}:${username} kubeconfig