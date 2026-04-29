# Analisi delle repository più popolari di Github
Il progetto ha l'obbiettivo di effettuare alcune analisi sul seguente [dataset](https://www.kaggle.com/datasets/nalisha/github-top-repositories-dataset-starred-project/) riguardo le repository con più stelle di Github, suddivise in base al loro dominio di sviluppo.

Il progetto è composto da quattro componenti:

- Bash
- Python
- Docker
- Ansible

Lo sviluppo del progetto è stato versionato tramite Git e una repository è disponibile su [Github](https://github.com/Nikicoraz/Progetto_FAS_1).

## Bash
Il progetto mette a disposizione uno script bash per scaricare e preparare il dataset per le analisi in Python.

La preparazione del dataset si occupa di suddividere il file csv del dataset intero in tanti file csv quanti sono i vari domini delle repository.
Lo script si trova nella cartella `./bash/dataset.sh` e ha due modalità di operazione:

- Senza argomenti: lo script esegue automaticamente il download e la preparazione del dataset
- Con argomenti: si possono utilizzare i seguenti argomenti:
    - `download`: scarica il dataset
    - `prepare`: prepara il dataset
    - `clean`: rimuove tutti i file scaricati e preparati

### Dipendenze
Lo script è stato scritto in modo di utilizzare gli strumenti più comuni presenti nei sistemi Linux, quindi le sue dipendenze sono:

- `bash`
- `curl`: per scaricare il dataset
- `unzip`: per estrarre il dataset scaricato in formato zip
- `cut`: per poter leggere le colonne singole del file csv

Nei sistemi minimali (come alpine linux), potrebbe essere necessario installare `bash`, `curl` e `unzip`.

Le dipendenze dello script possono essere installate (o verificate) tramite il playbook Ansible.

## Python
Python viene utilizzato, tramite notebook Jupyter, per effettuare analisi sul dataset.

### Dipendenze
Le dipendenze di Python sono elencate nel file `./python/requirements.txt` e vengono installate tramite `pip`. Questa scelta è stata fatta perché il progetto non è sufficientemente grande o complesso da giustificare l’uso di strumenti più avanzati come `conda` o `poetry`.

Le dipendenze principali sono:

- `pandas`: lettura file csv
- `matplotlib`: generazione e visualizzazione grafici
- `ipywidgets`: render di grafici interattivi tramite widget
- `jupyter`: modifica e visualizzazione notebook tramite interfaccia web

Ci sono due modalità per installare le dipendenze:

#### Tramite script
Il progetto mette a disposizione lo script bash `./python/start_jupyter_notebook.sh` che rileva se esiste un virtual environment con tutte le dipendenze installate, altrimenti crea l'environment e installa le dipendenze automaticamente utilizzando `pip` dopo una conferma da parte dell'utente

#### Manualmente
Per installare le dipendenze occorre eseguire i seguenti passaggi dentro alla cartella `./python`:

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
Il progetto mette a disposizione anche un Dockerfile con cui si può creare un'immagine Docker con un'istanza di Jupyter per poter visualizzare il contenuto del Jupyter notebook.

L'immagine può essere creata con il comando:
```
docker build -t local/top_github .
```

e eseguita con il comando:
```
docker run --rm -p 8888:8888 local/top_github
```

infine, per accedere all'interfaccia web, occorre accedere con il link che contiene il token di accesso che viene stampato su `stdout` all'avvio dell'immagine.

Alternativamente, si può de-commentare la penultima riga del Dockerfile per togliere l'accesso tramite token, e quindi si può accedere all'url `http://localhost:8888`.

### Dettagli sull'immagine

I file del dataset nel container sono scaricati durante la creazione dell'immagine, e non montati come volume, per cui ogni modifica al notebook tramite l'interfaccia web fornita dal container non è persistente.

Il build dell'immagine docker è suddivisa in due stage, uno per scaricare e preparare il dataset e uno per scaricare le dipendenze di Python.

La suddivisione è fatta per ottenere un'immagine finale più piccola, in quanto non contiene le dipendenze bash o comunque non contiene file non utilizzati dal notebook, ma soprattutto per poter parallelizzare la preparazione del dataset e il download delle dipendenze di Python in quanto sono i passaggi che richiedono più tempo.

### Docker compose

Per comodità, è messo a disposizione anche un file `docker-compose.yml` in cui è specificato di fare il build dell'immagine e di fare il port-forwarding della porta 8888 del container sulla porta 8888 dell'host.

Per avviare il file docker compose si può utilizzare il comando:
```
docker compose up
```

Se l'immagine non era mai stata creata prima dell'avvio con docker compose, verrà creata automaticamente.

## Ansible
Nel progetto è presente un playbook Ansible, diviso in due role, che assicura che il sistema abbia tutte le dipendenze per eseguire il progetto.


Il primo role, `bootstrap`, si occupa dell’installazione di Python sugli host appartenenti al gruppo `new` dell’inventario. Questo è necessario sia per poter utilizzare la parte Python del progetto, sia per consentire l’esecuzione del secondo role, poiché i moduli Ansible richiedono Python sull’host remoto.
Una volta installato Python, gli host possono essere rimossi dal gruppo `new` e, in futuro, verrà quindi eseguito esclusivamente il secondo role.

Il secondo role si chiama `install_packages` e si assicura che tutte le dipendenze per poter utilizzare il progetto siano installate.

Di default, nel file di inventario è impostato solo l'host `localhost`, però contiene anche un esempio di configurazione commentato per un altro host.


Per eseguire il playbook ansible (all'interno della directory `./ansible/`) si può utilizzare il comando:
```
ansible-playbook -i inventory.ini playbook.yml
```
