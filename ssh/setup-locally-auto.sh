#!/bin/bash
#
# This will run the setup.sh with pre-defined commands.
#

set -eo pipefail

sh setup-locally.sh -y configurations/yaml/local-natsiai.yaml -S
# shellcheck disable=SC2181
if [ "$?" -ne 0 ]; then
  exit 0
fi
sh setup-locally.sh -y configurations/yaml/local-natsiai.yaml -i -D
# shellcheck disable=SC2181
if [ "$?" -ne 0 ]; then
  exit 0
fi