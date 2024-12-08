#!/bin/bash
mkdir /work

./config.sh \
    --url ${GITHUB_REPO_URL} \
    --token ${GITHUB_RUNNER_TOKEN} \
    --work "/work" \
    --unattended \
    --replace

remove() {
    ./config.sh remove --unattended --token "${GITHUB_RUNNER_TOKEN}"
}

trap 'remove; exit 130' INT
trap 'remove; exit 143' TERM

./run.sh "$*" &

wait $!