#!/bin/bash

#Script per la creazione delle curve 20 metri in formato OSM


#carica il file di configuraione delle variabili
source "./configurazione"


#verifica che sia presente la cartella con i file sorgenti del Dtm5
if [[ ! -d $sdtm ]]
then
  echo "Non esiste la cartella $sdtm, fai girare lo script scaricadtm.sh prima di questo"
  exit 3
fi

if [[ ! -d $tif ]]
then
  echo "Non esiste la cartella $tif, fai girare lo script scaricadtm.sh prima di questo"
  exit 2
fi


#verifica che sia presente Ogr2osm
if [[ ! -e $ogr2osm ]]
then
  echo "Non trovo ogr2osm, se non lo hai già scaricato lo trovi qui:"
  echo "https://github.com/pnorman/ogr2osm"
  echo "oppure controlla di averlo messo nel percorso giusto"
  exit 1
fi


#verifica la presenza delle cartella dei file OSM e la crea se non è già esistente
if [ -d $uscitaosm20 ]; then
    echo "OK - $uscitaosm20 esiste."
else
    mkdir $uscitaosm20
fi


#rimuove i files eventualmente presenti nella cartella dei file OSM
rm -r $uscitaosm20/*


########Crea o copia il file della Regione


#verifica se è presente il file con le curve a 20 metri della Regione, altrimenti li crea
if [ -f $curve20re/SHP20_Piemonte.shp ]; then
    echo "OK - $curve20re/SHP20_Piemonte.shp esiste."
    echo 
    echo "Copio il file nella cartella"
    cp ./$curve20re/SHP20*.* ./$uscitaosm20/
else

	#rimuove i files vrt eventualmente presenti nella cartella delle immagini
	rm $tif/*.vrt


	#si sposta nella cartella dei file di servizio
	cd ./Scarico


	#crea le curve
	for filename in $(ls Regione.txt); do
		# prendo solo il nome del file
		n=$(echo $filename | awk -F \. {'print $1'})
		#crea la cartella della provincia
		echo
		echo "Creo la cartella per la Regione"
		mkdir ../$uscitaosm20/$n
		#legge il codice delle sezioni da copiare nellla cartella della provincia
		cat $n.txt | \
		while read riga; do
		echo $riga
		#prende il codice della sezione
		codice=`echo $riga | cut -d " " -f 1`
		#sposta il file selezionato
		cp ../$tif/DTM5_$codice.tif ../$uscitaosm20/$n/
		done
		#crea il file vrt unico per la regione
		echo
		echo "Creo il file vrt per la Regione"
		gdalbuildvrt ../$uscitaosm20/$n/SHP20_$n.vrt ../$uscitaosm20/$n/*.tif -a_srs "EPSG:32632"
		#crea le curve
		echo
		echo "Creo le curve della Regione"
		gdal_contour -b 1 -a name -i 20.0 -f "ESRI Shapefile" ../$uscitaosm20/$n/SHP20_$n.vrt "../$uscitaosm20/SHP20_Piemonte.shp"

		#cancella tutta la cartella
		rm -r ../$uscitaosm20/$n

	done

	#ritorna nella cartella principale
	cd ..

fi



#######Taglia il file della Regione

#si sposta nella cartella dei file di taglio
cd Taglio/Shp/AMM/

#taglia la regione sulle singole sezioni
for filename in $(ls *.shp); do
	# prendo solo il nome del file
	s=$(echo $filename | awk -F \_ {'print $1'})
	#taglio
	echo
	echo "Taglio il comune $s"
	ogr2ogr -f "ESRI Shapefile" -explodecollections -clipsrc $filename ../../../$uscitaosm20/$s.shp ../../../$uscitaosm20/SHP20_Piemonte.shp

done


#si sposta nella crtella principale
cd ../../..


#cancella il file della regione intera
rm $uscitaosm20/SHP20*.*



########Ciclo di conversione in formato PBF

#id massimo preso dalla history di osm con 9 davanti, in modo che sia motlo superiore per parecchio tempo
id=93937119999


#si sposta nella cartella delle curve
cd $uscitaosm20


#prende uno ad uno i file da convertire
for filename in $(ls *.shp); do
	# prendo solo il nome del file
	s=$(echo $filename | awk -F \. {'print $1'})
	#converte il file in formato OSM
	echo
	echo "Converto la sezione $s in formato OSM"
	python $ogr2osm --positive-id --id=$id --add-version --add-timestamp --force $s.shp -o "$s.osm"
	#rimuove gli zeri dopo la virgola sulla quota
	#echo
	#echo "Tolgo gli zeri dopo la virgola sulla quota"
	#sed -i 's/.000"\/><tag k/"\/><tag k/g' $s.osm
	#converte in PBF per occupare meno spazio e rimuove i file in formato OSM e SHP
	echo
	echo "Converto la sezione $s in formato PBF"
	osmconvert $s.osm -o=curve_$s.pbf
	rm $s.*

	id=`expr $id + 8000000`
done


#Unisce i files in uno solo
listafiles=`ls *.pbf`
numfiles=`echo $listafiles | wc -w`
echo
echo "Lista file da unire"
echo $listafiles
arg=""

let "nummerge = $numfiles - 1"
argmerge=`yes " --merge" | head -n $nummerge`

#crea gli argomenti con i files 
for osm in $listafiles
	do
	arg="$arg --rbf $osm"
done

#crea gli argomenti con --merge
argmerge=`yes " --merge" | head -n $nummerge`
echo
echo "$numfiles da unire"

#unisce i file
echo
echo Unisco i file
osmium merge *.pbf -o curve20.pbf


#cancella i singoli file delle curve
rm curve_*.pbf


#ritorna nella cartella principale
cd ..
