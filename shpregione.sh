#!/bin/bash

#file per unire tutte le sezioni in formato shp in un unico file


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
if [ -d $regione ]; then
    echo "OK - $regione esiste."
else
    mkdir $regione
fi


#rimuove i files eventualmente presenti nella cartella
rm -r $regione/*


#rimuove i files vrt eventualmente presenti nella cartella delle immagini
rm $tif/*.vrt


#si sposta nella cartella delle immagini
cd $tif


#crea un file vrt per ogni sezione
gdalbuildvrt Curve_DTM5_regione.vrt *.tif -a_srs "EPSG:32632"


#crea le curve
gdal_contour -b 1 -a name -i 10.0 -inodata -snodata 0 -f "ESRI Shapefile" Curve_DTM5_regione.vrt "../$regione/Curve_DTM5_regione.shp"


cd ..


#rimuove i files vrt eventualmente presenti nella cartella delle immagini
rm $tif/*.vrt


#prepara la cartella con le mappe e la documentazione della versione per GPS
cp -r ./Documentazione ./$regione/


#si sposta nella cartella documentazione
cd ./$regione/Documentazione


#chiede il nome e cognome per l'attribuzione della licenza e lo inserisce nel file licenza.txt al posto di "Licenziatario"
echo
echo
echo -n "inserisci il tuo nome e cognome per l'attribuzione: "
read parola

sed -i "s/Licenziatario/$parola/" Licenza.txt


#converte il file Licenza.txt in PDF
unoconv -f pdf Licenza.txt


#rimuove il file Licenza.txt
rm Licenza.txt


#ritorna nella cartella principale
cd ..
