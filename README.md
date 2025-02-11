# Chrono Docker

This repo demonstrates how to build a docker image which builds [Chrono](https://projectchrono.org). You need to download the [OptiX 7.7 installation script](https://developer.nvidia.com/designworks/optix/downloads/legacy) and place it at `./docker/data`.

## Usage

First, build the images with the following command.

```bash
docker compose build
```

Then start up the containers in the background. This will start the `dev` and `vnc` services.

```bash
docker compose up -d chrono vnc
```

And finally, enter the `dev` docker container. Any GUI visualization should be visible at [http://localhost:8080]().

```bash
docker compose exec dev /bin/bash
```

## License

📝 **Note:** This repository was created using the [docker-compose-template](https://github.com/AaronYoung5/docker-compose-template).  
