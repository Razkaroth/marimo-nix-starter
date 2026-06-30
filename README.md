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
- Official [marimo skills](https://github.com/marimo-team/skills) included in `.agents/` for AI-assisted development

## Agent Skills

This repo ships with 10 official marimo skills in `.agents/skills/` for AI coding assistants (OpenCode, Claude Code, Cursor, etc.):

| Skill | Description |
|---|---|
| `marimo-notebook` | Write marimo notebooks in correct format |
| `marimo-batch` | Prepare notebook for scheduled runs |
| `jupyter-to-marimo` | Convert .ipynb to marimo |
| `streamlit-to-marimo` | Convert Streamlit app to marimo |
| `anywidget-generator` | Generate anywidget components |
| `wasm-compatibility` | Check WASM compatibility |
| `implement-paper` | Implement research paper as notebook |
| `implement-paper-auto` | Auto-implement paper |
| `auto-paper-demo` | Auto-demo a paper |
| `add-molab-badge` | Add "Open in molab" badges |

Install via the skills CLI: `npx skills add marimo-team/skills`

## Getting Started

1. Clone the repository

```bash
git clone https://github.com/razkarot/marimo-nix-starter.git --depth 1 
```

2. Enter the environment

```bash
nix develop
```

Alternatively you can install the environment using uv or pip:
Create an environment
```bash
python -m venv .venv
```
Install dependencies
```bash
uv pip install -r requirements.txt # or pip install -r requirements.txt
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
docker run -p 7860:7860 marimo-nix-starter
```

4. ????

5. Profit


