#!/bin/bash

#file per unire tutte le sezioni in formato shp in un unico file


#carica il file di configuraione delle variabili
source "./configurazione"


#verifica che sia presente la cartella con le sezioni in formato SHP
if [[ ! -d $curve ]]
then
  echo "Non esiste la cartella $curve, fai girare lo script shpcurve.sh prima di questo"
  exit 1
fi


#crea la cartella per il file unito se non è già esistente
if [ -d $regione ]; then
    echo "$regione esiste."
else
    mkdir $regione
fi


#rimuove i file eventualmente presenti nella cartella
rm -r $regione/*


#si sposta nella cartella dei file delle sezioni
cd $curve


#prende i file, pulisce la stringa del nome e li unisce in un unico file
for i in $(find . -type f -name "*.shp") 
	 do  
	  
      #prende il nome del tipo di shp, togliendo dal primo all'ultimo _   
	 tmp2=${i#*_}  
	 tmp=`basename $tmp2`  
	 echo $tmp  
	 tipodishp=`echo "${tmp%\_*}"`  
         echo $tipodishp  
  

   #unisce i file shp  
      if [ -f "../$regione/$tipodishp.shp" ]  
      then  
           echo "unisce"  
           ogr2ogr -f 'ESRI Shapefile' -update -append ../$regione/$tipodishp.shp $i	   
      else  
            echo "crea shp"  
      ogr2ogr -f 'ESRI Shapefile' "../$regione/$tipodishp.shp" $i
fi
done


#passa nella cartella del file della regione
cd ../$regione


#rinomina il file
rename 's/DTM5/Curve_DTM5_Regione/g' DTM5.*


#torna nella cartella principale
cd ..


#copia la cartella documentazione nella cartella delle curve della regione in formato SHP
cp -r ./Documentazione ./$regione/
