# Jarppe's devcontainer for Clojure development

This repository builds a [devcontainer](https://containers.dev/) image for [Clojure](https://clojure.org/) development. The image contains recent Java (currently Java 23) and Clojure command-line tools from most recent release.

The image tag is `jarppe/clj-devcontainer:latest` and is built for `linux/arm64` and `linux/adm64` targets.

To keep the image size in reasonable small, the image does not contain all tools I use. Instead the image has installation scripts to install the tools, like:

- Babashka
- Docker CLI
- kubectl and krew
- Helm
- PostgreSQL CLI (version 17)
- Redis CLI
- K6

For example, to install postgres CLI, run this in devcontainer shell:

```bash
$ install-postgres-cli
```

## Kubernetes helper

The [devc](./devc) helper is a Babashka script that helps working with devcontainers in Kubernetes.

```bash
$ ./devc -h
usage: devc <command> <pod-name> <args>
command:
  up      Start devcontainer
  down    Stop devcontainer
  ps      List devcontainers
  sh      Open shell in devcontainer pod
pod-name:
  Name of the devcontainer pod, defaults to "jarppe"
args:
  -h,   --help                                     Show usage
  -ctx, --context   test:eu-west-1                 Kube context (default from kubectl config)
  -ns,  --namespace review-4259                    Kube namespace (default from kubectl config)
  -pod, --pod       jarppe                         Devcontainer pod name ($CLJ_DEVCONTAINER_POD_NAME or username)
  -c,   --container jarppe                         Container name ($CLJ_DEVCONTAINER_CONTAINER_NAME or pod name)
  -i,   --image     jarppe/clj-devcontainer:latest Devcontainer image ($CLJ_DEVCONTAINER_IMAGE or "jarppe/clj-devcontainer:latest")
```

Create devcontainer using defaults:

```bash
$ ./devc up
pod/jarppe created
```

At this point you can open remote devcontainer using your IDE. For example, this is how you do it on vscode:

- Run `Dev Containers: Reopen in container` command
- Select your devcontainer
- Start calva by `Calva: Start a project and Connect`

List devcontainers:

```bash
$ devc ps
NAME     READY   STATUS    RESTARTS   AGE
jarppe   1/1     Running   0          16s
```

Open shell in devcontainer:

```bash
$ devc sh
[review-4259/jarppe] ~
> whoami
jarppe
[review-4259/jarppe] ~
> uname -a
Linux jarppe 6.12.5-linuxkit #1 SMP Tue Jan 21 10:23:32 UTC 2025 aarch64 GNU/Linux
[review-4259/jarppe] ~
> java -version
openjdk version "23.0.2" 2025-01-21
OpenJDK Runtime Environment Temurin-23.0.2+7 (build 23.0.2+7)
OpenJDK 64-Bit Server VM Temurin-23.0.2+7 (build 23.0.2+7, mixed mode, sharing)
[review-4259/jarppe] ~
> clj --version
Clojure CLI version 1.12.0.1530
[review-4259/jarppe] ~
> ^D
```

Execute command on devcontainer:

```bash
$ devc sh ps aux
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
jarppe       1  0.0  0.0   2204  1004 ?        Ss   17:56   0:00 /tini -- sleep infinity
jarppe       6  0.0  0.0   2220  1148 ?        S    17:56   0:00 sleep infinity
jarppe       8  0.0  0.0   6156  4864 pts/0    Ss+  17:56   0:00 zsh -l
jarppe      69  0.0  0.0   8044  3812 ?        Rs   18:02   0:00 ps aux
```

Stop devcontainer:

```bash
$ devc down
pod "jarppe" deleted
```

## Build

To build this image yourself you need:

- [devcontainer CLI](https://github.com/devcontainers/cli)
- [babashka](https://github.com/babashka/babashka)

To build and push devcontainer image:

```bash
$ bb dist:push
```

## TODO

- Document how to run devcontainer in Docker
- Document how to create devcontainer with PV

## LICENSE

_TODO_
