#!/bin/bash

#script per la creazione delle curve in formato OSM


#carica il file di configuraione delle variabili
source "./configurazione"


#verifica che sia presente la cartella con le curve
if [[ ! -d $curve ]]
then
  echo "Non esiste la cartella $curve, fai girare lo script shpcurve.sh prima di questo"
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


#si sposta nella cartella delle curve della regione
cd $curve


# converte i file
for s in $(find -name "*DTM5*.shp")
	 do
	 echo
	 echo "Converto in formato osm $s"
nomeuscita=`basename $s`
python $ogr2osm --positive-id --id=$id --add-version --add-timestamp --force ./$s -o "../$uscitaosm/$nomeuscita.osm" 

	 echo
	 echo "Converto in formato il file in pbf"
$osmosis --rx ../$uscitaosm/$nomeuscita.osm --wb ../$uscitaosm/$nomeuscita.pbf omitmetadata=true
rm ../$uscitaosm/$nomeuscita.osm

id=`expr $id + 9000000`
done


#si sposta nella cartella di uscita dei file in formato osm
cd ../$uscitaosm


#rinomina i file
rename 's/.shp//g' *.shp.*


#ritorna nella cartella principale
cd ..
