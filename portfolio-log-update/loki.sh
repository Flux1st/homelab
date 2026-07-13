#!/bin/sh

# Muutoslokin sijainti. Tiedoston omistajuus määritelty nobody:nogroup
# Typemill pyörii käyttäjänä nobody, ja oma paikallinen käyttäjä lisätty ryhmään nogroup
muutosLokiSivu="/absoluuttinen/polku/lokitiedostoon.md"

# Merkkijono, jonka jälkeen uusi lokimerkintä lisätään
lokiErotin="-----"

# Editorivaihtoehtoina nano ja vim, joissa lokimerkintä aukeaa suoraan editoitavaksi
editorOfChoice="nano"

getDateTime() {
        TZ='Europe/Helsinki' date +"%d.%m.%Y"  
}

# Alustetaan uusi merkintä aikaleimalla
uudenAlku="**`getDateTime`** -- "

# Muutosloki-sivulla varsinainen loki erotetaan alustuskappaleesta merkkijonolla $lokiErotin.
# sed lisää sen jälkeen tekstiin rivinvaihdon ja uuden merkinnän aloittavan aikaleiman.
# Tiedostoon tallennus toteutettu välivaiheen kautta, jotta tiedoston omistajuus säilyy, ja Typemill voi edelleen kirjoittaa samaan tiedostoon
# ('sed -i' loisi väliaikaisen tiedoston, joka muuttaisi lopulta omistajuuden)

uusiTeksti=$(sed "/$lokiErotin/a\ \n$uudenAlku" $muutosLokiSivu)
printf '%s\n' "$uusiTeksti" > $muutosLokiSivu

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
