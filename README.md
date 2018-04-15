Script per la creazione di tematismi ricavati dal DTM (5 metri) della Regione Piemonte
======================================================================================

Script per la creazione delle curve di livello (passo 10m) in formato SHP, in formato garmin e modello raster per Qlandkarte, Qmapshack e similari.

Il DTM (rete 5 metri) della regione (utilizzato per tutti i formati) è distribuito in licenza CC BY 2.5 IT, quindi i vari prodotti realizzati devono rispettare la licenza e l'attribuzione richiesta dalla regione.

I vari script girano su UBUNTU, una volta scaricato il modello e create le curve di livello possono essere visualizzate in Qgis e simili per molti scopi.

Il tempo per il download dei 68 file zip che compongono il DTM del territtorio regionale dipendono dalla velocità della connessione a vostra disposizione.
Ovviamente, se vi serve una ridotta porzione di territtorio, si può andare a selezionare il dowload delle sezioni interessate andando a selezionare la parte interessata nel file Regione.txt oppure è possibile creare altri file con le zone interessate.


Descrizione degli script
========================

Sono presenti alcuni script che vanno a creare vari elementi cartografici partendo dal DTM della regione Piemonte, nello specifico si possono ottenere:

	- Curve di livello in formato SHP, di base a 10 metri ma il parametro può essere variato, utilizzabili con QGIS ed altri sistemi GIS

	- DTM, utilizzabile con QGIS ed altri sistemi GIS, Qmapshack, Qlandkarte ed altri software

	- Rilievi ombreggiati, utilizzabile con QGIS ed altri sistemi GIS

	- Curve di livello in formato img Garmin, utilizzabile su GPS escursionistici Garmin


Descrizione del DTM utilizzato
==============================

Il DTM copre tutto il territorio regionale ed è stato acquisito con metodologia
uniforme (LIDAR) in standard di livello 4. La risoluzione della griglia (passo)
è di 5 m, con una precisione in quota di ±0.30 m (±0.60 m nelle aree di
minor precisione, corrispondenti alle aree boscate e densamente
urbanizzate).


Prerequisiti
============

Per poter creare le varie parti serve avere installati i pacchetti:

Conversione raster e SHP

rename

unoconv

gdal-bin


Conversione Garmin

python-gdal

osmctools

osmosis

osm2ogr

mkgmap

splitter

gmt


Passo delle curve
=================

Il passo verticale di taglio per l'ottenimento delle curve è impostato a 10 metri, se volete un passo diverso bisogna andare a variare la stringa che contiene -i 10.0 all'interno degli script "shpcurve.sh" e "shpcurve.sh" e mettere al posto di 10.0 il valore desiderato.


Variabili
=========

Tutte le variabili comuni (cartelle, percorsi di file, ecc) contenute all'interno del file configurazione, se si vogliono cambiare si cambiano una volta sola senda dover andare a cambiare le stesse cose all'interno di tutti gli script.


Sequenza per creare le curve di livello in formato SHP
======================================================

scaricadtm.sh scarica i file zip del DTM e li decomprime

shpcurve.sh crea le curve a 10 metri delle sezioni al 50.000


Sequenza per creare le curve di livello in formato SHP in un unico file
=======================================================================

scaricadtm.sh scarica i file zip del DTM e li decomprime

shpregione.sh crea le curve in un unico file regionale


Sequenza per creare il DTM in un unico mosaico
==============================================

scaricadtm.sh scarica i file zip del DTM e li decomprime

dtmregione.sh crea il mosaico


Sequenza per creare il DTM mantenendo le sezioni separate
=========================================================

scaricadtm.sh scarica i file zip del DTM e li decomprime

dtmsezione.sh crea i file per le singole sezioni


Sequenza per creare il rilievo ombreggiato mantenendo le sezioni separate
=========================================================================

scaricadtm.sh scarica i file zip del DTM e li decomprime

ombresezione.sh crea i file per le singole sezioni


Sequenza per creare il rilievo ombreggiato in un unico file
===========================================================

scaricadtm.sh scarica i file zip del DTM e li decomprime

ombreregione.sh crea il rilievo ombreggiato in un unico file e lo ritaglia sul confine effettivo della regione


Sequenza per creare le curve di livello in formato Garmin
=========================================================

scaricadtm.sh scarica i file zip del DTM e li decomprime

shpregione.sh crea le curve in formato SHP in un unico file regionale

shpaosm.sh converte le curve in formato OSM

osmaimg.sh converte le curve in formato IMG
