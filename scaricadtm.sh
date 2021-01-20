#! /bin/bash

#Script per il download ed estrazione dei file delle sezioni per la successiva lavorazione


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


#rimuove i files eventualmente presenti nelle cartelle
rm -r $sdtm/*
rm -r $tif/*


#si sposta nella cartella in cui saranno scaricati i file zippati
cd $sdtm


#inizia il ciclo di scaricamento e lo ripete finchè ci sono sezioni indicate nel file di scarico
#puoi cambiare il file di scarico con uno di quelli presenti nella cartella oppure crearne uno tuo e salvarlo nella cartella "Scarico", per far leggere il tuo oppure un'altro file cambia la scritta Regione.txt qui sotto con quello che ti interessa

#legge il codice della sezione da scaricare indicato nel file di scarico
cat ../Scarico/Regione.txt | \
while read riga; do
echo $riga

#prende il codice della sezione
codice=`echo $riga | cut -d " " -f 1`

#scarica il file selezionato
wget -nc http://www.datigeo-piem-download.it/static/regp01/DTM5_ICE/RIPRESA_AEREA_ICE_2009_2011_DTM-SDO_CTR_FOGLI50-$codice-EPSG32632-TIF.zip

done 


#passa nella cartella dei file scompattati
cd ../$tif


#scompatta il file hillshading
unzip -o ../$sdtm/\*.zip


#torna nella cartella principale
cd ..
