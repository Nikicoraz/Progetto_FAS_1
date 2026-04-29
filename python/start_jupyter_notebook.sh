#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

RUN_DIRECTORY=python
VENV=venv
NOTEBOOK=Analisi.ipynb

if [ "$(basename "$(pwd)")" != "$RUN_DIRECTORY" ]; then
    echo "Please run this script inside the python directory"
    exit 1
fi

# Attivazione e/o creazione venv
if ! source ./$VENV/bin/activate; then
    echo "venv not found, creating..."
    if ! python3 -m venv $VENV; then
        echo "Python or the venv module was not found, exiting..."
        exit 1
    else
        source ./$VENV/bin/activate
    fi
fi

# Installazione e avvio jupyter
if ! jupyter-notebook $NOTEBOOK; then
    echo -n "Jupyter notebook was not found, do you want to try to install the python dependencies? [y/N]: "
    read -r input

    if [[ $input =~ ^[yY]$ ]]; then
        pip install -r requirements.txt
        jupyter-notebook $NOTEBOOK
    fi
fi
