SATIVA RADIO
=============

MPC/MPD and Icecast2 Dockerfile. Based on https://github.com/moul/docker-icecast

## Push image to registry
```
export DOCKER_ID_USER="jstnn"
docker login
docker tag sativa $DOCKER_ID_USER/radiosativa
docker push $DOCKER_ID_USER/radiosativa
```

## Run

Run with default password, export port 8000.

Expose 6600 for external client connection like mpc

Build image

```bash
docker build -t sativa .
```

```bash
docker run --env-file=sativa.env -p 8000:8000 -p 6600:6600 --privileged --cap-add SYS_ADMIN --cap-add MKNOD --device=/dev/fuse --security-opt apparmor:unconfined -v radio:/opt/music sativa
$BROWSER localhost:8000
```

Run with custom password

```bash
docker run -p 8000:8000 -e ICECAST_SOURCE_PASSWORD=aaaa -e ICECAST_ADMIN_PASSWORD=bbbb -e ICECAST_PASSWORD=cccc -e ICECAST_RELAY_PASSWORD=dddd <local music directory>:/opt/music alastairhm/docker-icecast
```


## License

[MIT](https://github.com/moul/docker-icecast/blob/master/LICENSE.md)
