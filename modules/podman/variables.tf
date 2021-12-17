variable triggers {
    type = map
}

variable remote_ip {
    type = string
}

variable podman_socket {
    type = string
    default = "/run/user/1000/podman/podman.sock"
}

variable username {
    type = string
}