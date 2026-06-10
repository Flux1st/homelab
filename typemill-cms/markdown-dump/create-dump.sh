
#!/bin/sh

# ---------------------------------------
# Koostesivun luominen Typemill-sisällönhallinnan tekstisisällöistä
#
# Tämä skripti edellyttää, että 'redacted.list'-tiedostossa on eriteltynä riveittäin kuhunkin markdown-tiedostoon tehtävät rivien poistot.
# Formaatti on seuraava:
# /tiedoston_polku_content_hakemistossa/nimi.md {TAB} sed-komennolle suoraan tuleva argumentti
#
# Eli kenttien välissä on yksi sarkainmerkki (tab). Esim. poistetaan content/00-cv/index.md-tiedostosta rivit 3, 8-10 ja 82-86:
# 00-cv/index.md	3d; 8,10d; 82,86d
#---------------------------------------

# sijainnit
contentPath="/var/www/html/content/"
redactedList="${contentPath}redacted.list"
dumpFile="/tmp/whole_site.md"


# Sivuston markdown-tiedostojen listaaminen oikeassa järjestyksessä väliaikaiseen tiedostoon
find "$contentPath" -type f -name "*md" | awk '{ key=$0; gsub(/[0-9]/, "~&", key); printf "%s\t%s\n", key, $0 }' | LC_ALL=C sort | cut -f 2- > filelist.tmp

# Siivottu versio "sisällysluetteloksi"
# sed erottaa regular expressionin mukaan rivin loppuosan, joka tulee polun $content jälkeen, 
# ja lisää siihen kaksi välilyöntiä, joka on markdownissa rivinvaihdon merkki
tiedostoLista=$(cat filelist.tmp | sed "s|$contentPath\(.*\)|\1  |") 

# Koostesivun header:
# ylikirjoittaa samalla jo mahdollisesti olemassaolevan edellisen koostetiedoston

tee $dumpFile > /dev/null <<EOF
# Porfoliosivuston kooste

Tässä dynaamisesti generoituvassa koosteessa on yhdistetty portfoliosivuston koko tekstisisältö, eli markdown-tiedostot valikon mukaisessa järjestyksessä:

$tiedostoLista

Koosteesta on poistettu henkilötietoja sisältävät rivit.


--------------------


# Portfolio
EOF

# Loopataan järjestetty tiedostolista läpi ja verrataan poistolistaan

for contentFile in `cat filelist.tmp`; 
do 
	linesToRedact=""

	while read line;
	do 
		fileToEdit=$(echo "$line" | cut -f 1)
		if [ "$contentFile" == "$contentPath$fileToEdit" ]
		then
			# kun tiedosto löytyy leikkauslistalta, eristetään riviltä sed-komennolle tuleva argumentti
			linesToRedact=$(echo "$line" | cut -f 2)
		fi 
	done < "$redactedList"

	# Mikäli $linesToRedact on tyhjä, sed ei tee mitään, ja sisältösivu liitetään sellaisenaan
	sed "$linesToRedact" < $contentFile >> $dumpFile
	# lisätään myös välikettä joka tiedoston jälkeen
	echo -e "\n\n-------------------------\n\n" >> $dumpFile
done 

rm filelist.tmp
