FROM debian:12-slim AS base

ARG TARGETARCH
ARG USER

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
    > /tini                                                                                                    && \
  chmod +x /tini

#
# fzf - The debian package for fzf is very old
#

RUN \
  RELEASE=$(curl -sSLf "https://api.github.com/repos/junegunn/fzf/releases/latest" | jq -r ".tag_name[1:]") && \
  curl -sSLf "https://github.com/junegunn/fzf/releases/download/v${RELEASE}/fzf-${RELEASE}-linux_${TARGETARCH}.tar.gz" \
    | tar -C /usr/local/bin -xzf - fzf

#
# Workspace:
#

RUN \
  groupadd --gid 1000 ${USER}                                                      && \
  useradd  --gid 1000                                                              \
           --uid 1000                                                              \
           --groups sudo                                                           \
           --create-home                                                           \
           --home-dir /home/${USER}                                                \
           --shell /bin/zsh                                                        \
           ${USER}                                                                 && \
  cat /etc/sudoers                                                                 \
    | sed -e 's/%sudo.*/%sudo ALL=(ALL:ALL) NOPASSWD:ALL/'                         \
    > /etc/sudoers

COPY  --chown=1000:1000   dotfiles/*          /home/${USER}
COPY  --chown=1000:1000   install-scripts/*   /home/${USER}/.local/bin/

WORKDIR /home/${USER}
USER ${USER}
ENV HOME=/home/${USER}

ENTRYPOINT ["/tini", "--"]
CMD ["/bin/zsh"]

FROM base AS clj

ARG TARGETARCH
ARG USER

RUN \
  PATH=$PATH:/home/${USER}/.local/bin/    && \
  install-java                            && \
  install-clojure
