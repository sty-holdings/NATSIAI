#!/bin/bash
#
# This will run the setup.sh with pre-defined commands.
#

set -eo pipefail

sh setup-ssh-nats.sh -y /Users/syacko/workspace/styh-dev/src/albert/servers/savup-nats/build-deploy/yaml/savup-prod.yaml -S
# shellcheck disable=SC2181
if [ "$?" -ne 0 ]; then
  exit 0
fi
sh setup-ssh-nats.sh -y /Users/syacko/workspace/styh-dev/src/albert/servers/savup-nats/build-deploy/yaml/savup-prod.yaml -U -D
# shellcheck disable=SC2181
if [ "$?" -ne 0 ]; then
  exit 0
fi
sh setup-ssh-nats.sh -y /Users/syacko/workspace/styh-dev/src/albert/servers/savup-nats/build-deploy/yaml/savup-prod.yaml -i -D
# shellcheck disable=SC2181
if [ "$?" -ne 0 ]; then
  exit 0
fi
sh setup-ssh-nats.sh -y /Users/syacko/workspace/styh-dev/src/albert/servers/savup-nats/build-deploy/yaml/savup-prod.yaml -o -D
# shellcheck disable=SC2181
if [ "$?" -ne 0 ]; then
  exit 0
fi
sh setup-ssh-nats.sh -y /Users/syacko/workspace/styh-dev/src/albert/servers/savup-nats/build-deploy/yaml/savup-prod.yaml -a -D
# shellcheck disable=SC2181
if [ "$?" -ne 0 ]; then
  exit 0
fi
sh setup-ssh-nats.sh -y /Users/syacko/workspace/styh-dev/src/albert/servers/savup-nats/build-deploy/yaml/savup-prod.yaml -r -D
# shellcheck disable=SC2181
if [ "$?" -ne 0 ]; then
  exit 0
fi
sh setup-ssh-nats.sh -y /Users/syacko/workspace/styh-dev/src/albert/servers/savup-nats/build-deploy/yaml/savup-prod.yaml -P -D
# shellcheck disable=SC2181
if [ "$?" -ne 0 ]; then
  exit 0
fi
sh setup-ssh-nats.sh -y /Users/syacko/workspace/styh-dev/src/albert/servers/savup-nats/build-deploy/yaml/savup-prod.yaml -n -D
# shellcheck disable=SC2181
if [ "$?" -ne 0 ]; then
  exit 0
fi
sh setup-ssh-nats.sh -y /Users/syacko/workspace/styh-dev/src/albert/servers/savup-nats/build-deploy/yaml/savup-prod.yaml -C -D
# shellcheck disable=SC2181
if [ "$?" -ne 0 ]; then
  exit 0
fi
sh setup-ssh-nats.sh -y /Users/syacko/workspace/styh-dev/src/albert/servers/savup-nats/build-deploy/yaml/savup-prod.yaml -m -D
