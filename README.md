## About The Project

terraform-kind is a Terraform based provisioner of [kind](https://kind.sigs.k8s.io/docs/user/quick-start/) deployments on various clouds.

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

1. Create an environment:
```sh
$ mkdir -p environment/gcp && cd environment/gcp
```
2. Create a configuration called i.e. `main.tf`:
```sh
module "platform" {
  source = "../../platforms/debian_gcp"

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

3. Run terraform
```sh
$ cd environment/gcp
$ terraform init
$ terraform apply
```

4. Create an SSH tunnel
```sh
$ cd environment/gcp
$ ./tunnel_kind.sh 
Warning: Permanently added '...' (ED25519) to the list of known hosts.
```

5. Configure `KUBECONFIG`
```sh
$ cd environment/gcp
$ export KUBECONFIG=$PWD/kubeconfig
$ kubectl get pod -A
NAMESPACE            NAME                                         READY   STATUS    RESTARTS   AGE
kube-system          coredns-558bd4d5db-mb9sm                     1/1     Running   0          69m
kube-system          coredns-558bd4d5db-r795g                     1/1     Running   0          69m
kube-system          etcd-kind-control-plane                      1/1     Running   0          69m
kube-system          kindnet-psvpr                                1/1     Running   0          69m
kube-system          kube-apiserver-kind-control-plane            1/1     Running   0          69m
kube-system          kube-controller-manager-kind-control-plane   1/1     Running   0          69m
kube-system          kube-proxy-rvpns                             1/1     Running   0          69m
kube-system          kube-scheduler-kind-control-plane            1/1     Running   0          69m
local-path-storage   local-path-provisioner-547f784dff-kxfgl      1/1     Running   0          69m
```

### Optional modules

#### podman

The `podman` module provisions a local podman remote connection to the provisioned host. Add the following into `main.tf`:

```
module "podman" {
  source = "../../modules/podman"

  triggers = {
    machine = module.platform.machine_name
  }

  remote_ip = module.platform.public_ip
}
```

Once the machine is provisioned the local system connection list should have the following entry:
```
$ podman --remote system connection list
Name                     Identity    URI
tf-6170853756317469531*              ssh://core@11.22.33.44:22/run/user/1000/podman/podman.sock
```

**Prerequisites**:
- You need to have `podman` locally installed.
- The referenced platform module must ensure podman is installed on the remote machine.

### Troubleshooting

#### Unable to connect via ssh

In case terraform is not able to provision via ssh make sure you have an SSH agent running or simply execute:

```sh
$ ssh-add
```

If the connection still fails, verify that your local ssh key algorithm is accepted by the server.
Check the server sshd logs for details.
