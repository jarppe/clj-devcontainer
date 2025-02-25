# Jarppe's devcontainer for Clojure development

This repository builds a [devcontainer](https://containers.dev/) image for [Clojure](https://clojure.org/) development. The image contains recent Java (currently Java 23), Clojure command-line tools, [Babashka](https://github.com/babashka/babashka), and a fairly large set of commonly used command-line tools, including:

- Docker CLI
- kubectl and krew
- Helm
- PostgreSQL CLI (version 17)
- Redis CLI
- K6
- ...

## Setup

To build this image yourself you need:

- [devcontainer CLI](https://github.com/devcontainers/cli)
- [kubectl](https://kubernetes.io/docs/reference/kubectl/kubectl/)
- [babashka](https://github.com/babashka/babashka)

To build and push devcontainer image:

```bash
$ bb dist:push
```

Create kubernetes resources:

```bash
$ bb kube:apply
```

Open shell to devcontainer:

```bash
$ bb kube:sh
```

Connect with vscode:

- Start vscode and run `Dev Containers: Reopen in container` command
- Select devcontainer
- Start calva by `Calva: Start a project and Connect`

## LICENSE

_TODO_
