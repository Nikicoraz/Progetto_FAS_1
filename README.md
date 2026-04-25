# Analisi delle repository più popolari di github
Questo progetto ha l'obbiettivo di effetturare alcune analisi sul seguente [dataset](https://www.kaggle.com/api/v1/datasets/download/nalisha/github-top-repositories-dataset-starred-project) riguardo le repository più popolari di github, suddivise in base al loro dominio.

Il progetto quindi ha quattro componenti:

- Bash
- Python
- Docker
- Ansible

Lo sviluppo del progetto è stato versionato tramite git

## Bash
Il progetto mette a disposizione uno script bash per scaricare e preparare il dataset per le analisi in python.

La preparazione del dataset si occupa di suddividere il file csv principale in tanti file csv, quanti sono i vari domini delle repository.
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

Le dipendenze dello script possono essere installate tramite il playbook ansible
