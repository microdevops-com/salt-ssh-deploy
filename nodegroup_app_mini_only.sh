#!/bin/bash
set -e
source /opt/salt-ssh-deploy/.env
SALT_SSH_NODEGROUP="$1"
DEPLOY_ONLY="$2"
echo "${SALT_REPO_KEY_TOKEN}" | docker login --username "${SALT_REPO_KEY_USER}" --password-stdin "${SALT_REPO_REGISTRY}"
docker run --pull=always --rm -e SALTSSH_ROOT_ED25519_PRIV="$(cat ${SALTSSH_ROOT_ED25519_PRIV_FILE})" -e SALTSSH_ROOT_ED25519_PUB="$(cat ${SALTSSH_ROOT_ED25519_PUB_FILE})" ${SALT_REPO_IMAGE} -- \
	salt-ssh --wipe --force-color --nodegroup "${SALT_SSH_NODEGROUP}" \
	state.apply app.mini pillar='{app: {python: {deploy_only: "'${DEPLOY_ONLY}'"}, php-fpm: {deploy_only: "'${DEPLOY_ONLY}'"}, ruby: {deploy_only: "'${DEPLOY_ONLY}'"}, static: {deploy_only: "'${DEPLOY_ONLY}'"}, docker: {deploy_only: "'${DEPLOY_ONLY}'"}}}'
