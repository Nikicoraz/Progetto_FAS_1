# Fase di build in cui viene eseguito lo script bash, quindi si occupa di scaricare e preparare il dataset
FROM alpine AS bash
RUN apk --no-cache add curl bash

WORKDIR /progetto
COPY ./bash ./bash

WORKDIR /progetto/bash
RUN "./dataset.sh" download
RUN "./dataset.sh" prepare

# Build dell'immagine finale che quindi eseguirà il notebook Jupyter
FROM alpine
RUN apk add --no-cache python3

WORKDIR /progetto/python
# Copio solo il file requirements per cachare solo le dipendenze, quindi aggiornando il notebook jupyter non serve riscaricare tutte le dipendenze
COPY --exclude=venv ./python/requirements.txt .

# Installazione delle dipendenze di python prima della copia dall'altro stage per parallelizzare l'installazione di dipendenze
RUN "sh" "-c" "python3 -m venv ./venv && source ./venv/bin/activate && pip install -r requirements.txt"

COPY --exclude=venv ./python .
COPY --from=bash /progetto/data /progetto/data

EXPOSE 8888

# Usare questo entrypoint se non si vuole usare un token per accedere all'interfaccia web
# ENTRYPOINT ["/bin/sh", "-c", "source ./venv/bin/activate && jupyter notebook Analisi.ipynb --allow-root --ip=0.0.0.0 --no-browser --NotebookApp.token='' --NotebookApp.password=''"]
ENTRYPOINT ["/bin/sh", "-c", "source ./venv/bin/activate && jupyter notebook Analisi.ipynb --allow-root --ip=0.0.0.0 --no-browser"]
