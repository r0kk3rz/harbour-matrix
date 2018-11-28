# harbour-matrix
An unofficial Matrix.org client for Sailfish OS based upon QMatrixClient

## Features
- Rooms

## License
GNU General Public License v3.0

## Building hints

You will need `opt-gcc6` to build it.

You could get it thanks to rinigus merproject repo something like:

1. ssh to mersdk
1. `sdk-assistant list`
1. `sb2 -t SailfishOS-3.0.0-super-fresh-armv7hl -R -m sdk-install`
1. `zypper ar -f http://repo.merproject.org/obs/home:/rinigus:/toolbox/sailfish_latest_armv7hl/ merproject-rinigus`
1. `zypper install opt-gcc6`
1. answer `yes` to accept rinigus repo and `i` after that to ignore signature check

If you hate docker less than sailfish sdk,
feel free to try [sailfish sdk CODeRUS docker version](https://github.com/CODeRUS/docker-sailfishos-sdk):

1. Run container (update it to newer sdk version if you want to),
1. Check ssh keys mounted (it could be broken currently),
1. ssh to mersdk,
1. add rinigus repo
1. `docker ps`,
1. `docker commit my_contaner_id sailfishos-platform-sdk-local:opt-gcc6`,
1. create new build helper script similar to `sdk-build-package` from the repo with new name
1. ???
1. PROFIT!
