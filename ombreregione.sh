#!/bin/bash

#file per creare il rilievo ombreggiato in un mosaico regionale


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


#verifica la presenza delle cartella dei rilievi ombreggiati e la crea se non è già esistente
if [ -d $ombrere ]; then
    echo "OK - $ombrere esiste."
else
    mkdir $ombrere
fi


#rimuove i files eventualmente presenti nella cartella
rm -r $ombrere/*


#rimuove i files vrt eventualmente presenti nella cartella delle immagini
rm $tif/*.vrt


#si sposta nella cartella delle immagini
cd $tif


#crea un file vrt unico per la regione
gdalbuildvrt OMBRE_regione.vrt *.tif -a_srs "EPSG:32632"


#crea il rilievo ombreggiato in un unico file
gdaldem hillshade OMBRE_regione.vrt ../$ombrere/OMBRE_regione.tif -b 1 -multidirectional


#si sposta nella cartella principale
cd ..


#rimuove i files vrt eventualmente presenti nella cartella delle immagini
rm $tif/*.vrt


#copia la documentazione nella cartella dei file
cp -r ./Documentazione ./$ombrere/


#si sposta nella cartella documentazione
cd ./$ombrere/Documentazione


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
