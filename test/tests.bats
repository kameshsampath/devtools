setup() {
    printf "Jai Guru"
    # get the containing directory of this file
    # use $BATS_TEST_FILENAME instead of ${BASH_SOURCE[0]} or $0,
    # as those will point to the bats executable's location or the preprocessed file respectively
    DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )"
    ## Load the dist/gitops-devcontainer.tar 
    IMAGE=$(docker load -q < dist/gitops-devcontainer.tar | awk 'NR==1{print $3}')
}

@test "argocd version should be v2.5.10" {
  assert_output 'v2.5.10'
}

@test "crane version should be v0.13.0" {
  assert_output 'v0.13.0'
}