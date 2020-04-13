# pusher/wave secret deletion bug

This repository contains a number of test cases for an apparent race condition
in pusher/wave where secrets are occasionally deleted during
`kubectl apply --prune`.

The [`test.sh`](./test.sh) script contains the base test case: it creates a
unique deployment and secret combination from a template, applies it to the
cluster, waits, and reapplies the template without the deployment, causing a
prune.

[`test-serial.sh`](./test-serial.sh) simply runs `test.sh` 20 times or until it
fails.

[`test-parallel.sh`](./test-parallel.sh) runs many instances of `test.sh` in
parallel (configurable, 25 by default). We could never trigger the bug with this
script, even running it serially.

[`stress.yaml`](./stress.yaml) can be deployed to saturate the cluster CPU. This
seems to improve reproducibility (see below).

[`wave.yaml`](./wave.yaml) is the latest Wave configuration from the master
branch, generated using `kubectl customize` with no overrides. It applies
cleanly to most recent Kubernetes distributions, including minikube running
Kubernetes v1.18.

## Usage

 1. Create an empty Kubernetes cluster, e.g. minikube.
 2. Run [`test-serial.sh`](./test-serial.sh). If desired, set `$NAMESPACE`,
    `$NAME`, or other environment variables listed in the scripts. By default
    it repeatedly creates and deletes a deployment/secret named `test` in the
    namespace `default`.

## Observations

We've been able to replicate this across multiple versions of Kubernetes (v1.14,
v1.18), multiple versions of `kubectl`, multiple Kubernetes distributions 
(Amazon EKS, minikube), and recent versions of pusher/wave (v0.4.0, latest
master).

Reproducibility varies between environments: 

 * On our production clusters, running EKS 1.14 with ~10 m5.large nodes, each
   under ~20% CPU and memory load, the secret is deleted almost every time. We
   have roughly 20 services being watched by Wave at any given time.
 * On an otherwise empty EKS cluster running 1.14 with 3 t3a.medium nodes, it
   takes about 20 attempts to delete the secret.
 * On a fresh single-node minikube VM running 1.18, it takes around 30 attempts
   to reproduce. The [`stress.yaml`](./stress.yaml) deployment saturates 2 CPUs
   and improves reproduction rates to around 1 in 5.
