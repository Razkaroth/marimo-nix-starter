---
title: Marimo multi-page starter app
emoji: 🍃
colorFrom: indigo
colorTo: purple
sdk: docker
pinned: true
license: mit
short_description: Template for internal tools 
---


# Marimo Nix Starter

This is a starter project for building a Marimo app using Nix.

It uses uv to manage dependencies and bootstraps a marimo multi-page app via FastAPI + Docker.

The idea is to work locally with marimo and then deploy to the cloud to share results/tools as a container. 

## Features

- Multi-page marimo app when containerized (see [Deploying](#deploying))
- Python 3.13
- uv for dependency management
- Nix flake for development environment - Credit to [Miklevin](https://github.com/miklevin/python_nix_flake)'s JupyterLab flake.

## Getting Started

1. Clone the repository

```bash
git clone https://github.com/razkarot/marimo-nix-starter.git --depth 1 
```

2. Enter the environment

```bash
nix develop
```

3. Run the app

```bash
marimo edit --watch
```



## Deploying

This works by serving a asgi app via fastapi. `main.py` is the entrypoint for the app.


### Hugging Face Spaces

Probably the easiest way to deploy is to use Hugging Face Spaces.


1. Create a Hugging Face Space and link it.

Once you have created a Hugging Face Space, you must add the repo as a remote to your local git repo.

```bash
git remote add hf https://huggingface.co/spaces/razkarot/marimo-nix-starter
```

2. Simply push your changes to the remote.

```bash
git push hf main
```

I ussually put both github and hugging face on the same remote so I can push to both on the same command.

### Docker

You can also build and run the container locally and push it to a container based cloud service.

1. Register pages in `main.py`

```python
.with_app(path="", root="./pages/index.py")
.with_app(path="/dashboard", root="./pages/dashboard.py")
```

2. Build the container

```bash
docker build -t marimo-nix-starter .
```

3. Run the container

```bash
docker run -p 8000:8000 marimo-nix-starter
```

4. ????

5. Profit


