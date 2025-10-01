#
# Scala, sbt and docker engine Dockerfile
#
# https://github.com/kamilkloch/scala-sbt-docker
#

# Pull base image
ARG BASE_IMAGE_TAG
FROM eclipse-temurin:${BASE_IMAGE_TAG:-25_36-jdk-jammy}

# Env variables
ARG SCALA_VERSION
ENV SCALA_VERSION=${SCALA_VERSION:-3.7.3}
ARG SBT_VERSION
ENV SBT_VERSION=${SBT_VERSION:-1.11.6}
ARG DOCKER_VERSION
ENV DOCKER_VERSION=${DOCKER_VERSION:-5:28.4.0-1~ubuntu.22.04~jammy}
ARG USER_ID
ENV USER_ID=${USER_ID:-1001}
ARG GROUP_ID
ENV GROUP_ID=${GROUP_ID:-1001}

# Install dependencies
# curl for downloading sbt and scala
# git and rpm for sbt-native-packager (see https://github.com/sbt/docker-sbt/pull/114)
RUN \
  apt-get update && \
  apt-get install -y curl git rpm && \
  rm -rf /var/lib/apt/lists/*

# Install sbt
RUN \
  curl -fsL --show-error "https://github.com/sbt/sbt/releases/download/v$SBT_VERSION/sbt-$SBT_VERSION.tgz" | tar xfz - -C /usr/share && \
  chown -R root:root /usr/share/sbt && \
  chmod -R 755 /usr/share/sbt && \
  ln -s /usr/share/sbt/bin/sbt /usr/local/bin/sbt

# Install Scala
RUN \
  case $SCALA_VERSION in \
    2.*) URL=https://downloads.typesafe.com/scala/$SCALA_VERSION/scala-$SCALA_VERSION.tgz SCALA_DIR=/usr/share/scala-$SCALA_VERSION ;; \
    *) URL=https://github.com/scala/scala3/releases/download/$SCALA_VERSION/scala3-$SCALA_VERSION.tar.gz SCALA_DIR=/usr/share/scala3-$SCALA_VERSION ;; \
  esac && \
  curl -fsL --show-error $URL | tar xfz - -C /usr/share/ && \
  mv $SCALA_DIR /usr/share/scala && \
  chown -R root:root /usr/share/scala && \
  chmod -R 755 /usr/share/scala && \
  ln -s /usr/share/scala/bin/* /usr/local/bin && \
  mkdir -p /test && \
  case $SCALA_VERSION in \
    2*) echo "println(util.Properties.versionMsg)" > /test/test.scala ;; \
    *) echo 'import java.io.FileInputStream;import java.util.jar.JarInputStream;val scala3LibJar = classOf[CanEqual[_, _]].getProtectionDomain.getCodeSource.getLocation.toURI.getPath;val manifest = new JarInputStream(new FileInputStream(scala3LibJar)).getManifest;val ver = manifest.getMainAttributes.getValue("Implementation-Version");@main def main = println(s"Scala version ${ver}")' > /test/test.scala ;; \
  esac && \
  scala -nocompdaemon test/test.scala && \
  rm -fr test \

# Install git and rpm for sbt-native-packager (see https://github.com/sbt/docker-sbt/pull/114)
RUN \
  apt-get update && \
  apt-get install git -y && \
  apt-get install rpm -y

# Install docker
RUN \
  apt-get update && apt-get install -y ca-certificates gnupg && \
  mkdir -p /etc/apt/keyrings && \
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
  echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
  apt-get update && \
  apt-get -y install docker-ce=$DOCKER_VERSION docker-ce-cli=$DOCKER_VERSION containerd.io docker-compose-plugin && \
  rm -rf /var/lib/apt/lists/*

# Symlink java to have it available on sbtuser's PATH
RUN ln -s /opt/java/openjdk/bin/java /usr/local/bin/java

# Add and use user sbtuser
RUN groupadd --gid $GROUP_ID sbtuser && useradd -m --gid $GROUP_ID --uid $USER_ID sbtuser --shell /bin/bash
USER sbtuser

# Switch working directory
WORKDIR /home/sbtuser

# Prepare sbt (warm cache)
RUN \
  sbt --script-version && \
  mkdir -p project && \
  echo "scalaVersion := \"${SCALA_VERSION}\"" > build.sbt && \
  echo "sbt.version=${SBT_VERSION}" > project/build.properties && \
  echo "// force sbt compiler-bridge download" > project/Dependencies.scala && \
  echo "case object Temp" > Temp.scala && \
  sbt compile && \
  rm -r project && rm build.sbt && rm Temp.scala && rm -r target

# Link everything into root as well
# This allows users of this container to choose, whether they want to run the container as sbtuser (non-root) or as root
USER root
RUN \
  rm -rf /tmp/..?* /tmp/.[!.]* * && \
  ln -s /home/sbtuser/.cache /root/.cache && \
  ln -s /home/sbtuser/.sbt /root/.sbt && \
  if [ -d "/home/sbtuser/.ivy2" ]; then ln -s /home/sbtuser/.ivy2 /root/.ivy2; fi

# Switch working directory back to root
## Users wanting to use this container as non-root should combine the two following arguments
## -u sbtuser
## -w /home/sbtuser
WORKDIR /root

CMD ["sbt"]