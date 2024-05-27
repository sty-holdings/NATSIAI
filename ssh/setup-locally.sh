#!/bin/bash
#
# Description: This will set up a NATS locally.
#
# Installation:
#   None required
#
# Copyright (c) 2022 STY-Holdings Inc
# MIT License
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
# associated documentation files (the “Software”), to deal in the Software without restriction,
# including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the Software is furnished to
# do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or
# substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING
# BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
# DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#

set -eo pipefail

# script variables
FILENAME=$(basename "$0")

# Private Variables
ACTION="none"
export IDENTITY          # This is set by calling build-ssh-identity.sh function build_ssh_identity.
export IDENTITY_FILENAME # This is set by calling build-ssh-identity_filename.sh function build_ssh_identity_filename.
WAIT="yes"
DISPLAY_EXPORTS="yes"
scriptDirectory="/Users/syacko/workspace/sty-holdings/NATSIAI/ssh"

function init_script() {
  # needed to initialize the script and load core-devops scripts
  if [ -d "$scriptDirectory/core-devops" ]; then
    # found
    if find "$scriptDirectory/core-devops" -mmin +5 -print | grep -q '.'; then
      echo "Remove existing core-devops directory."
      rm -rf core-devops
      echo "Cloning Core DevOps scripts"
      git clone https://github.com/sty-holdings/core-devops
    fi
  else
      echo "Cloning Core DevOps scripts"
      git clone https://github.com/sty-holdings/core-devops
  fi
  # shellcheck disable=SC2154
  . core-devops/scripts/0-initialize-core-scripts.sh
  #
  display_spacer
  display_info "Core Devops scripts are installed and initialized."

  #
  # Pulling configuration from Github
  #
  if [ -d "$scriptDirectory/configurations" ]; then
    # found
    validate_file_age 5 "configurations"
    # shellcheck disable=SC2154
    if [ "$validate_file_age_result" == "old" ]; then
      display_info "Remove existing configurations directory,."
      rm -rf configurations
      display_info "Cloning configurations"
      git clone https://github.com/sty-holdings/configurations
    fi
  else
    echo "test"
    display_info "Cloning configurations"
    git clone https://github.com/sty-holdings/configurations
  fi
  display_spacer
  display_info "Configuration is installed."
  display_spacer
#
  display_info "Script has been initialized."
}

# shellcheck disable=SC2028
function print_exports() {
  echo "LOCAL_USER_HOME_DIRECTORY:\t$LOCAL_USER_HOME_DIRECTORY"
  echo "SERVER_INSTANCE_IPV4:\t\t$SERVER_INSTANCE_IPV4"
  echo "WORKING_AS:\t\t\t$WORKING_AS"
  echo "WORKING_AS_HOME_DIRECTORY:\t$WORKING_AS_HOME_DIRECTORY"
  display_spacer
}

# shellcheck disable=SC2028
function print_usage() {
  display_info "This will install NATS on an existing instance accessible by SSH."
  echo
  echo "Usage: $FILENAME -h | -I | -y yaml <filename> <action> [-W | -D]"
  echo
  echo "Global flags:"
  echo "  -h\t\t\t Display help."
  echo "  -I\t\t\t Prints additional information for savup-nats."
  echo "  -y yaml filename\t The FQN of the yaml file containing all the needed settings."
  echo "  -W\t\t\t Do not wait to review the yaml and export settings."
  echo "  -D\t\t\t Do not display the export and yaml settings."
  echo
  echo "Actions (Listing in order of recommended execution)"
  echo "  -i\t (Skip -T) Installing nats-server, natscli, nsc and create nats.conf with TLS."
  echo "  -S\t Scrub NATS from the system. Executables and directories."
  echo
}

function set_NATS_port() {
  if [ -z "$NATS_PORT" ]; then
    export NATS_PORT=4222
  fi
}

function validate_arguments() {
  if [ $ACTION == "none" ]; then
    local Failed="true"
    display_error "You have to provide an action."
  fi
  if [ -z "$YAML_FILENAME" ]; then
    local Failed="true"
    display_error "The yaml filename was not provided."
  fi

  if [ "$Failed" == "true" ]; then
    print_usage
    exit 99
  fi
}

function validate_parameters() {
  if [ -z "$IDENTITY_FILENAME" ]; then
    local Failed="true"
    display_error "Your ssh IDENTITY_FILENAME must be provided."
  fi
  if [ -z "$LOCAL_USER_HOME_DIRECTORY" ]; then
    local Failed="true"
    display_error "The LOCAL_USER_HOME_DIRECTORY (FQN) must be provided."
  fi
  if [ -z "$SERVER_INSTANCE_IPV4" ]; then
    local Failed="true"
    display_error "The SERVER_INSTANCE_IPV4 must be provided. Can be an IP address or DNS entry."
  fi
  if [ -z "$NATS_INSTALL_DIRECTORY" ]; then
    local Failed="true"
    display_error "The NATS_INSTALL_DIRECTORY (FQN) must be provided."
  fi
  if [ -z "$WORKING_AS" ]; then
    local Failed="true"
    display_error "The WORKING_AS users must be provided."
  fi

  if [ "$Failed" == "true" ]; then
    print_usage
    exit 99
  fi
}

# shellcheck disable=SC2034
function validate_NATS_install_directory() {
  if [ -z "$NATS_INSTALL_DIRECTORY" ]; then
    validate_NATS_install_directory_result="failed"
    display_error "The NATS_INSTALL_DIRECTORY must be provided."
  fi
}

# Main function of this script
function run_script() {
  if [ "$#" == "0" ]; then
    display_error "No parameters where provided."
    print_usage
    exit 99
  fi

  while getopts 'Wy:DiISh' OPT; do # see print_usage
    case "$OPT" in
    D)
      DISPLAY_EXPORTS="no"
      ;;
    i)
      ACTION="INSTALL"
      ;;
    I)
      display_info "ACTION: -I Print action variable usage."
      # shellcheck disable=SC2086
      print_additional_info $FILENAME
      display_spacer
      exit 0
      ;;
    S)
      ACTION="SCRUB"
      ;;
    W)
      WAIT="no"
      ;;
    y)
      set_variable YAML_FILENAME "$OPTARG"
      ;;
    h)
      print_usage
      exit 0
      ;;
    *)
      display_error "Please review the usage printed below:" >&2
      print_usage
      exit 99
      ;;
    esac
  done

# Setup
#
# Validating inputs to the script
#
  validate_arguments
#
# Display yaml settings
#
  display_spacer
  if [ "$DISPLAY_EXPORTS" == "yes" ]; then
    display_info "YAML file values:"
    # shellcheck disable=SC2086
    print_formatted_yaml $YAML_FILENAME
  fi
  display_spacer
#
# Adding yaml setting as exports
#
  get_now_formatted '%Y-%m-%d-%H-%M-%S'
  # shellcheck disable=SC2086
  # shellcheck disable=SC2154
  parse_export_yaml_filename_prefix $YAML_FILENAME $now
  # shellcheck disable=SC2086
  myExports=$(cat /tmp/$now-exports.sh)
  # shellcheck disable=SC2086
  eval $myExports
  rm /tmp/*-exports.sh
#
# Validate yaml file parameters
#
  validate_parameters
  if [ "$DISPLAY_EXPORTS" == "yes" ]; then
    display_info "YAML values exported"
    print_exports
    if [ "$WAIT" == "yes" ]; then
      display_info "Waiting 8 seconds to allow review of setting. Ctrl+c to abort."
      sleep 8
      display_spacer
    fi
  fi
  display_spacer
#
# Building ssh identity file for the server user
#
  IDENTITY_FILENAME="$LOCAL_USER_HOME_DIRECTORY/.ssh/$IDENTITY_FILENAME"
  # shellcheck disable=SC2086
  build_ssh_identity $IDENTITY_FILENAME
#
# Processing Action
#
  case "$ACTION" in
  INSTALL)
    display_spacer
    display_info "ACTION: -i Installing nats-server, natscli, nsc and create nats.conf."
    display_spacer

    display_info "Installing natscli and nsc locally."
    brew tap nats-io/nats-tools
    brew install nats-io/nats-tools/nats
    brew install nats-io/nats-tools/nsc

    display_info "Pull Operator, Account, and Context from remote server"
    mkdir -p "$LOCAL_USER_HOME_DIRECTORY"/.local/share/nats/nsc
    mkdir -p "$LOCAL_USER_HOME_DIRECTORY"/.config/nats/context

    # shellcheck disable=SC2086
    scp $IDENTITY -r $WORKING_AS@$SERVER_INSTANCE_IPV4:/home/$WORKING_AS/.local/share/nats/nsc $LOCAL_USER_HOME_DIRECTORY/.local/share/nats
    # shellcheck disable=SC2086
    scp $IDENTITY -r $WORKING_AS@$SERVER_INSTANCE_IPV4:/home/$WORKING_AS/.config/nats/context $LOCAL_USER_HOME_DIRECTORY/.config/nats
    # shellcheck disable=SC2086
    scp $IDENTITY -r $WORKING_AS@$SERVER_INSTANCE_IPV4:/home/$WORKING_AS/.config/nats/context $LOCAL_USER_HOME_DIRECTORY/.config/nats
    display_spacer
    display_spacer
    display_spacer
    display_info "******* IMPORTANT *********"
    display_info ""
    display_info "Next Steps:"
    display_info "\tRun the following command to create NATS $WORKING_AS credentials:"
    display_info "\t\tsh /Users/syacko/workspace/sty-holdings/NATSIAI/ssh/generate-nats-creds.sh -a $NATS_ACCOUNT -u $WORKING_AS"
    display_info "\tUpdate the $LOCAL_USER_HOME_DIRECTORY/.config/nats/context/$WORKING_AS*.json file"
    display_info "\t\twith the file location for the CA Bundle, Certificate, and Private key."
    ;;

  SCRUB)
    display_spacer
    display_info "ACTION: -S Scrub NATS installation from the system."
    display_spacer
    echo "Scrubbing .config/nats and .local/share/nats from user."
    # shellcheck disable=SC2034
    # shellcheck disable=SC2086
    echo "\$LOCAL_USER_HOME_DIRECTORY=$LOCAL_USER_HOME_DIRECTORY"
    # shellcheck disable=SC2086
    rm -rf $LOCAL_USER_HOME_DIRECTORY/.local/share/nats $LOCAL_USER_HOME_DIRECTORY/.config/nats || true
    # shellcheck disable=SC2154
    echo "Scrubbing natscli and nsc."
    # shellcheck disable=SC2034
    rm /usr/local/bin/nats 2>/dev/null || true
    # shellcheck disable=SC2034
    rm /usr/local/bin/nsc 2>/dev/null || true
    brew tap nats-io/nats-tools
    brew uninstall nats-io/nats-tools/nats || true
    brew uninstall nats-io/nats-tools/nsc || true
    brew untap nats-io/nats-tools
    display_spacer
    ;;
  esac

  echo Done
}

my_os=$(uname -o)
if [ ! "$my_os" == "Darwin" ]; then
  echo "OS is not supported."
else
  init_script
  run_script "$@"
fi

