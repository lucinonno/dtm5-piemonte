#!/bin/bash

#carica il file di configuraione delle variabili
source "./configurazione"


if [[ ! -d $curve ]]
then
  echo "Non esiste la cartella $curve, fai girare lo script shpcurve.sh prima di questo"
  exit 1
fi


#verifica la presenza delle cartella dei file SHP e la crea se non è già esistente
if [ -d $regione ]; then
    echo "OK - $regione esiste."
else
    mkdir $regione
fi


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
