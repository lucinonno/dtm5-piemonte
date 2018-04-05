Script per la creazione di tematismi ricavati dal DTM (5 metri) della Regione Piemonte
======================================================================================

Script per la creazione delle curve di livello (passo 10m) in formato SHP, in formato garmin e modello raster per Qlandkarte, Qmapshack e similari.

Il DTM (rete 5 metri) della regione (utilizzato per tutti i formati) è distribuito in licenza CC BY 2.5 IT, quindi i vari prodotti realizzati devono rispettare la licenza e l'attribuzione richiesta dalla regione.

I vari script girano su UBUNTU, una volta scaricato il modello e create le curve di livello possono essere visualizzate in Qgis e simili per molti scopi.

Il tempo per il download dei 68 file zip che compongono il DTM del territtorio regionale dipendono dalla velocità della connessione a vostra disposizione.
Ovviamente, se vi serve una ridotta porzione di territtorio, si può andare a selezionare il dowload delle sezioni interessate andando a selezionare la parte interessata nel file XXXXXX


Descrizione del DTM utilizzato
==============================

Il DTM copre tutto il territorio regionale ed è stato acquisito con metodologia
uniforme (LIDAR) in standard di livello 4. La risoluzione della griglia (passo)
è di 5 m, con una precisione in quota di ±0.30 m (±0.60 m nelle aree di
minor precisione, corrispondenti alle aree boscate e densamente
urbanizzate).


Prerequisiti
============

Per poter creare le varie parti serve avere i pacchetti:

rename

unoconv

gdal-bin


Memoria occupata
================

Nello specchietto sottostante riporto quanta memoria occupano le varie parti.

2.9 Gb per i file zip del DTM
4.7 Gb per i file Tif (nativi) scompattati
3.7 Gb per i file delle sezioni in formato SHP
3.7 Gb per il file della regione in formato SHP


Passo delle curve
=================

Il passo verticale di taglio per l'ottenimento delle curve è impostato a 10 metri, se volete un passo diverso bisogna andare a variare la stringa (alla riga 57) 'gdal_contour -b 1 -a name -i 10.0 -f "ESRI Shapefile" "$i" "../$curve/$i.shp"' all'interno dello script "shpcurve.sh" e mettere al posto di 10.0 il valore desiderato.

Per la regione intera il passo verticale di taglio per l'ottenimento delle curve è impostato a 10 metri, se volete un passo diverso bisogna andare a variare la stringa (alla riga 49) 'gdal_contour -b 1 -a name -i 10.0 -f "ESRI Shapefile" Curve_DTM5_regione.vrt "../$regione/Curve_DTM5_regione.shp"' all'interno dello script "shpregione.sh" e mettere al posto di 10.0 il valore desiderato.


Variabili
=========

Tutte le variabili comuni (cartelle, percorsi di file, ecc) contenute all'interno del file configurazione, se si vogliono cambiare si cambiano una volta sola senda dover andare a cambiare le stesse cose all'interno di tutti gli script.


Sequenza per creare le curve di livello in formato SHP
======================================================

scaricastm.sh scarica i file zip del DTM e li decomprime

shpcurve.sh crea le curve a 10 metri delle sezioni al 50.000


Sequenza per creare le curve di livello in formato SHP in un unico file
=======================================================================

scaricastm.sh scarica i file zip del DTM e li decomprime

shpregione.sh crea le curve a 10 metri in un unico file regionale
