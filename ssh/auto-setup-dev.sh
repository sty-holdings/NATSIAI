#!/bin/bash
#
# This will run the setup.sh with pre-defined commands.
#

set -eo pipefail

sh setup-ssh-nats.sh -y /Users/syacko/workspace/styh-dev/src/albert/servers/savup-nats/build-deploy/yaml/savup-dev.yaml -S
# shellcheck disable=SC2181
if [ "$?" -ne 0 ]; then
  exit 0
fi
sh setup-ssh-nats.sh -y /Users/syacko/workspace/styh-dev/src/albert/servers/savup-nats/build-deploy/yaml/savup-dev.yaml -U -D
# shellcheck disable=SC2181
if [ "$?" -ne 0 ]; then
  exit 0
fi
sh setup-ssh-nats.sh -y /Users/syacko/workspace/styh-dev/src/albert/servers/savup-nats/build-deploy/yaml/savup-dev.yaml -i -D
# shellcheck disable=SC2181
if [ "$?" -ne 0 ]; then
  exit 0
fi
sh setup-ssh-nats.sh -y /Users/syacko/workspace/styh-dev/src/albert/servers/savup-nats/build-deploy/yaml/savup-dev.yaml -o -D
# shellcheck disable=SC2181
if [ "$?" -ne 0 ]; then
  exit 0
fi
sh setup-ssh-nats.sh -y /Users/syacko/workspace/styh-dev/src/albert/servers/savup-nats/build-deploy/yaml/savup-dev.yaml -a -D
# shellcheck disable=SC2181
if [ "$?" -ne 0 ]; then
  exit 0
fi
sh setup-ssh-nats.sh -y /Users/syacko/workspace/styh-dev/src/albert/servers/savup-nats/build-deploy/yaml/savup-dev.yaml -r -D
# shellcheck disable=SC2181
if [ "$?" -ne 0 ]; then
  exit 0
fi
sh setup-ssh-nats.sh -y /Users/syacko/workspace/styh-dev/src/albert/servers/savup-nats/build-deploy/yaml/savup-dev.yaml -P -D
# shellcheck disable=SC2181
if [ "$?" -ne 0 ]; then
  exit 0
fi
sh setup-ssh-nats.sh -y /Users/syacko/workspace/styh-dev/src/albert/servers/savup-nats/build-deploy/yaml/savup-dev.yaml -n -D
# shellcheck disable=SC2181
if [ "$?" -ne 0 ]; then
  exit 0
fi
sh setup-ssh-nats.sh -y /Users/syacko/workspace/styh-dev/src/albert/servers/savup-nats/build-deploy/yaml/savup-dev.yaml -C -D
# shellcheck disable=SC2181
if [ "$?" -ne 0 ]; then
  exit 0
fi
sh setup-ssh-nats.sh -y /Users/syacko/workspace/styh-dev/src/albert/servers/savup-nats/build-deploy/yaml/savup-dev.yaml -m -D
