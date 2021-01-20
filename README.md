Script per la creazione di tematismi ricavati dal DTM (5 metri) della Regione Piemonte (DTM 2009 2011 PIEMONTE ICE)
===================================================================================================================

Questo è un insieme di Script per la creazione delle curve di livello in formato SHP, in formato GARMINN, DTM RASTER, rilievo ombreggiato, per essere visualizzato da Qlandkarte, Qmapshack, Qgis e software similari.

Il DTM utilizzato (RIPRESA AEREA ICE 2009-2011 - DTM 5) copre tutto il territorio regionale ed è stato acquisito con metodologia uniforme (LIDAR) in standard di livello 4. La risoluzione della griglia (passo) è di 5 m, con una precisione in quota di ±0.30 m (±0.60 m nelle aree di minor precisione, corrispondenti alle aree boscate e densamente urbanizzate).

I vari script sono stati sviluppati appositamente per la creazione dei tematismi ed eseguono tutti i passaggi, dal download alla generazione dei file necessari, però sono necessari alcuni pacchetti che devono essere presenti nel sistema (vedi sezione dedicata ai prerequisiti necessari).

Il tempo per il download dei 68 file zip che compongono il DTM del territtorio regionale dipendono dalla velocità della connessione a vostra disposizione.
Ovviamente, se serve una ridotta porzione di territtorio, si può andare a selezionare il download delle sezioni interessate cambiando il file "Regione.txt" che agisce con lo script scaricadtm.sh oppure è possibile creare altri file con le zone di vostro interesse.
I file di testo per il download dell'intera regione e delle province sono contenuti nella cartella "Scarico".


Prerequisiti
============

Per poter creare le varie parti serve avere installati i pacchetti:

rename

unoconv

gdal-bin

python-gdal

openjdk 11 (sudo apt-get install openjdk-11-jre openjdk-11-jdk)

osmctools

osmosis (versione 0.45, specificare il percorso nel file configurazione)

osm2ogr (specificare il percorso nel file configurazione)

mkgmap-r4425 (specificare il percorso e la versione scaricata nel file configurazione)

splitter-r595 (specificare il percorso e la versione scaricata nel file configurazione)

gmt (specificare il percorso nel file configurazione)


Prerequisiti Hardware
=====================

Per gli script di DTM e Rilievo ombreggiato non sono necessari molti Gb di RAM e SWAP, arriva a circa 3-4Gb di ram impegnata, mentre per la generazione delle curve di livello (soprattutto per la parte regionale e provinciale) si arriva a 8-10Gb.
Per la conversione delle curve in formato Garmin con mkgmap è necessario impostare il limite della RAM da impiegare. Il parametro deve essere impostato nel file configurazione alla relativa voce, consiglio di impostare almeno un valore pari alla vostra ram. Se emergono errori inerenti la ram dedicata bisogna aumentare il parametro.

Sulla macchina che utilizzo ho 16Gb di ram e 50Gb di swap


Passo delle curve
=================

Il passo verticale di taglio per l'ottenimento delle curve è impostato a 10 e 20 metri, se volete un passo diverso occorre variare la stringa che contiene "-i 10.0" oppure "-i 20.0" mettendo il valore desiderato all'interno degli script:

shp10regione.sh
shp10province.sh
shp10sezione.sh
shp20regione.sh
shp20province.sh
shp20sezione.sh
osm10.sh
osm20.sh


Variabili
=========

Tutte le variabili comuni (cartelle, percorsi di file, ecc) sono contenute all'interno del file configurazione, se si vogliono cambiare si cambiano una volta sola senda dover andare a cambiare le stesse cose all'interno di tutti gli script.


Sequenza per creare il DTM Raster in un unico mosaico regionale
===============================================================

Lo scarico delle sezioni occorrenti è stato volutamente fatto a parte, in quanto si possono verificare alcune problematiche, così si può seguire il processo e monitorare di tanto in tanto.
N.B. Se i file che servono per la creazione sono già stati scaricati non occorre ripetere lo script scaricadtm.sh

scaricadtm.sh (scarica i file zip del DTM e li decomprime)

dtmregione.sh (crea il mosaico)


Sequenza per creare il DTM Raster
=================================

Lo scarico delle sezioni occorrenti è stato volutamente fatto a parte, in quanto si possono verificare alcune problematiche, così si può seguire il processo e monitorare di tanto in tanto.
N.B. Se i file che servono per la creazione sono già stati scaricati non occorre ripetere lo script scaricadtm.sh

scaricadtm.sh scarica i file zip del DTM e li decomprime

dtmregione.sh crea i file per le singole province (sono quindi utilizzabili singolarmente) ogniuna con il suo file .vrt mentre per la regione completa viene creato un file .vrt che richiama insieme tutte le province


Sequenza per creare il rilievo ombreggiato
==========================================

Lo scarico delle sezioni occorrenti è stato volutamente fatto a parte, in quanto si possono verificare alcune problematiche, così si può seguire il processo e monitorare di tanto in tanto.
N.B. Se i file che servono per la creazione sono già stati scaricati non occorre ripetere lo script scaricadtm.sh

scaricadtm.sh scarica i file zip del DTM e li decomprime

ombreregione.sh crea il rilievo ombreggiato delle singole province, ritagliato sui singoli confini e vengono richiamati in un file vrt
















Sequenza per creare le curve di livello (passo 10 metri) in formato SHP in un unico file regionale
==================================================================================================

Lo scarico delle sezioni occorrenti è stato volutamente fatto a parte, in quanto si possono verificare alcune problematiche, così si può seguire il processo e monitorare di tanto in tanto.
N.B. Se i file che servono per la creazione sono già stati scaricati non occorre ripetere lo script scaricadtm.sh

scaricadtm.sh scarica i file zip del DTM e li decomprime

shp10regione.sh crea le curve in formato SHP ed in un unico file regionale


Sequenza per creare le curve di livello (passo 10 metri) in formato SHP per le province
=======================================================================================

Lo scarico delle sezioni occorrenti è stato volutamente fatto a parte, in quanto si possono verificare alcune problematiche, così si può seguire il processo e monitorare di tanto in tanto.
N.B. Se i file che servono per la creazione sono già stati scaricati non occorre ripetere lo script scaricadtm.sh

scaricadtm.sh scarica i file zip del DTM e li decomprime

shp10province.sh crea le curve in formato SHP in un file per ogni provincia e lo ritaglia sul confine effettivo della provincia


Sequenza per creare le curve di livello (passo 10 metri) in formato SHP per le sezioni
======================================================================================

Lo scarico delle sezioni occorrenti è stato volutamente fatto a parte, in quanto si possono verificare alcune problematiche, così si può seguire il processo e monitorare di tanto in tanto.
N.B. Se i file che servono per la creazione sono già stati scaricati non occorre ripetere lo script scaricadtm.sh

scaricadtm.sh scarica i file zip del DTM e li decomprime

shp10sezionee.sh crea le curve in formato SHP in un file per ogni sezione e lo ritaglia sul confine effettivo della regione


Sequenza per creare le curve di livello (passo 20 metri) in formato SHP in un unico file regionale
==================================================================================================

Lo scarico delle sezioni occorrenti è stato volutamente fatto a parte, in quanto si possono verificare alcune problematiche, così si può seguire il processo e monitorare di tanto in tanto.
N.B. Se i file che servono per la creazione sono già stati scaricati non occorre ripetere lo script scaricadtm.sh

scaricadtm.sh scarica i file zip del DTM e li decomprime

shp20regione.sh crea le curve in formato SHP ed in un unico file regionale


Sequenza per creare le curve di livello (passo 20 metri) in formato SHP per le province
=======================================================================================

Lo scarico delle sezioni occorrenti è stato volutamente fatto a parte, in quanto si possono verificare alcune problematiche, così si può seguire il processo e monitorare di tanto in tanto.
N.B. Se i file che servono per la creazione sono già stati scaricati non occorre ripetere lo script scaricadtm.sh

scaricadtm.sh scarica i file zip del DTM e li decomprime

shp20province.sh crea le curve in formato SHP in un file per ogni provincia e lo ritaglia sul confine effettivo della provincia


Sequenza per creare le curve di livello (passo 20 metri) in formato SHP per le sezioni
======================================================================================

Lo scarico delle sezioni occorrenti è stato volutamente fatto a parte, in quanto si possono verificare alcune problematiche, così si può seguire il processo e monitorare di tanto in tanto.
N.B. Se i file che servono per la creazione sono già stati scaricati non occorre ripetere lo script scaricadtm.sh

scaricadtm.sh scarica i file zip del DTM e li decomprime

shp20sezionee.sh crea le curve in formato SHP in un file per ogni sezione e lo ritaglia sul confine effettivo della regione









Sequenza per creare le curve di livello in formato Garmin
=========================================================

scaricadtm.sh scarica i file zip del DTM e li decomprime

shpcurve.sh crea le curve in formato SHP

shpaosm.sh converte le curve in formato OSM

osmaimg.sh converte le curve in formato IMG
