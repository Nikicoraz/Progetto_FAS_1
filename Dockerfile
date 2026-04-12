FROM alpine
RUN apk update && apk add curl bash python3

WORKDIR /progetto
COPY ./bash ./bash

# Uso workdir al posto di cd && <comando> per poter mettere in cache le fasi dello script
WORKDIR /progetto/bash
RUN "./dataset.sh" download
RUN "./dataset.sh" prepare

WORKDIR /progetto
COPY --exclude=venv ./python ./python

WORKDIR /progetto/python

# Installazione delle dipendenze di python
RUN "bash" "-c" "python3 -m venv ./venv && source ./venv/bin/activate && pip install -r requirements.txt"

EXPOSE 8888

ENTRYPOINT ["/bin/bash", "-c", "source ./venv/bin/activate && jupyter notebook Analisi.ipynb --allow-root --ip=0.0.0.0 --no-browser"]
