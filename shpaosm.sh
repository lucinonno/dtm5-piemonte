#!/bin/bash

#script per la creazione delle curve in formato Garmin


#carica il file di configuraione delle variabili
source "./configurazione"


#verifica che sia presente la cartella con le curve
if [[ ! -d $regione ]]
then
  echo "Non esiste la cartella $regione, fai girare lo script shpregione.sh prima di questo"
  exit 1
fi


#crea la cartella dei file in formato osm se non è già esistente
if [ -d $uscitaosm ]; then
    echo "OK - $uscitaosm esiste."
else
    mkdir $uscitaosm
fi


#rimuove i files eventualmente presenti nella cartella
rm -r $uscitaosm/*


#id massimo preso dalla history di osm con 99 davanti, in modo che sia motlo superiore per parecchio tempo
id=993937119999


#si sposta nella cartella delle curve in formato SHP
cd $regione


#converte le curve in formato OSM
python $ogr2osm --positive-id --id=$id --add-version --add-timestamp --force Curve_DTM5_regione.shp -o "../$uscitaosm/Curve_DTM5_regione.osm"


#converte in pbf
$osmosis --rx Curve_DTM5_regione.osm --wb Curve_DTM5:regione.pbf omitmetadata=true


#cancella il file in formato OSM
rm ../$uscitaosm/$nomeuscita.osm


id=`expr $id + 9000000`

