#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

DATASET_URL="https://www.kaggle.com/api/v1/datasets/download/nalisha/github-top-repositories-dataset-starred-project"

DOMAINS_DIR="$DATA_DIR/domains"
DATA_DIR="../data"

ZIP_FILE="$DATA_DIR/github_top_repositories.zip"
CSV_FILE="${ZIP_FILE//.zip/.csv}"


function download_dataset() {
    if ! [ -d "$DATA_DIR" ]; then
        mkdir "$DATA_DIR"
    fi

    if [ -f "$CSV_FILE" ]; then
        echo "CSV file present, skipping download"
        return 0
    fi

    if ! [ -f "$ZIP_FILE" ]; then
        curl -L -o "$ZIP_FILE" "$DATASET_URL"
    fi

    unzip "$ZIP_FILE" -d "$DATA_DIR"
    rm "$ZIP_FILE"
}

function prepare_dataset() {
    if ! [ -d "$DOMAINS_DIR" ]; then
        mkdir "$DOMAINS_DIR"
    else
        # Remove existing files since the script uses append mode
        rm "$DOMAINS_DIR/"*
    fi

    # Add csv header without the domain to the files
    header="$(head -n 1 "$CSV_FILE" | cut -d "," -f 2-)"

    progress=0
    # Number of lines without counting the csv header
    total=$(( "$(wc -l "$CSV_FILE" | cut -d " " -f 1)" - 1 ))
    while read -r line
    do
        domain="$(echo "$line" | cut -d "," -f 1)"
        line="$(echo "$line" | cut -d "," -f 2-)"
        file="$DOMAINS_DIR/$domain.csv"
        if ! [ -f "$file" ]; then
            touch "$file"
            echo "$header" >> "$file"
        fi
        echo "$line" >> "$file"

        progress=$(( progress + 1 ))

        # Print progress bar
        echo -ne "Preparing dataset: $progress/$total\r"
    done < <(cat "$CSV_FILE" | tail -n +2)
}

function clean() {
    rm -r "$DATA_DIR"
    echo "Dataset directory removed"
}

if [ $(basename $(pwd)) != "bash" ]; then
    echo "Please execute the dataset script inside the bash directory"
    exit 1
fi

# If no arguments are passed, execute all steps except clean
if [ $# -eq 0 ]; then
    download_dataset
    prepare_dataset
else
    if [ "$1" == "download" ]; then
        download_dataset
    elif [ "$1" == "prepare" ]; then
        prepare_dataset
    elif [ "$1" == "clean" ]; then
        clean
    else
        echo "Usage ./dataset.sh COMMAND"
        echo "COMMAND is one of download, prepare, clean"
    fi
fi
