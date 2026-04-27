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
Le dipendenze principali sono:

- `pandas`: leggere file csv
- `matplotlib`: generare grafici
- `ipywidgets`: rendere i grafici interattivi con widget
- `jupyter`: notebook e interfaccia web

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

## Docker
Il progetto mette a disposizione anche un Dockerfile con cui si può creare un'immagine docker con un'istanza di Jupyter per poter visualizzare il contenuto del Jupyter notebook.

L'immagine può essere compilata con il comando:
```
docker build -t local/top_github .
```

e eseguita con il comando:
```
docker run --rm -p 8888:8888 local/top_github
```

infine, per accedere all'interfaccia web, occorre accedere con il link che contiene il token di accesso che viene stampato su `stdout` all'avvio dell'immagine.

Alternativamente, si può de-commentare l'ultima riga del Dockerfile per togliere l'accesso tramite token, e quindi per accedere si può semplicemente navigare all'url `http://localhost:8888`.

### Dettagli sull'immagine

I file del dataset nel container sono scaricati direttamente nell'immagine, e non montati come volume, per cui ogni modifica al notebook tramite l'interfaccia web fornita dal container non è persistente.

Il build dell'immagine docker è suddivisa in due stage, uno per scaricare e preparare il dataset e uno per scaricare le dipendenze di Python.

La suddivisione è fatta per ottenere un'immagine finale più piccola, in quanto non contiene le dipendenze bash o comunque file non utilizzati dal notebook, ma soprattutto per poter parallelizzare la preparazione del dataset e il download delle dipendenze di Python in quanto sono i passaggi che richiedono più tempo.

### Docker compose

Per comodità, è messo a disposizione anche un file `docker-compose.yml` in cui è specificato di fare il build dell'immagine e di fare il port-forwarding della porta 8888 del container sulla porta 8888 dell'host.

Per avviare il file docker compose si può utilizzare il comando
```
docker compose up
```
## Ansible
Nel progetto è presente un playbook ansible, diviso in due role, che assicura che il sistema abbia tutte le dipendenze per eseguire il progetto.

Il primo role si chiama `bootstrap` e si occupa di installare python negli host nel gruppo `new`. Questo sia per poter utilizzare la parte di python del progetto, sia per eseguire poi il secondo role siccome per eseguire i moduli ansible è richiesto python.

Il secondo role si chiama `install_packages` e si assicura che tutte le dipendenze per poter utilizzare il progetto siano installate.

Di default, nel file di inventario è impostato solo l'host `localhost`, però contiene anche un esempio di configurazione commentato per un altro host.
Per eseguire il playbook ansible (all'interno della cartella `./ansible/`) si può utilizzare il comando:
```
ansible-playbook -i inventory.ini playbook.yml
```
