# CKAD Practice Setup

This folder contains a Kubernetes practice environment for CKAD-style tasks. The main manifest creates a set of namespaces and starter resources for multiple questions, and the verification script checks whether the expected fixes have been completed.

## What Is Included

- `setup-ckad-practice.yaml` - Creates the practice resources across namespaces `q1` through `q16`.
- `verify-ckad.sh` - Runs checks against the cluster and reports pass/fail status for each question.
- `Dockerfile` - Used for the local image build practice task.
- `broken-deploy.yaml`, `pod.yaml`, `ingress.yaml`, `ingres.yaml`, and `fix-ingress.yaml` - Supporting YAML files for individual Kubernetes practice scenarios.
- `instructionsToRun.txt` - Short command reference for applying and deleting the setup.

The practice scenarios cover common CKAD topics such as Secrets, CronJobs, RBAC, ServiceAccounts, canary deployments, NetworkPolicies, rolling updates, readiness probes, security contexts, Services, Ingress, and resource requests/limits.

## Prerequisites

Before running the setup, make sure you have:

- A running Kubernetes cluster.
- `kubectl` installed and configured to point to that cluster.
- Permission to create namespaces, workloads, services, RBAC resources, NetworkPolicies, Ingress resources, and ResourceQuotas.
- `podman` or another compatible container tool if you want to complete the image build task.

Check your cluster access with:

```bash
kubectl cluster-info
kubectl get nodes
```

## Run The Setup

From this folder, create all practice resources with:

```bash
kubectl apply -f setup-ckad-practice.yaml
```

This creates the namespaces and starter objects needed for the CKAD practice questions.

## Verify Your Answers

After completing the exercises, run:

```bash
./verify-ckad.sh
```

If the script is not executable on your machine, run:

```bash
chmod +x verify-ckad.sh
./verify-ckad.sh
```

The script prints a pass/fail result for each question based on the expected Kubernetes state.

## Clean Up

When you are done practicing, remove the resources with:

```bash
kubectl delete -f setup-ckad-practice.yaml
```

This deletes the resources created by the setup manifest.

## Notes

- The setup intentionally includes broken or incomplete resources so you can practice diagnosing and fixing them.
- Most tasks are isolated by namespace, which makes it easier to work through one question at a time.
- Re-running `kubectl apply -f setup-ckad-practice.yaml` can reset many starter resources, but it may not undo every manual change. For a clean restart, delete the setup first and then apply it again.
