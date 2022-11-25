#!/bin/bash

set -e

source /opt/salt-ssh-deploy/.env

# By default exit code = 0
GRAND_EXIT=0

# Duplicate output to temp file and rm it with trap on exit
OUT_FILE=$(mktemp)
trap 'rm -f "${OUT_FILE}"' 0
exec > >(tee ${OUT_FILE})
exec 2>&1

SALT_SSH_NODEGROUP="$1"
DEPLOY_ONLY="$2"
DEPLOY_IMAGE="$3"

echo "${SALT_REPO_KEY_TOKEN}" | docker login --username "${SALT_REPO_KEY_USER}" --password-stdin "${SALT_REPO_REGISTRY}"
docker run --pull=always --rm -e SALTSSH_ROOT_ED25519_PRIV="$(cat ${SALTSSH_ROOT_ED25519_PRIV_FILE})" -e SALTSSH_ROOT_ED25519_PUB="$(cat ${SALTSSH_ROOT_ED25519_PUB_FILE})" ${SALT_REPO_IMAGE} -- \
	salt-ssh --wipe --force-color --nodegroup "${SALT_SSH_NODEGROUP}" \
	state.apply app.docker \
	pillar='{app: {docker: {deploy_only: "'${DEPLOY_ONLY}'", apps: {"'${DEPLOY_ONLY}'": {image: "'${DEPLOY_IMAGE}'"}}}}}' \
	|| GRAND_EXIT=1

# Check out file for errors
grep -q "ERROR" ${OUT_FILE} && GRAND_EXIT=1

# Check out file for red color with shades
grep -q "\[0;31m" ${OUT_FILE} && GRAND_EXIT=1
grep -q "\[31m" ${OUT_FILE} && GRAND_EXIT=1
grep -q "\[0;1;31m" ${OUT_FILE} && GRAND_EXIT=1

exit $GRAND_EXIT
