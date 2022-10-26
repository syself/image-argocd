# ArgoCD Image with Helmfile
This repo contains the Dockerfile for ArgoCD with Helmfile support.

## Usage

Image Repo: `quay.io/syself/argocd:latest`

https://quay.io/repository/syself/argocd


## Release Process

### Create a tag

1. Create an annotated tag
   - `export RELEASE_TAG=<the tag of the release to be cut>` (eg. `export RELEASE_TAG=v1.0.1`)
   - `git tag -a ${RELEASE_TAG} -m ${RELEASE_TAG}`
2. Push the tag to the GitHub repository. This will automatically trigger a [Github Action](https://github.com/kubernetes-sigs/cluster-api/actions) to create a draft release.
   > NOTE: `origin` should be the name of the remote pointing to `github.com/syself/cluster-api-provider-hetzner`
   - `git push origin ${RELEASE_TAG}`