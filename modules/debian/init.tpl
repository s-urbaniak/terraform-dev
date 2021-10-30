DEBIAN_FRONTEND=noninteractive sudo apt-get update
DEBIAN_FRONTEND=noninteractive sudo apt-get -y install docker.io
curl -OL# ${kind_url}
sudo mv kind* /usr/bin/kind
sudo chmod +x /usr/bin/kind
sudo kind create cluster
sudo cp /root/.kube/config kubeconfig
sudo chown ${username}:${username} kubeconfig