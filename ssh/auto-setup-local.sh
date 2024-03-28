#!/bin/bash
#
# This will run the setup.sh with pre-defined commands.
#

set -eo pipefail

sh setup-ssh-nats.sh -y /Users/syacko/workspace/styh-dev/src/albert/servers/savup-nats/build-deploy/yaml/savup-local.yaml -S
# shellcheck disable=SC2181
if [ "$?" -ne 0 ]; then
  exit 0
fi
sh setup-ssh-nats.sh -y /Users/syacko/workspace/styh-dev/src/albert/servers/savup-nats/build-deploy/yaml/savup-local.yaml -U -D
# shellcheck disable=SC2181
if [ "$?" -ne 0 ]; then
  exit 0
fi
sh setup-ssh-nats.sh -y /Users/syacko/workspace/styh-dev/src/albert/servers/savup-nats/build-deploy/yaml/savup-local.yaml -i -D
# shellcheck disable=SC2181
if [ "$?" -ne 0 ]; then
  exit 0
fi
sh setup-ssh-nats.sh -y /Users/syacko/workspace/styh-dev/src/albert/servers/savup-nats/build-deploy/yaml/savup-local.yaml -o -D
# shellcheck disable=SC2181
if [ "$?" -ne 0 ]; then
  exit 0
fi
sh setup-ssh-nats.sh -y /Users/syacko/workspace/styh-dev/src/albert/servers/savup-nats/build-deploy/yaml/savup-local.yaml -a -D
# shellcheck disable=SC2181
if [ "$?" -ne 0 ]; then
  exit 0
fi
sh setup-ssh-nats.sh -y /Users/syacko/workspace/styh-dev/src/albert/servers/savup-nats/build-deploy/yaml/savup-local.yaml -r -D
# shellcheck disable=SC2181
if [ "$?" -ne 0 ]; then
  exit 0
fi
sh setup-ssh-nats.sh -y /Users/syacko/workspace/styh-dev/src/albert/servers/savup-nats/build-deploy/yaml/savup-local.yaml -P -D
# shellcheck disable=SC2181
if [ "$?" -ne 0 ]; then
  exit 0
fi
sh setup-ssh-nats.sh -y /Users/syacko/workspace/styh-dev/src/albert/servers/savup-nats/build-deploy/yaml/savup-local.yaml -n -D
# shellcheck disable=SC2181
if [ "$?" -ne 0 ]; then
  exit 0
fi
sh setup-ssh-nats.sh -y /Users/syacko/workspace/styh-dev/src/albert/servers/savup-nats/build-deploy/yaml/savup-local.yaml -C -D
# shellcheck disable=SC2181
if [ "$?" -ne 0 ]; then
  exit 0
fi
sh setup-ssh-nats.sh -y /Users/syacko/workspace/styh-dev/src/albert/servers/savup-nats/build-deploy/yaml/savup-local.yaml -m -D
