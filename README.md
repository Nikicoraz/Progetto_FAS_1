# Analisi delle repository più popolari di github
Questo progetto ha l'obbiettivo di effetturare alcune analisi sul seguente [dataset](https://www.kaggle.com/datasets/nalisha/github-top-repositories-dataset-starred-project/) riguardo le repository più popolari di github, suddivise in base al loro dominio.

Il progetto quindi ha quattro componenti:

- Bash
- Python
- Docker
- Ansible

Lo sviluppo del progetto è stato versionato tramite git

## Bash
Il progetto mette a disposizione uno script bash per scaricare e preparare il dataset per le analisi in python.

La preparazione del dataset si occupa di suddividere il file csv principale in tanti file csv quanti sono i vari domini delle repository.
Lo script bash si trova nella cartella `./bash/dataset.sh` e ha due modalità di operazione:

- Senza argomenti: lo script esegue automaticamente il download e la preparazione del dataset
- Con argomenti: si possono utilizzare i seguenti argomenti:
    - `download`: scarica il dataset
    - `prepare`: prepara il dataset
    - `clean`: rimuove tutti i file scaricati e preparati

### Dipendenze
Lo script è stato scritto in modo di utilizzare gli strumenti più comuni presenti nei sistemi linux, quindi le sue dipendenze sono:

- `bash`
- `curl`: per scaricare il dataset
- `unzip`: per unzippare il dataset
- `cut`: per poter leggere le colonne singole del csv

Le dipendenze dello script possono essere installate (o verificate) tramite il playbook ansible.

## Python
Python viene utilizzato dentro al notebook Jupyter per effetturare delle analisi sul dataset.

Le dipendenze di python sono elencate dentro al file `./python/requirements.txt`.

Ci sono due modi per installare le dipendenze di python

### Tramite script
Il progetto mette a disposizione lo script `./python/start_jupyter_notebook.sh` che rileva se esiste un virtual environment con tutte le dipendenze installate, altrimenti le installa automaticamente

### Manualmente
Per installare le dipendenze occorre seguire i seguenti passaggi dentro alla cartella `./python`:

1. Creare un virtual environment
```
python -m venv venv
```

2. Attivare il virtual environment
```
source ./venv/bin/activate
```

3. Installare le dipendenze con pip
```
pip install -r requirements.txt
```

4. Avviare jupyter notebook
```
jupyter notebook Analisi.ipynb
```
