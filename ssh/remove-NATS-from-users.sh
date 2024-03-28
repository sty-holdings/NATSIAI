#!/bin/bash
#
# This will remove the .config/nats and .local/share/nats from all users
#

# Loop through all user home directories
for user_home in /home/*; do
  if [ -d "$user_home" ]; then
    # Check for and remove .config/nats directory
    config_nats_dir="$user_home/.config/nats"
    if [ -d "$config_nats_dir" ]; then
      rm -r "$config_nats_dir"
    fi

    # Check for and remove /local/share/nats directory
    local_share_nats_dir="$user_home/.local/share/nats"
    if [ -d "$local_share_nats_dir" ]; then
      rm -r "$local_share_nats_dir"
    fi
  fi
done
