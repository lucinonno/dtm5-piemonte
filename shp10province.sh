#!/bin/bash

#Script per creare le curve in formato shp delle singole province (10 metri)


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
if [ -d $curve10pr ]; then
    echo "OK - $curve10pr esiste."
else
    mkdir $curve10pr
fi


#chiede il nome e cognome per l'attribuzione della licenza
echo
echo
echo -n "inserisci il tuo nome e cognome per l'attribuzione: "
read parola


#rimuove i files eventualmente presenti nella cartella
rm -r $curve10pr/*


#rimuove i files vrt eventualmente presenti nella cartella delle immagini
rm $tif/*.vrt


#si sposta nella cartella dei file di servizio
cd ./Servizio


#crea le curve
for filename in $(ls *.txt); do
	# prendo solo il nome del file
	n=$(echo $filename | awk -F \. {'print $1'})
	#crea la cartella della provincia
	echo
	echo "Creo la cartella per la provincia di $n"
	mkdir ../$curve10pr/$n
	#legge il codice delle sezioni da copiare nellla cartella della provincia
	cat $n.txt | \
	while read riga; do
	echo $riga
	#prende il codice della sezione
	codice=`echo $riga | cut -d " " -f 1`
	#sposta il file selezionato
	cp ../$tif/DTM5_$codice.tif ../$curve10pr/$n/
	done
	#crea il file vrt unico per la provincia
	echo
	echo "Creo il file vrt per la provincia di $n"
	gdalbuildvrt ../$curve10pr/$n/SHP10_$n.vrt ../$curve10pr/$n/*.tif -a_srs "EPSG:32632"
	#crea le curve
	echo
	echo "Creo le curve della provincia di $n"
	gdal_contour -b 1 -a name -i 10.0 -f "ESRI Shapefile" ../$curve10pr/$n/SHP10_$n.vrt "../$curve10pr/$n/SHP10_$n.shp"
	#ritaglia le curve sul confine della provincia
	echo
	echo "Taglio le curve che sbordano oltre il confine della provincia di $n"
	ogr2ogr -f 'ESRI Shapefile' -progress -clipsrc ../Taglio/Shp/$n.shp ../$curve10pr/SHP10_$n.shp ../$curve10pr/$n/SHP10_$n.shp
	#cancella tutta la cartella
	rm -r ../$curve10pr/$n

done


#ritorna nella cartella principale
cd ..


#rimuove i files vrt eventualmente presenti nella cartella delle immagini
rm $tif/*.vrt


#copia la documentazione nella cartella dei file
cp -r ./Documentazione/Documentazione_SHP10_Province ./$curve10pr/Documentazione


#si sposta nella cartella documentazione
cd ./$curve10pr/Documentazione


#inserisce il nome e cognome per l'attribuzione della licenza nel file SHP10_PIEMONTE_PROVINCE-licenza.txt al posto di "Licenziatario"
sed -i "s/licenziatario/$parola/" SHP10_PIEMONTE_PROVINCE-licenza.txt


#converte il file SHP10_PIEMONTE_PROVINCE-licenza.txt in PDF
unoconv -f pdf SHP10_PIEMONTE_PROVINCE-licenza.txt


#rimuove il file SHP10_PIEMONTE_PROVINCE-licenza.txt
rm SHP10_PIEMONTE_PROVINCE-licenza.txt


#ritorna nella cartella principale
cd ..
