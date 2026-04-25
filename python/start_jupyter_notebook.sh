#!/bin/bash

RUN_DIRECTORY=python

if [ "$(basename "$(pwd)")" != "$RUN_DIRECTORY" ]; then
    echo "Please run this script inside the python directory"
    exit 1
fi

if ! source ./venv/bin/activate; then
    echo "venv not found, creating..."
    if ! python3 -m venv venv; then
        echo "Python was not found, exiting..."
        exit 1
    fi
fi


if ! jupyter-notebook Analisi.ipynb; then
    echo -n "Jupyter notebook was not found, do you want to try to install the python dependencies? [y/N]: "
    read -r input

    if [[ $input =~ ^[yY]$ ]]; then
        pip install -r requirements.txt
        jupyter-notebook Analisi.ipynb
    fi
fi
