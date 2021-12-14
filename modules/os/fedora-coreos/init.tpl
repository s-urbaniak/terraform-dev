curl -OL# ${kind_url}
mv kind* kind
chmod +x kind
sudo ./kind create cluster
sudo cp /root/.kube/config kubeconfig
sudo chown ${username}:${username} kubeconfig
systemctl --user enable --now podman.socket
