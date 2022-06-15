# Scala and sbt Dockerfile

This repository contains **Dockerfile** of [Scala](http://www.scala-lang.org) and [sbt](http://www.scala-sbt.org).


## DockerHub

As we think referencing unstable versions is a bad idea we don't publish a `latest` tag

For a list of all available tags see https://hub.docker.com/r/sbtscala/scala-sbt/tags

Older tags are available at: https://hub.docker.com/r/hseeberger/scala-sbt/tags

## Base Docker Image ##

* [openjdk](https://hub.docker.com/_/openjdk)


## Installation ##

1. Install [Docker](https://www.docker.com)
2. Pull [automated build](https://hub.docker.com/r/sbtscala/scala-sbt/) from public [Docker Hub Registry](https://registry.hub.docker.com):
```
docker pull sbtscala/scala-sbt:17.0.2_1.6.2_3.1.2
```
Alternatively, you can build an image from Dockerfile:
(debian):
```
docker build \
  --build-arg BASE_IMAGE_TAG="17.0.2-jdk-bullseye" \
  --build-arg SBT_VERSION="1.6.2" \
  --build-arg SCALA_VERSION="2.13.8" \
  --build-arg USER_ID=1001 \
  --build-arg GROUP_ID=1001 \
  -t sbtscala/scala-sbt \
  github.com/sbt/docker-sbt.git#:debian
```

## Usage ##

```
docker run -it --rm sbtscala/scala-sbt:17.0.2_1.6.2_3.1.2
```

### Alternative commands ###
The container contains `bash`, `scala` and `sbt`.

```
docker run -it --rm sbtscala/scala-sbt:17.0.2_1.6.2_3.1.2 scala
```

### Non-root ###
The container is prepared to be used with a non-root user called `sbtuser`

```
docker run -it --rm -u sbtuser -w /home/sbtuser sbtscala/scala-sbt:17.0.2_1.6.2_3.1.2
```

## Contribution policy ##

Contributions via GitHub pull requests are gladly accepted from their original author. Along with any pull requests, please state that the contribution is your original work and that you license the work to the project under the project's open source license. Whether or not you state this explicitly, by submitting any copyrighted material via pull request, email, or other means you agree to license the material under the project's open source license and warrant that you have the legal authority to do so.


## License ##

This code is open source software licensed under the [Apache 2.0 License]("http://www.apache.org/licenses/LICENSE-2.0.html").
