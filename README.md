# Kinto Kube Infra

> Contains all the infrastructure required components to run KintoHub.

## Requirements

- `kubectl`
- `helm`

- `Kubernetes 1.15+`

## Install

```sh
kubectl create ns kintohub
helm template kinto --include-crds --namespace kintohub . | kubectl apply -f -
```

## Uninstall

```sh
helm template kinto --include-crds --namespace kintohub . | kubectl delete -f -
kubectl delete ns kintohub
```

## Meta

[https://www.kintohub.com](https://www.kintohub.com)
