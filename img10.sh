#!/bin/bash

#Script per la creazione delle curve (passo 10 metri) e DTM in formato IMG


#carica il file di configuraione delle variabili
source "./configurazione"


#verifica che sia presente la cartella con i file sorgenti in formato OSM
if [[ ! -d $uscitaosm10 ]]
then
  echo "Non esiste la cartella $uscitaosm10, fai girare lo script osm10.sh prima di questo"
  exit 4
fi


#verifica che sia presente Gmaptool
if [[ ! -e $GMT ]]
then
  echo "Non trovo gmt, se non lo hai già scaricato lo trovi qui:"
  echo "http://www.gmaptool.eu"
  echo "oppure controlla di averlo messo nel percorso giusto"
  exit 3
fi


#verifica che sia presente mkgmap
if [[ ! -e $mkgmap ]]
then
  echo "Non trovo mkgmap, se non lo hai già scaricato lo trovi qui:"
  echo "https://www.mkgmap.org.uk/download/mkgmap.html"
  echo "oppure controlla di averlo messo nel percorso giusto"
  exit 2
fi


#verifica che sia presente splitter
if [[ ! -e $splitter ]]
then
  echo "Non trovo splitter, se non lo hai già scaricato lo trovi qui:"
  echo "https://www.mkgmap.org.uk/download/splitter.html"
  echo "oppure controlla di averlo messo nel percorso giusto"
  exit 1
fi


#crea la cartella per i file IMG se non è già esistente
if [ -d $uscitaimg10 ]; then
    echo "OK - $uscitaimg10 esiste."
else
    mkdir $uscitaimg10
fi


#cancella le cartelle di destinazione (se presenti)
rm -r $uscitaimg10/GPS_10m
rm -r $uscitaimg10/NewGPS_10m
rm -r $uscitaimg10/Basemap_10m
rm $uscitaimg10/*_10m-*.zip


#chiede il nome e cognome per l'attribuzione della licenza
echo
echo
echo -n "inserisci il tuo nome e cognome per l'attribuzione: "
read parola


#crea il files della licenza
cp Stile_Garmin/Licenza.txt Stile_Garmin/curve_licenza.txt


#inserisce il nome e cognome per l'attribuzione della licenza nel file licenza.txt al posto di "Licenziatario"
sed -i "s/licenziatario/$parola/" Stile_Garmin/curve_licenza.txt


########Ciclo di creazione formato Garmin

#divide e converte le curve di livello in formato IMG

java $Xmx -jar $splitter \
--max-nodes=1600000 \
--max-areas=300 \
--mapid=56100001 \
--output-dir=$uscitaimg10 \
$uscitaosm10/curve10.pbf

for infile in $uscitaimg10/56100*.osm.pbf
  do
  MAPNAME=$(basename $infile .osm.pbf)
  echo processing $MAPNAME

  java $Xmx -jar $mkgmap --code-page=1252 \
    --mapname=$MAPNAME \
    --description="DTM5 Curve_10m" \
    --country-name="Italia" \
    --region-name="Piemonte" \
    --copyright-message="$copyright" \
    --output-dir=$uscitaimg10 \
    --style-file=Stile_Garmin/dtm5_curve \
    --show-profiles=1 \
    --draw-priority=30 \
    --transparent \
    --license-file=Stile_Garmin/curve_licenza.txt \
  $infile
done


#cancella i file di sevizio
rm $uscitaimg10/areas.*
rm $uscitaimg10/densities-out.txt
rm $uscitaimg10/temp*.*
rm $uscitaimg10/*.osm.pbf


# compilo il file typ dal formato testo
     java -jar $mkgmap \
     --family-id=1810 \
     Stile_Garmin/Typ/${TYPFILE_VERSION}.txt

mv ${TYPFILE_VERSION}.typ Stile_Garmin/Typ

MASTER_TYPFILE=Stile_Garmin/Typ/${TYPFILE_VERSION}.typ


# creo le varianti del file master TYP file con le differenze
# cambia solamente il family ID:
for FID in 1810
do
  cp $MASTER_TYPFILE Stile_Garmin/Typ/$FID.TYP
  $GMT -w -y $FID,1 Stile_Garmin/Typ/$FID.TYP
done


# ora creo i singoli livelli che comporranno la mappa
# e definisco i singoli file:

DTM5_Curve=$(ls $uscitaimg10/56100*.img)

# make the target directory
mkdir $uscitaimg10/GPS_10m
mkdir $uscitaimg10/NewGPS_10m
mkdir $uscitaimg10/Basemap_10m

# unisco il file di ogni strato in un file IMG separato per i nuovi disposistivi come ad es. il gps64

$GMT -j -o $uscitaimg10/NewGPS_10m/Curve_10m.img \
     -f 1810,1 -m "DTM5 Curve_10m" $DTM5_Curve ./Stile_Garmin/Typ/1810.TYP

    
# gli strati ora vengono uniti in un unico gmapsupp.img per i vecchi dispositivi:

$GMT -j -o $uscitaimg10/GPS_10m/gmapsupp.img -m "DTM5 Curve_10m (GPS)" \
     $uscitaimg10/NewGPS_10m/Curve_10m.img


# Ora creo versioni di divisione della mappa per l'utilizzo con Basecamp

# Questo cciclo di mkgmap è usato per fare una mappa panoramica mapset.img
# Che viene utilizzato da Basecamp:

java -jar $mkgmap \
  --series-name="DTM5 Curve_10m (PC version)" \
  --overview-mapname="mapset"   \
  --country-name="Italia"       \
  --region-name="Piemonte"      \
  --output-dir=$uscitaimg10/Basemap_10m     \
  --family-id=1810              \
  --draw-priority=30            \
  --family-name="DTM5 Curve di livello" \
  --product-id=1               \
  $DTM5_Curve                  \
  $MASTER_TYPFILE


# Il file tdb che è stato creato nel processo non funziona
# E non ne abbiamo bisogno, quindi provvedo ad eliminarlo:

rm $uscitaimg10/Basemap_10m/mapset.tdb


# Facio un gmapsupp.img intermedio, lo utilizziamo per poi dividerlo
# nella creazione dei file per Basecamp:

$GMT -j -o $uscitaimg10/Basemap_10m/gmapsupp.img \
     -m "DTM5 Curve_10m (PC version)" \
     -f 1810,1		\
     $DTM5_Curve        \
     $MASTER_TYPFILE


# E divido il file per Basecamp, che genera alcuni file aggiuntivi necessari
# Per l'installazione su Windows, tra cui il file tdb

$GMT -S \
     -f 1810,1 \
     -o $uscitaimg10/Basemap_10m \
     $uscitaimg10/Basemap_10m/gmapsupp.img

# cancello il file intermedio gmapsupp.img

rm $uscitaimg10/Basemap_10m/gmapsupp.img

# E adesso bisogna patchare il file TDB affinchè contenga le corrette informazioni sul copyright
# Per tutte le parti della mappa

python Stile_Garmin/tdbfile.py $uscitaimg10/Basemap_10m/mapset.tdb

#cancella i file di servizio
rm $uscitaimg10/osmmap.tdb
rm $uscitaimg10/*.img
rm osmmap.*
rm Stile_Garmin/curve_licenza.txt
rm Stile_Garmin/Typ/*.TYP
rm Stile_Garmin/Typ/*.typ


#copia la documentazione nelle cartelle

cp -r Documentazione/Garmin/Documentazione $uscitaimg10/Basemap_10m

cp -r Documentazione/GPS/Documentazione $uscitaimg10/GPS_10m

cp -r Documentazione/NewGPS/Documentazione $uscitaimg10/NewGPS_10m


#crea il nome del file partendo dalla data
data=`date +%Y-%m`


#crea i file zip

#si sposta nella cartella dei file
cd $uscitaimg10


echo
echo
echo "Creo il file zip per Basecamp/Mapsource"
zip -r "Basemap_10m-$data.zip" Basemap_10m

echo
echo
echo "Creo il file zip per GPS"
zip -r "GPS_10m-$data.zip" GPS_10m

echo
echo
echo "Creo il file zip per GPS separato"
zip -r "NewGPS_10m-$data.zip" NewGPS_10m


#si sposta nella cartella principale
cd ..
