# Docker-Unison
A docker volume container using [Unison](http://www.cis.upenn.edu/~bcpierce/unison/) for fast two-way folder sync. Created as an alternative to [slow docker for mac volumes on OS X](https://forums.docker.com/t/file-access-in-mounted-volumes-extremely-slow-cpu-bound/8076).

This image is trying to be as minimal as possible and it only weights `14.41MB`.

The docker image is available on Docker Hub:
[registry.hub.docker.com/u/onnimonni/unison/](https://registry.hub.docker.com/u/onnimonni/unison/)

## Usage

### Docker

First, you can launch a volume container exposing a volume with Unison.

```bash
$ CID=$(docker run -d -p 5000:5000 -e UNISON_DIR=/data onnimonni/unison)
```

You can then sync a local folder to `$UNISON_DIR` (default value: `/data`) in the container with:

```bash
$ unison . socket://<docker>:5000/ -auto -batch
```

Next, you can launch a container connected with the volume under `/data`.

```bash
$ docker run -it --volumes-from $CID ubuntu /bin/sh
```

### Configuration
This container has few envs that you can alter.

`UNISON_DIR` - This is the directory which receives data from unison inside the container.
This is also the directory which you can use in other containers with `volumes_from` directive.

`UNISON_GID` - Group ID for the user running unison inside container.

`UNISON_UID` - User ID for the user running unison inside container.

`UNISON_USER` - User name for the sync user ( UID matters more )

`UNISON_GROUP` - Group name for the sync user ( GID matters more )

### Docker Compose

If you are using Docker Compose to manage a dev environment, use the `volumes_from` directive.

The following `docker-compose.yml` would mount the `/var/www/project` folder from the `unison` container inside your `mywebserver` container.

```yaml
mywebserver:
  build: .
  volumes_from:
    - unison
unison:
  image: onnimonni/unison
  environment:
    - UNISON_DIR=/var/www/project
    - UNISON_UID=10000
    - UNISON_GID=10000
  ports:
    - "5000:5000"
  volumes:
    - /var/www/project
```

You can then sync a local folder, using the unison client, to `/unison` in the container with:

```bash
$ unison . socket://<docker>:5000/ -ignore 'Path .git' -auto -batch
```

You can use `-repeat watch` to sync everytime when files change:

```bash
$ unison . socket://<docker>:5000/ -repeat watch -ignore 'Path .git' -auto -batch
```

**NOTE: In order to use `-repeat` option you need to install unison-fsmonitor.**

## Installing Unison Locally
Unison requires the version of the client (running on the host) and server (running in the container) to match.

Docker images are versioned with the version of unison which is installed in the container.
You can use `onnimonni/unison:2.48.4` image to use unison with 2.48.4 version.

* 2.40.102 (available via `apt-get install unison` on Ubuntu 14.04, 14.10, 15.04)
* 2.48.4 (available via `brew install unison` on Mac OS X) [default]

Additional versions can be added easily on request. Open an Issue if you need another version.

## Installing unison-fsmonitor on OSX (unox)
```
# This is dependency for unox
$ pip install MacFSEvents

# unox is unison-fsmonitor script for Mac
$ curl -o /usr/local/bin/unison-fsmonitor -L https://raw.githubusercontent.com/hnsl/unox/master/unox.py
$ chmod +x /usr/local/bin/unison-fsmonitor
```
## Credits
Thanks for [leighmcculloch](https://github.com/leighmcculloch/docker-unison) for showing me how to use unison with docker.

## License
This docker image is licensed under GPLv3 because Unison is licensed under GPLv3 and is included in the image. See LICENSE.
