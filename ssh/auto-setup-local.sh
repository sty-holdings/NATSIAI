#!/bin/bash
#
# This will run the setup.sh with pre-defined commands.
#

set -eo pipefail

sh setup.sh -y configurations/yaml/local-natsiai.yaml -S
# shellcheck disable=SC2181
if [ "$?" -ne 0 ]; then
  exit 0
fi
sh setup.sh -y configurations/yaml/local-natsiai.yaml -U -D
# shellcheck disable=SC2181
if [ "$?" -ne 0 ]; then
  exit 0
fi
sh setup.sh -y configurations/yaml/local-natsiai.yaml -i -D
# shellcheck disable=SC2181
if [ "$?" -ne 0 ]; then
  exit 0
fi
sh setup.sh -y configurations/yaml/local-natsiai.yaml -o -D
# shellcheck disable=SC2181
if [ "$?" -ne 0 ]; then
  exit 0
fi
sh setup.sh -y configurations/yaml/local-natsiai.yaml -a -D
# shellcheck disable=SC2181
if [ "$?" -ne 0 ]; then
  exit 0
fi
sh setup.sh -y configurations/yaml/local-natsiai.yaml -r -D
# shellcheck disable=SC2181
if [ "$?" -ne 0 ]; then
  exit 0
fi
sh setup.sh -y configurations/yaml/local-natsiai.yaml -P -D
# shellcheck disable=SC2181
if [ "$?" -ne 0 ]; then
  exit 0
fi
sh setup.sh -y configurations/yaml/local-natsiai.yaml -n -D
# shellcheck disable=SC2181
if [ "$?" -ne 0 ]; then
  exit 0
fi
sh setup.sh -y configurations/yaml/local-natsiai.yaml -C -D
# shellcheck disable=SC2181
if [ "$?" -ne 0 ]; then
  exit 0
fi
sh setup.sh -y configurations/yaml/local-natsiai.yaml -m -D
