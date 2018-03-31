#! /bin/bash

#carica il file di configuraione delle variabili
source "./configurazione"


#crea la cartella per i file zippati del DTM5 se non è già esistente
if [ -d $sdtm ]; then
    echo "$sdtm esiste."
else
    mkdir $sdtm
fi


#crea la cartella per i file TIF se non è già esistente
if [ -d $tif ]; then
    echo "$tif esiste."
else
    mkdir $tif
fi


#rimuove i files presenti eventualmente presenti nelle cartelle
rm $sdtm/*
rm $tif/*


cd $sdtm


#ciclo di scaricamento 
cat ../Scarico/Regione.txt | \
while read riga; do
echo $riga

#prende il codice del comune
codice=`echo $riga | cut -d " " -f 1`

#scarica il file
wget -nc http://www.datigeo-piem-download.it/static/regp01/DTM5_ICE/RIPRESA_AEREA_ICE_2009_2011_DTM-SDO_CTR_FOGLI50-$codice-EPSG32632-TIF.zip

done 


cd ../$tif

#scompatta il file hillshading
unzip -o ../$sdtm/\*.zip

cd ..
