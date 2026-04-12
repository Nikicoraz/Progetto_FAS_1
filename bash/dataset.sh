#!/bin/bash

DATASET_URL="https://www.kaggle.com/api/v1/datasets/download/asifxzaman/developer-burnout-prediction-dataset7000-samples"
DATA_DIR="../data"
ZIP_FILE="$DATA_DIR/developer_burnout_dataset_7000.zip"
CSV_FILE="${ZIP_FILE//.zip/.csv}"

LOW_BURNOUT_FILE="$DATA_DIR/burnouts/low_burnout.csv"
MEDIUM_BURNOUT_FILE="${LOW_BURNOUT_FILE//low/medium}"
HIGH_BURNOUT_FILE="${LOW_BURNOUT_FILE//low/high}"

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
    if ! [ -d "$(dirname "$LOW_BURNOUT_FILE")" ]; then
        mkdir "$(dirname "$LOW_BURNOUT_FILE")"
    else
        if [ -f "$LOW_BURNOUT_FILE" ] && [ -f "$MEDIUM_BURNOUT_FILE" ] && [ -f "$HIGH_BURNOUT_FILE" ]; then
            echo "Dataset already prepared, using cached values"
            return 0
        fi
    fi

    # Create the burnout files, and truncate them if they exist
    truncate -s 0 "$LOW_BURNOUT_FILE"
    truncate -s 0 "$MEDIUM_BURNOUT_FILE"
    truncate -s 0 "$HIGH_BURNOUT_FILE"

    # Add csv header without the burnout level to the files
    header="$(head -n 1 "$CSV_FILE" | cut -d "," -f 1-11)"
    echo "$header" > "$LOW_BURNOUT_FILE"
    echo "$header" > "$MEDIUM_BURNOUT_FILE"
    echo "$header" > "$HIGH_BURNOUT_FILE"

    progress=0
    # Number of lines without counting the csv header
    total=$(( "$(wc -l "$CSV_FILE" | cut -d " " -f 1)" - 1 ))
    while read -r line
    do
        burnout="$(echo "$line" | cut -d "," -f 12)"
        line="$(echo "$line" | cut -d "," -f 1-11)"
        if [ "$burnout" == "Low" ]; then
            echo "$line" >> "$LOW_BURNOUT_FILE"
        elif [ "$burnout" == "Medium" ]; then
            echo "$line" >> "$MEDIUM_BURNOUT_FILE"
        elif [ "$burnout" == "High" ]; then
            echo "$line" >> "$HIGH_BURNOUT_FILE"
        fi
        progress=$(( progress + 1 ))

        # Print progress bar
        echo -ne "Preparing dataset: $progress/$total\r"
    done < <(cat "$CSV_FILE" | tail -n +2)
}

function clean() {
    rm -r "$DATA_DIR"
    echo "Dataset directory removed"
}

# If no arguments are passed, execute all steps
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
        echo "Usage ./dataset.sh command"
        echo "command is one of download, prepare, clean"
    fi
fi
