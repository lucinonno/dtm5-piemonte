#!/bin/bash

#Script per creare il rilievo ombreggiato in un mosaico regionale


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


#chiede il nome e cognome per l'attribuzione della licenza
echo
echo
echo -n "inserisci il tuo nome e cognome per l'attribuzione: "
read parola


#rimuove i files eventualmente presenti nella cartella
rm -r $ombrere/*


#rimuove i files vrt eventualmente presenti nella cartella delle immagini
rm $tif/*.vrt


#si sposta nella cartella delle immagini
cd $tif


#crea un file vrt unico per la regione
echo
echo "Creo il file vrt per l'intera regione"
gdalbuildvrt OMBRE_Piemonte.vrt *.tif -a_srs "EPSG:32632"


#crea il rilievo ombreggiato in un unico file
echo
echo "Creo il rilievo ombreggiato per l'intera regione"
gdaldem hillshade OMBRE_Piemonte.vrt ../$ombrere/OMBRE_cut.tif -b 1


#si sposta nella cartella di servizio
cd ../Servizio


#taglia il file della regione sul confine della provincia e cre file vrt
for filename in $(ls *.txt); do

	# prendo solo il nome del file
	n=$(echo $filename | awk -F \. {'print $1'})
	#taglia il file sul confine della provincia
	echo
	echo "Taglio il rilievo ombreggiato sul confine della provincia di $n"
	gdalwarp -ot Float32 -of GTiff -cutline ../Taglio/Shp/$n.shp -crop_to_cutline -dstnodata 0 -co COMPRESS=DEFLATE -co PREDICTOR=2 ../$ombrere/OMBRE_cut.tif ../$ombrere/OMBRE_$n.tif
	#crea il file vrt per la provincia
	echo
	echo "Creo il file vrt per il riilievo ombreggiato della provincia di $n"
	gdalbuildvrt ../$ombrere/OMBRE_$n.vrt ../$ombrere/OMBRE_$n.tif -a_srs "EPSG:32632"

done


#si sposta nella cartella principale
cd ..


#rimuove i files vrt eventualmente presenti nella cartella delle immagini ed il file di servizio nella cartella dei rilievi ombreggiati
rm $tif/*.vrt
rm $ombrere/*cut.tif


#si sposta nella cartella della regione
cd $ombrere


#crea un file vrt unico per la regione
echo
echo "Creo il file vrt per l'intera regione"
gdalbuildvrt OMBRE_Piemonte.vrt *.tif -a_srs "EPSG:32632"


#ritorna nella cartella principale
cd ..


#copia la documentazione nella cartella dei file
cp -r ./Documentazione/Documentazione_OMBRE_Piemonte ./$ombrere/Documentazione


#si sposta nella cartella documentazione
cd ./$ombrere/Documentazione


#inserisce il nome e cognome per l'attribuzione della licenza nel file OMBRE_Piemonte-licenza.txt al posto di "Licenziatario"
sed -i "s/licenziatario/$parola/" OMBRE_Piemonte-licenza.txt


#converte il file OMBRE_PIEMONTE-licenza.txt in PDF
unoconv -f pdf OMBRE_PIEMONTE-licenza.txt


#rimuove il file OMBRE_PIEMONTE-licenza.txt
rm OMBRE_Piemonte-licenza.txt


#ritorna nella cartella principale
cd ..
