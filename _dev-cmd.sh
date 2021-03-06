#!/usr/bin/env bash

# Don't use strict mode so that we run through to the end. (commented out)
# set -euo pipefail

set -x

echo "Configuring Docker group..."

# Configure Docker permissions.
if [[ -S /var/run/docker.sock ]] ; then
  # Get the GID of the "docker" group.
  docker_gid=`stat --format=%g /var/run/docker.sock`
  if [ -z "$docker_gid" ] ; then
    echo "No mounted Docker socket found."
  else
    if getent group "${docker_gid}" ; then
        # The group for the Docker socket's gid already exists.
        echo "Adding user to '$(getent group "${docker_gid}" | cut -d: -f1)' group for docker access."
        sudo usermod -aG "${docker_gid}" "${MAMBA_USER}"
    else
        # The group for the Docker socket's gid doesn't exist.
        if getent group docker ; then
          # The "docker" group exists, but doesn't match the gid of the Docker socket.
          docker_group_name="docker-conflicting-groupname"
        else
          docker_group_name="docker"
        fi
        echo "Setting the GID of the '${docker_group_name}' group to ${docker_gid}."
        sudo groupadd --force --gid "${docker_gid}" "${docker_group_name}"
        sudo usermod -aG "${docker_group_name}" "${MAMBA_USER}"
    fi
  fi
fi

# Set default blame ignore filename.
# This should only be done when it exists, due to <https://stackoverflow.com/q/70435937>
if [ -f .git-blame-ignore-revs ]; then
    git config --system blame.ignoreRevsFile .git-blame-ignore-revs
fi

echo "Sleeping forever."

while sleep 1000; do :; done
