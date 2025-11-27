update: update-submodules graph pdf

update-submodules:
    git submodule update --remote

graph:
    python update-git-graph.py

pdf:
    typst compile main.typ