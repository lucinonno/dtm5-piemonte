#!/bin/bash

#script per la creazione delle curve in formato OSM


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


#si sposta nella cartella delle curve della regione
cd $regione


# converte in OSM
for tipo in $sdu
do 


for s in $(find -name "*$tipo*.shp" | cut -c3-)
	 do
	 echo "converto $s"
	 #converte in osm
nomeuscita=`basename $s`
python $ogr2osm --positive-id --id=$id --add-version --add-timestamp --force ./$s -o "../$uscitaosm/$nomeuscita.osm" 


#converte in pbf
$osmosis --rx ../$uscitaosm/$nomeuscita.osm --wb ../$uscitaosm/$nomeuscita.pbf omitmetadata=true
rm ../$uscitaosm/$nomeuscita.osm


id=`expr $id + 9000000`
done
done


#si sposta nella cartella di uscita dei file in formato osm
cd ../$uscitaosm


#rinomina il file
rename 's/.shp//g' *.shp.*


#ritorna nella cartella principale
cd ..
