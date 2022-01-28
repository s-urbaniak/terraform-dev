## About The Project

`terraform-dev` is a Terraform based tool to install development machines on various clouds.

Currently, the following cloud platforms are supported:

* GCP
* Hetzner Cloud

## Getting Started

### Prerequisites

You need to have [terraform](https://www.terraform.io/) installed.

#### GCP

GCP credentials must be available in the environment, see https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/provider_reference#full-reference for details.

#### Hetzner Cloud

A Heztner Cloud API token must be available in the environment, see https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs#argument-reference for details.

### Usage

1. Create a configuration:
```sh
$ mkdir dev-gcp && cd dev-gcp
module "platform" {
  source = "git::https://github.com/s-urbaniak/terraform-dev//platforms/gcp_rocky"

  project      = "gce-project"
  region       = "europe-west2"
  zone         = "europe-west2-a"

  machine_prefix = "foo"
  username       = "foo"

  ssh_keys = [
    {
      user : "foo",
      publickey : "ssh-rsa YOUR-PUBLIC-KEY",
    },
  ]
}
```

Inspect `variables.tf` for variables of the provisioned platform for possible settings.

2. Run terraform
```sh
$ terraform init
$ terraform apply
```

### Optional modules

#### podman

The `podman` module provisions a local podman remote connection to the provisioned host.
Add the following to `main.tf`:

```
module "platform" {
  source = "git::https://github.com/s-urbaniak/terraform-dev//platforms/<your_preferred platform>"
...
  enable_podman = true
}
```

Once the machine is provisioned the local system connection list should have a remote entry:
```
$ podman --remote system connection list
Name                     Identity    URI
tf-6170853756317469531*              ssh://core@11.22.33.44:22/run/podman/podman.sock
```

**Prerequisites**:
`podman` must be locally installed, see https://podman.io/.

#### file sync

The `mutagen` module provisions a local mutagen file sync session pointing to the provisioned host.
Add the following to `main.tf`:

```
module "platform" {
  source = "git::https://github.com/s-urbaniak/terraform-dev//platforms/<your_preferred platform>"
...
  enable_mutagen = true
  sync_paths = [
    "/home/user/src/foo/bar",
  ]
}
```

Once the machine is provisioned the local mutagen sync session list should have a remote entry:
```
$ mutagen sync list
--------------------------------------------------------------------------------
Name: tf-7048997643480967595
Identifier: sync_RzC4Ik9rwnB1JkOzaFmRflbWyPpdH3JF1uLSY7ix4ni
Labels: None
Alpha:
	URL: /home/user/src/foo/bar
	Connection state: Connected
Beta:
	URL: core@11.22.33.44:/home/user/src/foo/bar
	Connection state: Connected
Status: Watching for changes
--------------------------------------------------------------------------------
```

*Note*: Additional entries can be added or removed while the host is provisioned.
Using `terraform apply` changes will be applied.
If a sync path entry is removed, the local mutagen sync sessions will be removed.
Conversely, if a sync path entry is added, a local mutagen sync session will be added.

**Prerequisites**:
`mutagen` must be locally installed, see https://mutagen.io/.

#### kind

The `kind` module provisions a kubernetes development cluster to the provisioned host using kind.
Add the following to `main.tf`:

```
module "platform" {
  source = "git::https://github.com/s-urbaniak/terraform-dev//platforms/<your_preferred platform>"
...
  enable_kind = true
}
```

##### Connecting via ssh

Once the machine is provisioned, `tunnel.sh` can be used to connect to the remote cluster.
```
$ ./tunnel.sh
Warning: Permanently added '11.22.33.44' (ED25519) to the list of known hosts.

$ export KUBECONFIG=$PWD/kubeconfig

$ kubectl get pod -A
NAMESPACE            NAME                                         READY   STATUS    RESTARTS   AGE
kube-system          coredns-558bd4d5db-285mn                     1/1     Running   0          7m11s
kube-system          coredns-558bd4d5db-hmnnd                     1/1     Running   0          7m11s
kube-system          etcd-kind-control-plane                      1/1     Running   0          7m19s
kube-system          kindnet-8pwc2                                1/1     Running   0          7m11s
kube-system          kube-apiserver-kind-control-plane            1/1     Running   0          7m19s
kube-system          kube-controller-manager-kind-control-plane   1/1     Running   0          7m19s
kube-system          kube-proxy-rswb2                             1/1     Running   0          7m11s
kube-system          kube-scheduler-kind-control-plane            1/1     Running   0          7m19s
local-path-storage   local-path-provisioner-547f784dff-857z7      1/1     Running   0          7m11s
```

##### Connecting via wireguard VPN

An alternative way of connecting is via WireGuard/VPN. Here, the `wireguard` module must be enabled
and kind needs to be configured to listen to the WireGuard server IP:

```
module "platform" {
  source = "git::https://github.com/s-urbaniak/terraform-dev//platforms/<your_preferred platform>"
...
  enable_kind          = true

  kind_config          = <<EOF
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
networking:
  apiServerAddress: "192.168.71.1"
  EOF

  enable_wiregard = true
}
```

After provisioning, the cluster can be reached as follows:

```
$ sudo wg-quick up $PWD/wg0_0.conf
Warning: `/Users/surbania/src/terraform-dev/environment/gcp/wg0_0.conf' is world accessible
[#] wireguard-go utun
[+] Interface for wg0_0 is utun5
[#] wg setconf utun5 /dev/fd/63
[#] ifconfig utun5 inet 192.168.71.2/24 192.168.71.2 alias
[#] ifconfig utun5 up
[#] route -q -n add -inet 192.168.71.0/24 -interface utun5
[+] Backgrounding route monitor

$ export KUBECONFIG=$PWD/kubeconfig

$ kubectl get pod -A
NAMESPACE            NAME                                         READY   STATUS    RESTARTS   AGE
kube-system          coredns-64897985d-rqcqv                      1/1     Running   0          3m56s
kube-system          coredns-64897985d-v6kch                      1/1     Running   0          3m56s
kube-system          etcd-kind-control-plane                      1/1     Running   0          4m11s
kube-system          kindnet-8582s                                1/1     Running   0          3m56s
kube-system          kube-apiserver-kind-control-plane            1/1     Running   0          4m11s
kube-system          kube-controller-manager-kind-control-plane   1/1     Running   0          4m11s
kube-system          kube-proxy-txgtk                             1/1     Running   0          3m56s
kube-system          kube-scheduler-kind-control-plane            1/1     Running   0          4m11s
local-path-storage   local-path-provisioner-5bb5788f44-5nszq      1/1     Running   0          3m56s
```

##### Specifying the kind version

To specify the version of `kind`, configure the `kind_version` variable:

```
module "platform" {
  source = "git::https://github.com/s-urbaniak/terraform-dev//platforms/<your_preferred platform>"
...
  enable_kind = true
  kind_version = "v0.11.1"
}
```

##### cluster creation command line options

To specify command line options, configure the `kind_startup_options` variable.
These will be appended to the `kind create cluster` command:

```
module "platform" {
  source = "git::https://github.com/s-urbaniak/terraform-dev//platforms/<your_preferred platform>"
...
  enable_kind = true
  kind_startup_options = "--image=kindest/node:v1.23.0"
}
```

##### kind configuration

Additional configuration for `kind` can be declared using the `kind_config` variable, example:

```
module "platform" {
  source = "git::https://github.com/s-urbaniak/terraform-dev//platforms/<your_preferred platform>"
...

  enable_kind = true
  kind_config          = <<EOF
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
runtimeConfig:
  "api/alpha": "false"
  EOF
}
```

#### wireguard

The `wireguard` module provisions a remote wireguard server and a local wireguard client configuration.
Add the following to `main.tf`:

```
module "platform" {
  source = "git::https://github.com/s-urbaniak/terraform-dev//platforms/<your_preferred platform>"
...
  enable_wireguard = true
}
```

Once the machine is provisioned the VPN tunnel can be started as follows:
```
$ sudo wg-quick up $PWD/wg0_0.conf
[#] ip link add wg0_0 type wireguard
[#] wg setconf wg0_0 /dev/fd/63
[#] ip -4 address add 192.168.71.2/24 dev wg0_0
[#] ip link set mtu 1420 up dev wg0_0
$ sudo wg show
interface: wg0_0
  public key: ...
  private key: (hidden)
  listening port: 55676

peer: ...
  preshared key: (hidden)
  endpoint: 11.22.33.44:51820
  allowed ips: 192.168.71.0/24
  latest handshake: 3 seconds ago
  transfer: 92 B received, 180 B sent
  persistent keepalive: every 25 seconds
```

The VPN IP subnet is `192.168.71.0/24`. The development remote server is reachable at `192.168.71.1`
while the local machine is reachable at `192.168.71.2`.

**Prerequisites**:
`wireguard` must be locally installed, see https://www.wireguard.com/.

### Troubleshooting

#### Unable to connect via ssh

In case terraform is not able to provision via ssh make sure you have an SSH agent running or simply execute:

```sh
$ ssh-add
```

If the connection still fails, verify that your local ssh key algorithm is accepted by the server.
Check the server sshd logs for details.
