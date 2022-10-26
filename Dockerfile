# ArgoCD Base
FROM argoproj/argocd:v2.4.7

# Dependencies versions

# renovate: datasource=github-tags depName=helmfile/helmfile extractVersion=^v(?<version>.*)$
ARG HELMFILE_VERSION=v0.146.0
# renovate: datasource=github-tags depName=helm/helm
ARG HELM_VERSION=v3.9.0
ARG HELM_LOCATION="https://get.helm.sh"
ARG HELM_FILENAME="helm-${HELM_VERSION}-linux-amd64.tar.gz"
# renovate: datasource=github-tags depName=mozilla/sops
ARG SOPS_VERSION=3.7.3
# renovate: datasource=github-tags depName=databus23/helm-diff extractVersion=^v(?<version>.*)$
ARG HELM_DIFF_VERSION=3.5.0
# renovate: datasource=github-tags depName=jkroepke/helm-secrets extractVersion=^v(?<version>.*)$
ARG HELM_SECRETS_VERSION=3.14.0
# renovate: datasource=github-tags depName=kubernetes/kubernetes extractVersion=^v(?<version>.*)$
ARG KUBECTL_VERSION=1.24.1

USER root

# Download OS dependencies
RUN apt-get update && \
  apt-get install -y \
  curl git wget unzip && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Download helmfile
RUN curl -fsSL "helmfile" https://github.com/helmfile/helmfile/releases/download/v${HELMFILE_VERSION}/helmfile_${HELMFILE_VERSION}_linux_amd64.tar.gz | tar -xzv helmfile && \
  mv helmfile /usr/local/bin/helmfile && \
  chmod +x /usr/local/bin/helmfile

# Download helm
RUN curl -OL ${HELM_LOCATION}/${HELM_FILENAME} && \
  echo Extracting ${HELM_FILENAME}... && \
  tar zxvf ${HELM_FILENAME} && mv ./linux-amd64/helm /usr/local/bin/ && \
  rm ${HELM_FILENAME} && rm -r ./linux-amd64 && \
  chmod +x /usr/local/bin/helm

# Dowload sops
RUN curl -fSSL https://github.com/mozilla/sops/releases/download/v${SOPS_VERSION}/sops-v${SOPS_VERSION}.linux \
  -o /usr/local/bin/sops && chmod +x /usr/local/bin/sops

# Download kubectl
RUN curl -fSSL https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl \
  -o /usr/local/bin/kubectl && chmod +x /usr/local/bin/kubectl

# Switch back to non-root user
USER argocd

# Install helm-secrets plugin (as argocd user)
RUN helm plugin install https://github.com/databus23/helm-diff --version v${HELM_DIFF_VERSION} && \
  helm plugin install https://github.com/jkroepke/helm-secrets --version v${HELM_SECRETS_VERSION} && \
  helm plugin install https://github.com/mumoshu/helm-x  && \
  helm plugin install https://github.com/aslafy-z/helm-git.git

# In case wrapper scripts are used, HELM_SECRETS_HELM_PATH needs to be the path of the real helm binary
ENV HELM_SECRETS_HELM_PATH=/usr/local/bin/helm \
  HELM_PLUGINS="/home/argocd/.local/share/helm/plugins/" \
  HELM_SECRETS_VALUES_ALLOW_SYMLINKS=false \
  HELM_SECRETS_VALUES_ALLOW_ABSOLUTE_PATH=false \
  HELM_SECRETS_VALUES_ALLOW_PATH_TRAVERSAL=false
