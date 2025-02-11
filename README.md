# docker-compose-template

A template repository for simple docker-based linux development.

## Motivation

The purpose of this repo is to provide a quick and easy way to get started with docker compose for linux-based development _outside_ of web development. The idea is that docker is a great place to create extensible and reusable systems for groups of developers. It's difficult, though, to create a docker image/container which is flexible for many applications. This template repo provides a few mechanisms to improve the initial setup of a docker compose project for these purposes.

## Features

### Snippets

We introduce a notion of snippets, or small dockerfile components, which when combined with a base image and other snippets, create a full docker image. Snippets is (in theory) the only thing that is added for projects which derive from this template. To support these self contained snippets, we leverage [dockerfile-x](https://github.com/devthefuture-org/dockerfile-x), which adds support for an `INCLUDE` directive to include individual dockerfiles.

The default build workflow is as follows. Create a file titled `<service>.dockerfile` inside `docker/`. This file should contain the following:

```dockerfile
# syntax = devthefuture/dockerfile-x
# The INCLUDE directive is provided by the devthefuture/dockerfile-x project

# This does the initial setup for the other dockerfiles in the build system.
# This will also create a user with the same name as the service
INCLUDE ./docker/common/base.dockerfile

# Snippets
INCLUDE ./docker/snippets/micromamba.dockerfile

# == Add more snippets here ==
# == Add more snippets here ==
# == Add more snippets here ==

# This does final setup, such as setting shell properties and installing final dependencies
INCLUDE ./docker/common/common.dockerfile

# Sets the entrypoint and user
INCLUDE ./docker/common/final.dockerfile
```

> [!NOTE]
> The `INCLUDE` directive is sequential in that the following snippets will inherit changes made by previous snippets. The default user when running snippets is the newly created user.

### VNC

A common issue in the adopting of docker-based development is the lack of immediate support for GUI applications. Another feature of this template is the addition of a NoVNC service which is capable of directly visualizing windows from within other containers on the same host. This is enabled by attaching all containers which need to be visualized to the same network as the NoVNC service (defaults to the default docker compose network). Then, a port is exposed from the NoVNC service to the host machine, which can be accessed via a web browser (i.e., `http://localhost:8080`).

### User Permissions

One headache when creating docker containers is sharing files between the host and the container. For instance, a common issue is that the user in the container is often root, so files editted within the container will also be owned by root when accessed on the host. We fix this within `base.dockerfile` by accepting a `USER_UID` and `USER_GID` build argument (which both default to `1000`). We create a user within the container (defaults to the name of the project) with the given UID and GID with the intention that this will match the user on the host. This way, files created within the container will be owned by the user on the host.

## Limitations

- The image must be Debian based.

📝 **Note:** This repository was created using the [docker-compose-template](https://github.com/AaronYoung5/docker-compose-template).  