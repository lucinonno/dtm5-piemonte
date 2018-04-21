#!/bin/bash

#file per creare il rilievo ombreggiato per ogni sezione


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
if [ -d $ombre ]; then
    echo "OK - $ombre esiste."
else
    mkdir $ombre
fi


#rimuove i files eventualmente presenti nella cartella
rm -r $ombre/*


#rimuove i files vrt eventualmente presenti nella cartella delle immagini
rm $tif/*.vrt


#si sposta nella cartella delle immagini
cd $tif


#crea un file vrt per ogni sezione
for i in $(find -name "*.tif")  
	 do
	 echo
	 echo "Creo il file vrt per $i"
gdalbuildvrt $i.vrt $i -a_srs "EPSG:32632"

done


#rinomina i file vrt
rename 's/.tif.vrt/.vrt/g' *.tif.vrt


#crea il rilievo ombreggiato per ogni sezione
for i in $(find -name "*.vrt")  
	 do
	 echo
	 echo "Creo il rilievo ombreggiato per $i"
gdaldem hillshade $i ../$ombre/$i.tif -b 1

done


#si sposta nella cartella di destinazione
cd ../$ombre


#rinomina i file tif
rename 's/.vrt.tif/.tif/g' *.tif
rename 's/DTM5/Ombre_DTM5/g' *.tif


#si sposta nella cartella principale
cd ..


#rimuove i files vrt eventualmente presenti nella cartella delle immagini
rm $tif/*.vrt


#copia la documentazione nella cartella dei file
cp -r ./Documentazione ./$ombre/


#si sposta nella cartella documentazione
cd ./$ombre/Documentazione


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
