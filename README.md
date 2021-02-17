# Kinto Helm Chart

## Prerequisites Details

- `Kubernetes 1.15+`

## Chart Details

The chart will do the following:

- Deploy [Kinto Dashboard](https://github.com/kintoproj/kinto-dashboard)
- Deploy [Kinto Core](https://github.com/kintoproj/kinto-core)
- Deploy [Kinto Builder](https://github.com/kintoproj/kinto-builder)
- Deploy [Nginx Ingress Controller](https://github.com/bitnami/charts/tree/master/bitnami/nginx-ingress-controller)
- Deploy [Proxless](https://github.com/bappr/proxless)
- Deploy [Minio](https://github.com/minio/charts)

## Installing the chart

### Prerequisites

- [Cert Manager](https://cert-manager.io/docs/) and [Argo Workflow](https://github.com/argoproj/argo-workflows) are cluster wide (they operate at a cluster level) and they have their own sets of Custom Resource Definition.  
If you already have your own versions of these tools running on your Kubernetes Cluster, don't run the commands below but go straight to [Install KintoHub](#install-kintohub). If KintoHub does not work with the version you installed, please create an issue.
Notes: KintoHub has been test with cert-manager v0.15.0 and argo workflow 0.9.5.
- You must have a domain name ready to be used. KintoHub only support Cloudflare at the moment, you can create a free account and transfer your domain ownership easily. Please create an issue if you want to add more.
- KintoHub does not support its private docker registry yet. You must use an external one (docker hub, gcr, ecr, acr, etc.).
- You must have [Helm](https://helm.sh/) (v3.0 or above) installed. Cert Manager/Argo/Kintohub are all installed via Helm Charts.
- Kubernetes cluster with at least a node having 4GB or more memory

#### Install Cert-Manager

Run

```sh
kubectl create namespace cert-manager
helm repo add jetstack https://charts.jetstack.io
helm upgrade --install cert-manager \
              --version v0.15.0 \
              --set installCRDs=true \
              --namespace cert-manager jetstack/cert-manager
```

Check cert-manager is running fine.

Run

```sh
kubectl get pods -n cert-manager
```

and you should get something similar to

```sh
NAME                                       READY   STATUS    RESTARTS   AGE
cert-manager-766d5c494b-wl4bq              1/1     Running   0          33s
cert-manager-cainjector-6649bbb695-l5rb2   1/1     Running   0          33s
cert-manager-webhook-68d464c8b-hvpf6       1/1     Running   0          33s
```

#### Install Argo Workflow

Run

```sh
kubectl create namespace argo
helm repo add argo https://argoproj.github.io/argo-helm
helm upgrade --install argo \
              --version 0.9.5 \
              --set installCRD=true \
              --set singleNamespace=false \
              --set useDefaultArtifactRepo=true \
              --set artifactRepository.archiveLogs=true \
              --set artifactRepository.s3.accessKeySecret.name=kinto-minio \
              --set artifactRepository.s3.accessKeySecret.key=accesskey \
              --set artifactRepository.s3.secretKeySecret.name=kinto-minio \
              --set artifactRepository.s3.secretKeySecret.key=secretkey \
              --set artifactRepository.s3.insecure=true \
              --set artifactRepository.s3.bucket=argo-artifacts \
              --set artifactRepository.s3.endpoint=kinto-minio:9000 \
              --set artifactRepository.minio.install=false \
              --namespace argo argo/argo
```

Check argo is running fine.

Run

```sh
kubectl get pods -n argo
```

and you should get something similar to

```sh
NAME                                       READY   STATUS    RESTARTS   AGE
argo-server-7869fd4b96-xn8gw               1/1     Running   0          62s
argo-workflow-controller-b68ffccb5-jx7vq   1/1     Running   0          62s
```

### Install KintoHub

Check out this repository and adapt the [values.yaml](./values.yaml) file accordingly for your own need.
Checks specifically for any `## TO BE CHANGED` pattern in it and change the values.
Notes: you can also provide the parameters directly into the command line using `--set`.

Run

```sh
# Check out the repository and edit the values.yaml
git clone https://github.com/kintoproj/kinto-helm.git
vi values.yaml

# install the chart via helm, it will take the values from values.yaml automatically
kubectl create ns kintohub
helm upgrade --install kinto --namespace kintohub .
```

Check kintohub is running fine.

Run

```sh
kubectl get pods -n kintohub
```

and you should get something similar to

```sh
NAME                                                              READY   STATUS    RESTARTS   AGE
kinto-builder-64cb848858-vjwp8                                    1/1     Running   0          56s
kinto-core-7f9b8777c9-pwfv7                                       1/1     Running   0          56s
kinto-dashboard-645776fc5b-mj2xz                                  1/1     Running   0          56s
kinto-minio-5fdd9859bd-x5g7n                                      1/1     Running   0          56s
kinto-nginx-ingress-controller-5774d868cb-mcktf                   1/1     Running   0          56s
kinto-nginx-ingress-controller-default-backend-66549b79f8-7cmtx   1/1     Running   0          56s
kinto-proxless-65487b797c-jf7cd                                   1/1     Running   0          56s
```

#### DNS Setup

Get and save the IP of the nginx-ingress-controller.
Get and save your ingresses domain names.

```sh
kubectl get service kinto-nginx-ingress-controller -n kintohub -o jsonpath="{.status.loadBalancer.ingress[0].ip}"
34.105.245.209

kubectl get ingress -n kintohub
NAME                  HOSTS                   ADDRESS       PORTS     AGE
kinto-core-grpc       core.kintohub.net       34.89.73.47   80, 443   8m38s
kinto-core-grpc-web   core-web.kintohub.net   34.89.73.47   80, 443   8m38s
kinto-dashboard       dashboard.kintohub.net  34.89.73.47   80, 443   8m38s
```

Access your DNS provider (cloudflare) and create a `HOST A` record for each of the above ingresses targetting the nginx-ingress-controller IP.
**DO NOT** turn on DNS Proxy on cloudflare for every HOST A record.
And create an additional wildcard one corresponding to `common.ssl.certificate.dnsName`.

ie:

```txt
core.kintohub.net      HOST A 34.105.245.209
core-web.kintohub.net  HOST A 34.105.245.209
dashboard.kintohub.net HOST A 34.105.245.209
*.kintohub.net         HOST A 34.105.245.209
```

#### Access KintoHub

And that's it.
You can now open your URL (dashboard.kintohub.net) on your prefered browser and start using KintoHub.

## Uninstall the chart

```sh
helm uninstall kinto --namespace kintohub
kubectl delete ns kintohub
```

Notes: you can use the same command to uninstall argo and cert-manager too.

## Meta

[https://www.kintohub.com](https://www.kintohub.com)
