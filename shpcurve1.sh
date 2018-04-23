#!/bin/bash

# script per la creazione delle curve di livello per le singole sezioni tagliando la regione intera con il perimetro delle sezioni
# unico requisito è avere già fatto il file delle curve prima di far partire questo script


#carica il file di configuraione delle variabili
source "./configurazione"


#verifica che sia presente la cartella con il file delle curve della regione intera
if [[ ! -d $regione ]]
then
  echo "Non esiste la cartella $regione, fai girare lo script shpregione.sh prima di questo"
  exit 1
fi


#verifica la presenza delle cartella per i file SHP delle sezioni e la crea se non è già esistente
if [ -d $curve ]; then
    echo "OK - $curve esiste."
else
    mkdir $curve
fi


#rimuove i file eventualmente presenti nella cartella delle sezioni
rm -r $curve/*


#si sposta nella cartella delle curve create per la regione intera
cd $regione


#crea le curve per le sezioni
    for filename in $(ls ../$sdtm/*.zip); do

       #prende il numero delle sezioni, isolandolo tra trattino "-" precedente il numero ed il trattino "-" seguente
       n=$(echo $filename | awk -F \RIPRESA_AEREA_ICE_2009_2011_DTM-SDO_CTR_FOGLI50- {'print $2'} | awk -F \-EPSG32632-TIF {'print $1'})

       echo
       echo "Creo le curve di livello della sezione $n"
       ogr2ogr -progress -clipsrc ../Taglio/Sezioni/$n.shp ../$curve/Curve_DTM5_$n.shp Curve_DTM5_regione.shp

    done


#ritorna nella cartella principale
cd ..


#copia la documentazione nella cartella dei file
cp -r ./Documentazione ./$curve/


#si sposta nella cartella documentazione
cd ./$curve/Documentazione


#chiede il nome e cognome per l'attribuzione della licenza e lo inserisce nel file licenza.txt al posto di "Licenziatario"
echo
echo
echo -n "inserisci il tuo nome e cognome per l'attribuzione: "
read parola

sed -i "s/licenziatario/$parola/" Licenza.txt


#converte il file Licenza.txt in PDF
unoconv -f pdf Licenza.txt


#rimuove il file Licenza.txt
rm Licenza.txt


#ritorna nella cartella principale
cd ..
