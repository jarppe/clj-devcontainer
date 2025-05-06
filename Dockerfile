FROM debian:12-slim AS base

ARG TARGETARCH

RUN \
  apt update -q                                                                    && \
  apt install -qy --no-install-recommends                                          \
    ca-certificates                                                                \
    apt-transport-https                                                            \
    lsb-release                                                                    \
    binutils                                                                       \
    procps                                                                         \
    zsh                                                                            \
    sudo                                                                           \
    gnupg                                                                          \
    openssh-client                                                                 \
    inetutils-ping                                                                 \
    curl                                                                           \
    vim                                                                            \
    jq                                                                             \
    yq                                                                             \
    git                                                                            \
    file                                                                           \
    fd-find                                                                        \
    bat                                                                            \
    direnv                                                                         && \
  ln -s /usr/bin/batcat /usr/local/bin/bat                                         && \
  apt upgrade -y

#
# tini:
#

RUN \
  TINI_VERSION=$(curl -sSLf "https://api.github.com/repos/krallin/tini/releases/latest" | jq -r ".tag_name")   && \
  curl -sSLf "https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-${TARGETARCH}"            \
    > /bin/tini                                                                                                && \
  chmod +x /bin/tini

#
# User:
#

ARG USER=dev

RUN \
  groupadd --gid 1000 ${USER}                                                      && \
  useradd  --gid 1000                                                              \
           --uid 1000                                                              \
           --groups sudo                                                           \
           --create-home                                                           \
           --home-dir /home/${USER}                                                \
           --shell /bin/zsh                                                        \
           ${USER}                                                                 && \
  echo "%sudo ALL=(ALL:ALL) NOPASSWD:ALL" >> /etc/sudoers                          && \
  install -g ${USER} -o ${USER} -d                                                 \
     /home/${USER}/.local                                                          \
     /home/${USER}/.local/bin

WORKDIR /home/${USER}
ENV USER=${USER}
ENV HOME=/home/${USER}
ENV PATH=$PATH:/home/${USER}/.local/bin/

#
# Install Java:
#

ARG JAVA_VERSION=24

RUN \
  echo "Installing Java $JAVA_VERSION..."                                             && \
  curl -sSLf https://packages.adoptium.net/artifactory/api/gpg/key/public             \
    | gpg --dearmor -o /etc/apt/trusted.gpg.d/temurin.gpg                             && \
    echo "deb https://packages.adoptium.net/artifactory/deb" $(lsb_release -cs) "main"  \
    | tee /etc/apt/sources.list.d/adoptium.list                                       && \
  apt update -q                                                                       && \
  apt install -qy --no-install-recommends                                             \
    temurin-${JAVA_VERSION}-jdk                                                       && \
  java --version

#
# Maven:
#

RUN \
  apt install -qy --no-install-recommends maven                                    && \
  mvn --version

#
# Clojure:
#

RUN \
  RELEASE=$(curl -sSLf "https://api.github.com/repos/clojure/brew-install/releases/latest" | jq -r ".tag_name") && \
  apt install -y rlwrap                                                            && \
  curl -sSLf https://github.com/clojure/brew-install/releases/download/${RELEASE}/posix-install.sh \
    | bash -

#
# Babashka:
#

RUN \
  RELEASE=$(curl -sSLf "https://api.github.com/repos/babashka/babashka/releases/latest" | jq -r ".tag_name[1:]")                         && \
  case $(uname -m) in                                                              \
    aarch64) ARCH=aarch64;;                                                        \
    x86_64)  ARCH=amd64;;                                                          \
    *) echo "Unknown CPU: $(uname -m)"; exit 1;;                                   \
  esac                                                                             && \
  curl -sSLf "https://github.com/babashka/babashka/releases/download/v${RELEASE}/babashka-${RELEASE}-linux-${ARCH}-static.tar.gz"  \
    | tar xzCf $HOME/.local/bin -                                                  && \
  bb --version

#
# fzf - The debian package for fzf is very old
#

RUN \
  RELEASE=$(curl -sSLf "https://api.github.com/repos/junegunn/fzf/releases/latest" | jq -r ".tag_name[1:]") && \
  curl -sSLf "https://github.com/junegunn/fzf/releases/download/v${RELEASE}/fzf-${RELEASE}-linux_${TARGETARCH}.tar.gz" \
    | tar -C /usr/local/bin -xzf - fzf

#
# Misc utils:
#

RUN \
  apt install -y                                                                   \
    silversearcher-ag

#
# Workspace:
#

USER ${USER}

# Download clojure core libs and Calva requirements:

RUN \
  clojure -Sdeps '{:deps {nrepl/nrepl {:mvn/version "1.3.0"} cider/cider-nrepl {:mvn/version "0.50.2"}}}' -P

# In stall dotfiles and installation helpers:

COPY  --chown=1000:1000  dotfiles/*         /home/${USER}
COPY  --chown=1000:1000  install-scripts/*  /home/${USER}/.local/bin/

ENTRYPOINT ["/bin/tini", "--"]
CMD ["/bin/zsh"]
