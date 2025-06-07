Based on the work of [Miklevin](https://github.com/miklevin/python_nix_flake).

# Marimo Nix Starter

This is a starter project for building a Marimo app using Nix.

It uses uv to manage dependencies and bootstraps a marimo multi-page app via FastAPI + Docker.

The idea is to work locally with marimo and then deploy to the cloud to share results/tools as a container. 

## Features

- Multi-page marimo app when containerized (see [Deploying](#deploying))
- Python 3.13
- uv for dependency management
- Nix flakes for development environment - Credit to [Miklevin](https://github.com/miklevin/python_nix_flake)

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
start
```

4. Stop the app

```bash
stop
```



## Deploying

This works by serving a asgi app via fastapi. `main.py` is the entrypoint for the app.

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
