# timedrop
Timedrop is a microservice that serves up JSON data containing locations and time zone information through a HTTP rest point.

## PREREQUISITES
- **nginx** is required to be installed if using the RPM package.
- **docker** (podman) is required if using the CONTAINER image locally.
- **kubernetes** is required if you wanted to use the .yaml files.

## INSTALLATION
There are two ways this package is installed:

1) RPM

`yum install -y timedrop-1.1.4-1.el7.x86_64.rpm`

The application runs as a systemd service and listens on localhost:9987.

To be externally accesible, nginx must be installed and is accessible through http://ip-address/time

2) CONTAINER

### Docker (podman)

I. `docker pull ghcr.io/erock530/timedrop:1.1.4`

II. `podman images | grep timedrop`

III. `podman run -d -p 8080:9987 --name timedrop-svc POD_ID_FROM_PREVIOUS_COMMAND`

The pod can be accessed via `curl http://localhost:8080`

### Kubernetes

Edit kubernetes/service.yml file and make sure an external IP address is configured for externalIPs.

I. `kubectl create namespace timedrop`

II. `kubectl create -f kubernetes/deployment.yml -n timedrop`

III. `kubectl create -f kubernetes/service.yml -n timedrop`


You can verify the service is configured:

`kubectl get services -n timedrop`

The pod can be accessed via `curl http://IP`

## TROUBLESHOOTING

Not working correctly? Check the pod logs:

Docker (podman):

I. `podman container list | grep timedrop`

II. `podman container logs POD_ID_FROM_PREVIOUS_COMMAND`

Kubernetes:

I. `kubectl get pods -n timedrop`

II. `kubectl logs A_POD_ID_FROM_PREVIOUS_COMMAND -n timedrop`

