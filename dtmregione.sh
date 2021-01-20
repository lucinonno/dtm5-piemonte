#!/bin/bash

#Script per creare il DTM per l'intera regione (insieme delle province) e le singole province


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


#verifica la presenza delle cartella dei file DTM e la crea se non è già esistente
if [ -d $dtmre ]; then
    echo "OK - $dtmre esiste."
else
    mkdir $dtmre
fi


#chiede il nome e cognome per l'attribuzione della licenza
echo
echo
echo -n "inserisci il tuo nome e cognome per l'attribuzione: "
read parola


#rimuove i files eventualmente presenti nella cartella
rm -r $dtmre/*


#rimuove i files vrt eventualmente presenti nella cartella delle immagini
rm $tif/*.vrt


#crea la cartella in cui verranno messi i file generati
mkdir $dtmre/3D/


#si sposta nella cartella di Servizio
cd ./Servizio


#crea una cartella per goni provincia
for filename in $(ls *.txt); do

	# prendo solo il nome del file
	n=$(echo $filename | awk -F \. {'print $1'})
	#crea la cartella di servizio della provincia
	echo
	echo "Creo la cartella per la provincia di $n"
	mkdir ../$dtmre/$n
	#legge il codice della sezione da copiare nellla cartella della provincia
	cat $n.txt | \
	while read riga; do
	echo $riga
	#prende il codice della sezione
	codice=`echo $riga | cut -d " " -f 1`
	#sposta il file selezionato
	cp ../$tif/DTM5_$codice.tif ../$dtmre/$n/

	done 

	#crea il file vrt per la provincia
	echo
	echo "Creo il file vrt per la provincia di $n"
	gdalbuildvrt ../$dtmre/$n/DTM5_$n.vrt ../$dtmre/$n/*.tif -a_srs "EPSG:32632"
	#taglia il DTM sul confine della provincia
	echo
	echo "Taglio il DTM sul confine della provincia di $n"
	gdalwarp -cutline ../Taglio/Shp/$n.shp -crop_to_cutline -co COMPRESS=DEFLATE -co PREDICTOR=2 ../$dtmre/$n/DTM5_$n.vrt ../$dtmre/3D/DTM5_$n.tif
	#crea il file vrt definitivo per la provincia
	echo
	echo "Creo il file vrt per la provincia di $n"
	gdalbuildvrt ../$dtmre/3D/DTM5_$n.vrt ../$dtmre/3D/DTM5_$n.tif -a_srs "EPSG:32632"
	#cancella la cartella di servizio
	rm -r ../$dtmre/$n/

done


#crea il file vrt definitivo per la regione
echo
echo "Creo il file vrt per l'intera regione"
gdalbuildvrt ../$dtmre/3D/DTM5_Piemonte.vrt ../$dtmre/3D/*.tif -a_srs "EPSG:32632"


#si sposta nella cartella principale
cd ..


#copia la documentazione nella cartella dei file
cp -r ./Documentazione/Documentazione_DTM5_Piemonte ./$dtmre/Documentazione


#si sposta nella cartella documentazione
cd ./$dtmre/Documentazione


#inserisce il nome e cognome per l'attribuzione della licenza nel file DTM5_PIEMONTE-licenza.txt al posto di "Licenziatario"
sed -i "s/licenziatario/$parola/" DTM5_PIEMONTE-licenza.txt


#converte il file Licenza.txt in PDF
unoconv -f pdf DTM5_PIEMONTE-licenza.txt


#rimuove il file DTM5_PIEMONTE-licenza.txt
rm DTM5_PIEMONTE-licenza.txt


#ritorna nella cartella principale
cd ..
