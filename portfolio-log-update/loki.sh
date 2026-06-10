#!/bin/sh

#########################################################
# Portfoliosivuston muutoslokin päivittämisen helpottaja
# - lisää lokiin päivämääräleiman ja avaa editorin
#########################################################

# Muutoslokin sijainti ja merkkijono, jonka jälkeen uusi lokimerkintä lisätään merkintöjen jonon alkuun
muutosLokiSivu="/absoluuttinen/polku/lokisivulle.md"
lokiErotin="-----"

# Editorivaihtoehtoina nano ja vim, joissa lokimerkintä aukeaa suoraan editoitavaksi
editorOfChoice="nano"

getDateTime() {
        TZ='Europe/Helsinki' date +"%d.%m.%Y"  
}

if [ ! -f "$muutosLokiSivu" ] ; then
        echo "Määritettyä lokisivua $muutosLokiSivu ei ole olemassa!" >&2
        exit 1
fi

if [ ! -r "$muutosLokiSivu" ] ; then
        echo "Lokisivu $muutosLokiSivu ei ole luettava!" >&2
        exit 1
fi

if [ ! -w "$muutosLokiSivu" ] ; then
        echo "Lokisivu $muutosLokiSivu ei ole kirjoitettava!" >&2
        exit 1
fi


# Alustetaan uusi merkintä aikaleimalla
uudenAlku="**`getDateTime`** -- "

# Muutosloki-sivulla varsinainen loki erotetaan alustuskappaleesta merkkijonolla $lokiErotin.
# sed lisää sen jälkeen tiedostoon rivinvaihdon ja uuden merkinnän aloittavan aikaleiman
sed -i "/$lokiErotin/a\ \n$uudenAlku" $muutosLokiSivu

# Haetaan lokiosion aloittavan poikittaisen viivan rivinumero ja lisätään kahdella, jotta päästään uuden merkinnän riville. 
# Vaihtoehtoinen versio, jonka tein ensin: rivi=$(( $(grep -m 1 -n "\-\-\-\-\-" $muutosLokiSivu | cut -d : -f 1) + 2 ))
# sed on huomattavasti yksinkertaisempi:
rivi=$(( $(sed -n "/$lokiErotin/=" $muutosLokiSivu) + 2 ))

# Aikaleimalisäyksen pituus lisättynä yhdellä kertoo tekstin aloitussarakkeen paikan
sarake=$(( ${#uudenAlku} + 1 ))

# Avataan tiedosto halutussa editorissa suoraan uuden merkinnän aloittavaan kohtaan.
# vim:ssä "-c star" aloittaa insert-modessa, eli kirjoittamaan voi alkaa suoraan

case $editorOfChoice in
nano)
	nano +"$rivi,$sarake" $muutosLokiSivu ;;
vim)
	vim -c star -c "call cursor($rivi, $sarake)" $muutosLokiSivu ;;
*)
	nano +"$rivi,$sarake" $muutosLokiSivu ;;
esac
