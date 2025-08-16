FROM debian:13-slim

ARG TARGETARCH

#
# Installation tools:
#


RUN \
  apt update -q                                                                    && \
  apt install -qy --no-install-recommends                                          \
    ca-certificates                                                                \
    apt-transport-https                                                            \
    lsb-release                                                                    \
    binutils                                                                       \
    procps                                                                         \
    gnupg                                                                          \
    curl                                                                           \
    jq


#
# tini:
#

RUN \
  TINI_VERSION=$(curl -sSLf "https://api.github.com/repos/krallin/tini/releases/latest" | jq -r ".tag_name")   && \
  curl -sSLf "https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-${TARGETARCH}"            \
    > /bin/tini                                                                                                && \
  chmod +x /bin/tini


#
# Install Java and Maven:
#


ARG JAVA_VERSION=24

RUN \
  echo "Installing Java $JAVA_VERSION..."                                          && \
  curl -sSLf https://packages.adoptium.net/artifactory/api/gpg/key/public          \
    | gpg --dearmor -o /etc/apt/trusted.gpg.d/temurin.gpg                          && \
  echo "deb https://packages.adoptium.net/artifactory/deb" $(lsb_release -cs) "main"  \
    > /etc/apt/sources.list.d/adoptium.list                                        && \
  apt update -q                                                                    && \
  apt install -qy --no-install-recommends                                          \
    temurin-${JAVA_VERSION}-jdk                                                    \
    maven                                                                          && \
  java --version                                                                   && \
  mvn --version


#
# Clojure:
#


RUN \
  RELEASE=$(curl -sSLf "https://api.github.com/repos/clojure/brew-install/releases/latest" | jq -r ".tag_name")  && \
  curl -sSLf https://github.com/clojure/brew-install/releases/download/${RELEASE}/posix-install.sh               \
    | bash -


#
# Babashka:
#


RUN \
  RELEASE=$(curl -sSLf "https://api.github.com/repos/babashka/babashka/releases/latest" | jq -r ".tag_name[1:]")                         && \
  case ${TARGETARCH} in                                                            \
    arm64) ARCH=aarch64;;                                                          \
    amd64) ARCH=amd64;;                                                            \
    *) echo "Unknown CPU: ${TARGETARCH}"; exit 1;;                                 \
  esac                                                                             && \
  curl -sSLf "https://github.com/babashka/babashka/releases/download/v${RELEASE}/babashka-${RELEASE}-linux-${ARCH}-static.tar.gz"  \
    | tar xzCf /usr/local/bin -                                                    && \
  bb --version


#
# fzf - The debian package for fzf is very old
#


RUN \
  RELEASE=$(curl -sSLf "https://api.github.com/repos/junegunn/fzf/releases/latest" | jq -r ".tag_name[1:]")            && \
  curl -sSLf "https://github.com/junegunn/fzf/releases/download/v${RELEASE}/fzf-${RELEASE}-linux_${TARGETARCH}.tar.gz" \
    | tar -C /usr/local/bin -xzf - fzf


#
# Misc utils:
#


RUN \
  apt install -qy --no-install-recommends                                          \
    vim                                                                            \
    openssh-client                                                                 \
    inetutils-ping                                                                 \
    zsh                                                                            \
    yq                                                                             \
    git                                                                            \
    file                                                                           \
    fd-find                                                                        \
    bat                                                                            \
    direnv                                                                         \
    httpie                                                                         \
    rlwrap                                                                         \
    silversearcher-ag                                                              && \
  ln -s /usr/bin/batcat /usr/local/bin/bat


#
# Download clojure core libs and Calva requirements:
#


RUN \
  clojure -Sdeps '{:deps {nrepl/nrepl {:mvn/version "1.3.0"} cider/cider-nrepl {:mvn/version "0.50.2"}}}' -P


# In stall dotfiles and installation helpers:


COPY  dotfiles/*         /root
COPY  install-scripts/*  /usr/local/bin


#
# Entrypoint and command:
#


WORKDIR /root/workspace
ENTRYPOINT ["/bin/tini", "--"]
CMD ["/bin/zsh"]
