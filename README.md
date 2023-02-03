# DevTools

A collection tools and utilities that can be used for building Kubernetes demos, tutorials. They can also be used with Container Native CI tools to run build/test commands.

These images are Alpine based, built using [apko](https://github.com/chainguard-dev/apko) and [melange](https://github.com/chainguard-dev/melange).

## Tools Available

- [x] [Argo CD](https://argo-cd.readthedocs.io/) CLI
- [x] [Crane](https://github.com/google/go-containerregistry/blob/main/cmd/crane/doc/crane.md) CLI
- [x] [FluxCD](https://fluxcd.io/) CLI
- [x] [Helm](https://helm.sh)
- [x] [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [x] [kubectx](https://github.com/ahmetb/kubectx)
- [x] [kustomize](https://kustomize.io/)
- [x] [K3D](https://k3d.io)
- [x] [Taskfile](https://taskfile.dev/)
- [x] [yq](https://github.com/mikefarah/yq)
- [x] [jq](https://stedolan.github.io/jq/)
- [ ] Docker In Docker(DinD)

There are few other extra settings/packages installed to make these images to be used as Visual Studio Code [Dev Containers](https://code.visualstudio.com/docs/devcontainers/containers).

## Images

- [ ] docker.io/kameshsampath/kube-dev-tools:0.1.6
- [ ] docker.io/kameshsampath/gitops-devcontainer:0.0.1
