This project is adapted from [mdouchement](https://github.com/mdouchement) [Zoom](https://github.com/mdouchement/docker-zoom-us) containerization.

# slithy/docker-ms-teams

# Introduction

`Dockerfile` to create a [Docker](https://www.docker.com/) container image for
[Microsoft Teams](https://www.microsoft.com/en-us/microsoft-365/microsoft-teams/download-app)
with support for audio/video calls.

The image uses [X11](http://www.x.org) and [Pulseaudio](http://www.freedesktop.org/wiki/Software/PulseAudio/)
unix domain sockets on the host to enable audio/video support in Microsoft Teams. These components are
available out of the box on pretty much any modern Linux distribution.

# License

Copyright © 2020 Michael Davis

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.

# Getting started

## Installation

* `make` to create the Docker image.
* `make install` installs the script `ms-teams-wrapper` in `/usr/local/bin` and a symbolic link, `teams`.
* Run `teams` to start the container.

## How it works

The wrapper scripts volume mount the X11 and pulseaudio sockets in the launcher container. The X11 socket
allows for the user interface display on the host, while the pulseaudio socket allows for the audio output
to be rendered on the host.

When the image is launched the following directories are mounted as volumes

- `${HOME}/.config`
- `XDG_DOWNLOAD_DIR` or if it is missing `${HOME}/Downloads`
- `XDG_DOCUMENTS_DIR` or if it is missing `${HOME}/Documents`

This makes sure that your profile details are stored on the host and files received via Teams are available
on your host in the appropriate download directory.

**Don't want to expose host's folders to Teams?**

Add `MS_TEAMS_HOME` environment variable to namespace all teams folders:
```sh
export MS_TEAMS_HOME=${HOME}/ms-teams
```

# Maintenance

## Upgrading

Rebuilding the Docker container will download the latest release of MS Teams.

## Uninstallation

* `make uninstall` will delete the scripts from `/usr/local/bin`.

## Shell Access

For debugging and maintenance purposes you may want access the container's shell. If you are using Docker
version `1.3.0` or higher you can access a running containers shell by starting `bash` using `docker exec`:

```bash
docker exec -it msteams bash
```

## Troubleshooting

* MS Teams creates a logfile in `.config/Microsoft/Microsoft Teams/logs/teams-startup.log`

