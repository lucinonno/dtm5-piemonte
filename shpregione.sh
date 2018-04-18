#!/bin/bash

#file per creare le curve in formato shp in un unico file


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


#crea un file vrt unico per la regione
gdalbuildvrt Curve_DTM5_regione.vrt *.tif -a_srs "EPSG:32632"


#crea le curve
echo
echo Creo le curve della regione
gdal_contour -b 1 -a name -i 10.0 -inodata -snodata 0 -f "ESRI Shapefile" Curve_DTM5_regione.vrt "../$regione/Curve_DTM5.shp"


#si sposta nella cartella del file con le curve
cd ../$regione


#ritaglia le curve sul confine della regione piemonte, all'interno dell cartella Taglio sono presenti anche i file delle province,
#è possibile cambiare il poligono di taglio cambiando il nome Piemonte.shp con uno di quelli contenuti nella cartella
echo
echo Taglio le curve che sbordano oltre il confine della regione
ogr2ogr -progress -clipsrc ../Taglio/Shp/Piemonte.shp Curve_DTM5_regione.shp Curve_DTM5.shp


#cancella il file più grande del confine della regione
rm Curve_DTM5.*


#ritorna nella cartella principale
cd ..


#rimuove i files vrt eventualmente presenti nella cartella delle immagini
rm $tif/*.vrt


#copia la documentazione nella cartella dei file
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
