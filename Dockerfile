#syntax=docker/dockerfile:1.3-labs
ARG DOCKER_VERSION=23.0.0
ARG BASE=mcr.microsoft.com/devcontainers/base:ubuntu

## TODO Move this to a common base 
FROM $BASE AS builder

ARG TARGETARCH

ARG K3S_VERSION=v1.24.9-k3s1
ARG CRANE_VERSION=0.13.0
ARG HELM_VERSION=3.11.0
ARG KUSTOMIZE_VERSION=v4.5.7

ARG BASE_URL="https://get.helm.sh"
ARG TAR_FILE="helm-v${HELM_VERSION}-linux-${TARGETARCH}.tar.gz"

# Argo CD CLI
RUN curl -sSL -o /usr/bin/argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-${TARGETARCH} && \
  chmod 755 /usr/bin/argocd

# crane

RUN <<EOT sh
    if  [ "amd64" = "$TARGETARCH" ];
    then
      curl -sSL "https://github.com/google/go-containerregistry/releases/download/v${CRANE_VERSION}/go-containerregistry_Linux_x86_64.tar.gz" -o go-containerregistry.tar.gz
    else
      curl -sSL "https://github.com/google/go-containerregistry/releases/download/v${CRANE_VERSION}/go-containerregistry_Linux_${TARGETARCH}.tar.gz" -o go-containerregistry.tar.gz
    fi
    tar -zxf go-containerregistry.tar.gz
    mv crane /usr/bin/crane
    rm -rf go-containerregistry.tar.gz
EOT

# Docker 
RUN curl -fsSL https://get.docker.com -o get-docker.sh \
   && sh get-docker.sh

# Flux
RUN curl -s https://fluxcd.io/install.sh | bash 

# Helm
RUN curl -sL ${BASE_URL}/${TAR_FILE} | tar -xvz && \
    mv linux-${TARGETARCH}/helm /usr/bin/helm && \
    chmod +x /usr/bin/helm && \
    rm -rf linux-${TARGETARCH}

# kubectl
RUN  curl -sSL "https://dl.k8s.io/release/${K3S_VERSION%[+-]*}/bin/linux/${TARGETARCH}/kubectl" -o "/usr/bin/kubectl" &&\
  chmod +x "/usr/bin/kubectl"

# k3d
RUN curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

# kubens
RUN curl -sL -o /usr/bin/kubens https://raw.githubusercontent.com/ahmetb/kubectx/master/kubens \
  && chmod +x /usr/bin/kubens

# kubectx
RUN curl -sL -o /usr/bin/kubectx https://raw.githubusercontent.com/ahmetb/kubectx/master/kubectx \
  && chmod +x /usr/bin/kubectx

# kubectl aliasses
RUN curl https://raw.githubusercontent.com/ahmetb/kubectl-aliases/master/.kubectl_aliases -o /usr/local/.kubectl_aliases

# kustomize
RUN curl -sLO https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2F${KUSTOMIZE_VERSION}/kustomize_${KUSTOMIZE_VERSION}_linux_${TARGETARCH}.tar.gz && \
    tar xvzf kustomize_${KUSTOMIZE_VERSION}_linux_${TARGETARCH}.tar.gz && \
    mv kustomize /usr/bin/kustomize && \
    chmod +x /usr/bin/kustomize

# Taskfile
RUN sh -c "$(curl --location https://taskfile.dev/install.sh)" -- -d -b /usr/bin 

# yq
RUN wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_${TARGETARCH} -O /usr/bin/yq && \
    chmod +x /usr/bin/yq

FROM docker:$DOCKER_VERSION-dind

ARG TARGETARCH

ARG USERNAME=dev
ARG USER_UID=1001

COPY --from=builder /usr/bin/argocd /usr/bin/crane /usr/bin/k3d  /usr/bin/flux /usr/bin/kubectl /usr/bin/helm /usr/bin/kustomize /usr/bin/task /usr/bin/

COPY --from=builder /usr/local/bin/kubectx /usr/local/kubens /usr/local/.kubectl_aliases /usr/local/

RUN apk add --update --no-cache sudo shadow bash bash-completion musl libgcc libstdc++ curl wget git ca-certificates starship

RUN <<EOT
  groupadd $USERNAME && \
  useradd -s /bin/bash --uid $USER_UID --gid $USERNAME -m $USERNAME
   echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME
   chmod 0440 /etc/sudoers.d/$USERNAME
   cat <<EOF | tee /home/$USERNAME/.bashrc
     if [ -z "${USER}" ]; then export USER=$(whoami); fi
     if [[ "${PATH}" != *"$HOME/.local/bin"* ]]; then export PATH="${PATH}:$HOME/.local/bin"; fi
     source /usr/share/bash-completion/bash_completion
     source /usr/local/.kubectl_aliases
     alias k=kubectl
     complete -o default -F __start_kubectl k
     source <(kubectl completion bash)
     eval '$(starship init bash)'
EOF
  mkdir -p /home/$USERNAME/.kube
  chmod -R go-=wrx /home/$USERNAME/.kube
EOT
### END User Configuration

ENV USER=$USERNAME
ENV KUBECONFIG=/home/$USERNAME/.kube/config

CMD [ "/bin/bash" ]