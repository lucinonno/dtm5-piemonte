#! /bin/bash

#script per la creazione delle curve in formato Garmin


#carica il file di configuraione delle variabili
source "./configurazione"


# Verifica che sia presente mkgmap.jar per convertire in formato garmin i file OSM
if [[ ! -e $mkgmap ]]
then
  echo "Non trovo $mkgmap, assicurati di averlo scaricato o di"
  echo "aver seguito il percorso giusto"
  exit 4
fi


# Verifica che sia presente splitter.jar per convertire in formato garmin i file OSM
if [[ ! -e $splitter ]]
then
  echo "Non trovo $splitter, assicurati di averlo scaricato o di"
  echo "aver seguito il percorso giusto"
  exit 3
fi


#verifica che sia presente Gmaptool
if [[ ! -e $GMT ]]
then
  echo "Non trovo gmt, se non lo hai già scaricato lo trovi qui:"
  echo "http://www.gmaptool.eu"
  echo "oppure controlla di averlo messo nel percorso giusto"
  exit 2
fi


#verifica che sia presente la cartella con i file del BDTRE convertiti in OSM
if [[ ! -d $uscitaosm ]]
then
  echo "Non esiste la cartella $uscitaosm, fai girare lo script shpaosm.sh e uniscibdtre.sh prima di questo"
  exit 1
fi


#crea la cartella per i file IMG se non è già esistente
if [ -d $uscitaimg ]; then
    echo "$uscitaimg esiste."
else
    mkdir $uscitaimg
fi


#cancella i file nella directory
rm -r $uscitaimg/*


#elimina il file curve_licenza.txt
rm ./stile_garmin/curve_licenza.txt


#fa una copia del file licenza.txt e lo rinomina in curve_licenza.txt
cp ./stile_garmin/licenza.txt ./stile_garmin/curve_licenza.txt


#chiede il nome e cognome per l'attribuzione della licenza e lo inserisce nel file curve_licenza.txt al posto di "Licenziatario"
echo
echo
echo -n "inserisci il tuo nome e cognome per l'attribuzione: "
read parola

sed -i "s/Licenziatario/$parola/" ./stile_garmin/curve_licenza.txt


#ritaglia e converte le curve di livello in formato IMG

#ritaglia i dati sul confine della regione piemonte, all'interno dell cartella Taglio sono presenti anche i file delle province,
#è possibile cambiare il poligono di taglio cambiando il nome PIEMONTE.poly con uno di quelli contenuti nella cartella

#  osmconvert $uscitaosm/Curve_DTM5_regione.pbf -B=./Taglio/Poly/Piemonte.poly --drop-broken-refs -o=$uscitaosm/Curve_DTM5_cut.pbf


java $Xmx -jar $splitter \
--max-nodes=1500000 \
--max-areas=300 \
--mapid=66140001 \
--output-dir=$uscitaimg \
$uscitaosm/Curve_DTM5_cut.pbf


for infile in $uscitaimg/66140*.osm.pbf
  do
  MAPNAME=$(basename $infile .osm.pbf)
  echo processing $MAPNAME

  java $Xmx -jar $mkgmap --code-page=1252 \
    --mapname=$MAPNAME \
    --description="DTM5 Curve di livello" \
    --country-name="Italia" \
    --region-name="Piemonte" \
    --copyright-message="$copycurve" \
    --output-dir=$uscitaimg \
    --style-file=stile_garmin/dtm_curve \
    --show-profiles=1 \
    --draw-priority=10 \
    --transparent \
    --license-file=stile_garmin/curve_licenza.txt \
  $infile
done

rm $uscitaimg/areas.*
rm $uscitaimg/densities-out.txt
rm $uscitaimg/temp*.*
rm $uscitaimg/*.tmp
rm $uscitaimg/*.pbf
rm $uscitaimg/osm*.*
rm $uscitaosm/*cut.pbf


#cancella i file TYP nella directory stile_garmin/Typ
rm stile_garmin/Typ/*.TYP
rm stile_garmin/Typ/*.typ


# compilo il file typ dal formato testo

     java -jar $mkgmap \
     --family-id=1811 \
     stile_garmin/Typ/${TYPFILE_VERSION}.txt

mv ${TYPFILE_VERSION}.typ stile_garmin/Typ

MASTER_TYPFILE=stile_garmin/Typ/${TYPFILE_VERSION}.typ


# creo le varianti del file master TYP file con le differenze
# cambia solamente il family ID:
for FID in 1811
do
  cp $MASTER_TYPFILE stile_garmin/Typ/$FID.TYP
  $GMT -w -y $FID,1 stile_garmin/Typ/$FID.TYP
done


# ora creo i singoli livelli che comporranno la mappa
# e definisco i singoli file:
DTM5_Curve=$(ls $uscitaimg/66140*.img)


# make the target directory
mkdir $uscitaimg/finale
mkdir $uscitaimg/finale/etrex
mkdir $uscitaimg/finale/64
mkdir $uscitaimg/finale/mappe


# unisco il file di ogni strato in un file IMG separato per i nuovi disposistivi come ad es. il gps64
$GMT -j -o $uscitaimg/finale/64/Curve.img \
     -f 1811,1 -m "DTM5 Curve di livello" $DTM5_Curve ./stile_garmin/Typ/1811.TYP

    
# gli strati ora vengono uniti in un unico gmapsupp.img per i vecchi dispositivi:
$GMT -j -o $uscitaimg/finale/etrex/gmapsupp.img -m "DTM5-CURVE-GPS (GPS)" \
     $uscitaimg/finale/64/Curve.img


# Ora creo versioni di divisione della mappa per l'utilizzo con Basecamp

# Questo cciclo di mkgmap è usato per fare una mappa panoramica mapset.img
# Che viene utilizzato da Basecamp:
java -jar $mkgmap \
  --series-name="DTM5-CURVE-GPS Map (PC version)" \
  --overview-mapname="mapset"   \
  --country-name="Italia"       \
  --region-name="Piemonte"      \
  --output-dir=$uscitaimg/finale/mappe     \
  --family-id=1811              \
  --draw-priority=10            \
  --family-name="DTM5 Curve di livello"    \
  --product-id=1                \
  $DTM5_Curve                   \
  $MASTER_TYPFILE


# Il file tdb che è stato creato nel processo non funziona
# E non ne abbiamo bisogno, quindi provvedo ad eliminarlo:
rm $uscitaimg/finale/mappe/mapset.tdb


# Facio un gmapsupp.img intermedio, lo utilizziamo per poi dividerlo
# nella creazione dei file per Basecamp:
$GMT -j -o $uscitaimg/finale/mappe/gmapsupp.img \
     -m "DTM5-CURVE-GPS Map (PC version)" \
     -f 1811,1		\
     $DTM5_Curve        \
     $MASTER_TYPFILE


# E divido il file per Basecamp, che genera alcuni file aggiuntivi necessari
# Per l'installazione su Windows, tra cui il file tdb
$GMT -S \
     -f 1811,1 \
     -o $uscitaimg/finale/mappe \
     $uscitaimg/finale/mappe/gmapsupp.img

# cancello il file intermedio gmapsupp.img
rm $uscitaimg/finale/mappe/gmapsupp.img

# E adesso bisogna patchare il file TDB affinchè contenga le corrette informazioni sul copyright
# Per tutte le parti della mappa BDTRE - OSM- GPS

python stile_garmin/tdbfile.py $uscitaimg/finale/mappe/mapset.tdb

#cancella i file
rm osmmap.tdb
rm osmmap.img
