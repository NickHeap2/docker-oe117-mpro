# docker-oe117-mpro

Docker image for running mpro sessions

## docker commands

### Build the docker image

```bash
docker build -t oe117-mpro:0.1 -t oe117-mpro:latest .
```

### Run the container

```bash
docker run -it --rm --name oe117-mpro oe117-mpro:latest
```

### Run the container with a mapped volume for code and pass in propath and startup proc

```bash
docker run -it --rm --name oe117-mpro -v D:/workspaces/mpro:/var/lib/openedge/code -v D:/workspaces/mpro/logs:/usr/wrk -e PROPATH=".:src" -e MPRO_STARTUP=" -b -p server.p -pf dbconfig.pf" -e LOCK_FILE="server.lck" oe117-mpro:latest
```

### Exec bash in the running container

```bash
docker exec -it oe117-mpro bash
```

### Stop the container

```bash
docker stop oe117-mpro
```

### Clean the container

```bash
docker rm oe117-mpro
```
