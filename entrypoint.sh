#!/bin/bash
set -e

USER_UID=${USER_UID:-1000}
USER_GID=${USER_GID:-1000}

MS_TEAMS_USER=msteams

install_ms_teams() {
  echo "Installing ms-teams-wrapper..."
  install -m 0755 /var/cache/ms-teams/ms-teams-wrapper /target/
  echo "Installing teams..."
  ln -sf ms-teams-wrapper /target/teams
}

uninstall_ms_teams() {
  echo "Uninstalling ms-teams-wrapper..."
  rm -rf /target/ms-teams-wrapper
  echo "Uninstalling teams..."
  rm -rf /target/teams
}

create_user() {
  # create group with USER_GID
  if ! getent group ${MS_TEAMS_USER} >/dev/null; then
    groupadd -f -g ${USER_GID} ${MS_TEAMS_USER} >/dev/null 2>&1
  fi

  # create user with USER_UID
  if ! getent passwd ${MS_TEAMS_USER} >/dev/null; then
    adduser --disabled-login --uid ${USER_UID} --gid ${USER_GID} \
      --gecos 'MS Teams' ${MS_TEAMS_USER} >/dev/null 2>&1
  fi
  chown ${MS_TEAMS_USER}:${MS_TEAMS_USER} -R /home/${MS_TEAMS_USER}
  adduser ${MS_TEAMS_USER} sudo
}

grant_access_to_video_devices() {
  for device in /dev/video*
  do
    if [[ -c $device ]]; then
      VIDEO_GID=$(stat -c %g $device)
      VIDEO_GROUP=$(stat -c %G $device)
      if [[ ${VIDEO_GROUP} == "UNKNOWN" ]]; then
        VIDEO_GROUP=msteamsvideo
        groupadd -g ${VIDEO_GID} ${VIDEO_GROUP}
      fi
      usermod -a -G ${VIDEO_GROUP} ${MS_TEAMS_USER}
      break
    fi
  done
}

launch_ms_teams() {
  cd /home/${MS_TEAMS_USER}
  exec sudo -HEu ${MS_TEAMS_USER} PULSE_SERVER=/run/pulse/native QT_GRAPHICSSYSTEM="native" xcompmgr -c -l0 -t0 -r0 -o.00 &
  exec sudo -HEu ${MS_TEAMS_USER} PULSE_SERVER=/run/pulse/native QT_GRAPHICSSYSTEM="native" $@
}

case "$1" in
  install)
    install_ms_teams
    ;;
  uninstall)
    uninstall_ms_teams
    ;;
  msteams)
    create_user
    grant_access_to_video_devices
    echo "$1"
    launch_ms_teams $@
    ;;
  *)
    exec $@
    ;;
esac
