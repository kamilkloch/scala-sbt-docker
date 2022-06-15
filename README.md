# Scala, sbt and Docker Engine Dockerfile
Based on [sbt/docker-sbt](https://github.com/sbt/docker-sbt).

This repository contains **Dockerfile** of [Scala](http://www.scala-lang.org), [sbt](http://www.scala-sbt.org) and a Docker Engine.
Basically, a [sbt/docker-sbt](https://github.com/sbt/docker-sbt) plus `docker-cli` and `docker-compose`.

## DockerHub
For a list of all available tags see https://hub.docker.com/repository/docker/kamilkloch/scala-sbt-docker/tags

## Base Docker Image ##
* [eclipse-temurin](https://hub.docker.com/_/eclipse-temurin)

## Installation ##
1. Install [Docker](https://www.docker.com)
2. Pull the [image](https://hub.docker.com/repository/docker/kamilkloch/scala-sbt-docker) from public [Docker Hub Registry](https://registry.hub.docker.com):
```
docker pull kamilkloch/scala-sbt-docker:eclipse-temurin-17.0.2_1.6.2_2.13.8_20.10.16
```

## Usage ##
```
docker run -it --rm sbtscala/scala-sbt:17.0.2_1.6.2_3.1.2
```

Alternatively, you can bulid an image from Dockerfile:

```
docker build \
  --build-arg BASE_IMAGE_TAG="17.0.2_8-jdk-focal" \
  --build-arg SBT_VERSION="1.6.2" \
  --build-arg SCALA_VERSION="2.13.8" \
  --build-arg DOCKER_VERSION="5:20.10.16~3-0~ubuntu-focal" \
  --build-arg USER_ID=1001 \
  --build-arg GROUP_ID=1001 \
  -t kamilkloch/scala-sbt-docker:eclipse-temurin-17.0.2_1.6.2_2.13.8_20.10.16 .
```

### Alternative commands ###
The container contains `bash`, `scala`, `sbt`, `docker` and `docker compose`.

```
docker run -it --rm kamilkloch/scala-sbt-docker:eclipse-temurin-17.0.2_1.6.2_2.13.8_20.10.16 scala
```

### Non-root ###
The container is prepared to be used with a non-root user called `sbtuser`

```
docker run -it --rm -u sbtuser -w /home/sbtuser kamilkloch/scala-sbt-docker:eclipse-temurin-17.0.2_1.6.2_2.13.8_20.10.16
```

## License ##

This code is open source software licensed under the [Apache 2.0 License]("http://www.apache.org/licenses/LICENSE-2.0.html").
