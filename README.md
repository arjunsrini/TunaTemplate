# TunaTemplate

A simplified version of [`gentzkow/template`](https://github.com/gentzkow/template).

In honor of Tuna 🍣 🐈

### Setup

1. `Use this template` to create your own repo. For more info, see [this](https://docs.github.com/en/repositories/creating-and-managing-repositories/creating-a-repository-from-a-template).

2. At the root of your repo, create a file called `config.yaml` with contents like the file `setup/example_config.yaml`.

3. To build the whole project, type `make` from the root of the repo. To build an a submodule (e.g. `analysis`), type `make` while your current working directory is `your-path-to-repo/analysis`.

### Notes

#### `shmake`

Included as a git submodule, this is a shell version of [`gslab_make`](https://github.com/gslab-econ/gslab_make).

