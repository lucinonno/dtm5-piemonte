#!/bin/bash

#carica il file di configuraione delle variabili
source "./configurazione"


#verifica che sia presente la cartella con i file sorgenti del Dtm5
if [[ ! -d $sdtm ]]
then
  echo "Non esiste la cartella $sdtm, fai girare lo script scaricadtm.sh prima di questo"
  exit 2
fi

if [[ ! -d $tif ]]
then
  echo "Non esiste la cartella $tif, fai girare lo script scaricadtm.sh prima di questo"
  exit 1
fi


#verifica la presenza delle cartella dei file SHP e la crea se non è già esistente
if [ -d $curve ]; then
    echo "OK - $curve esiste."
else
    mkdir $curve
fi


#rimuove i files presenti eventualmente presenti nella cartella
rm $curve/*


#si sposta nella cartella delle immagini
cd $tif


#crea un file vrt per ogni sezione
for i in $(find -name "*.tif")  
	 do
	 echo "creo il file vrt per $i"
gdalbuildvrt $i.vrt $i -a_srs "EPSG:32632"

done


#rinomina i file vrt
rename 's/.tif.vrt/.vrt/g' *.tif.vrt


#crea le curve
for i in $(find -name "*.vrt")  
	 do
	 echo "creo le curve di livello per $i"
gdal_contour -b 1 -a name -i 10.0 -f "ESRI Shapefile" "$i" "../$curve/$i.shp"

done


#si sposta nella cartella delle curve in formato SHP
cd ../$curve/

#rinomina i file SHP
for filename in *.vrt.* ; do mv $filename Curve_$filename; done

rename 's/.vrt//g' *.vrt.*

cd ..


#prepara la cartella con le mappe e la documentazione della versione per GPS

cp -r ./Documentazione ./$CURVE/

