#!/usr/bin/env ./libs/bats/bin/bats
load './libs/bats-support/load'
load './libs/bats-assert/load'

set +x

setup() {
    # get the containing directory of this file
    # use $BATS_TEST_FILENAME instead of ${BASH_SOURCE[0]} or $0,
    # as those will point to the bats executable's location or the preprocessed file respectively
    DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )"
    ## Load the $DIR/../dist/gitops-devcontainer.tar 
    IMAGE=$(docker load -q < $DIR/../dist/gitops-devcontainer_$(uname -m).tar  | awk 'NR==1{print $3}')
}

docker_run(){
  run docker run --platform="linux/$(uname -m)" --rm $IMAGE $1
}

@test "argocd version should be v2.5.10" {
  docker_run "argocd version"
  assert_output --partial 'argocd: v2.5.10+d311fad'
}

@test "crane version should be v0.13.0" {
  docker_run "crane version"
  assert_output --partial '0.13.0'
}

@test "flux version should be v0.39.0" {
  docker_run "flux version --client"
  assert_output --partial 'v0.39.0'
}

@test "helm version should be v3.11.0" {
  docker_run "helm version --client"
  assert_output --partial 'v3.11.0'
}

@test "k3d version should be v5.4.7" {
  docker_run "k3d version"
  assert_output --partial 'v5.4.7'
}

@test "kustomize version should be v5.0.0" {
  docker_run "kustomize version"
  assert_output --partial 'v5.0.0'
}

@test "taskfile version should be v3.20.0" {
  docker_run "task --version"
  assert_output --partial 'v3.20.0'
}

@test "kubectl version should be v1.24.10" {
  docker_run "kubectl version"
  assert_output --partial 'v1.24.10'
}

## TODO add cases for dev-tools/dev-user-settings

teardown() {
  docker rmi --force $IMAGE
}
