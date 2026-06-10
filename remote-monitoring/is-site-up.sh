#!/bin/sh

configFile="$PWD/is-site-up.env"

if [ ! -f "$configFile" ] ; then
	echo "Määrittelytiedosto $configFile puuttuu!" >&2
	exit 1
fi

if [ ! -r "$configFile" ] ; then
	echo "Määrittelytiedosto $configFile ei ole luettava!" >&2
	exit 1
fi

. $configFile

#
# FUNKTIOT
#

getDateTime() {
	TZ="$timeZone" date +"$dateTimeFormat"
}

addToLog() {
	# argumenttina $1 logattavan viestin sisältö
	if [ "$1" != "" ] ; then
		echo "`getDateTime` --- $1" >> $logFile
	fi
}

sendToTelegram() {
	# Lähettää viestin Telegram-botin kautta
	# tuottaa lokirivin viestin lähettämisen onnistumisesta

	# argumenttina lähetettävä viesti
	message=$1

	# kokeillaan lähettää viesti botin kautta ja otetaan vastaus talteen
	curlOutput=$(curl -s -X POST https://api.telegram.org/bot$botToken/sendMessage -d chat_id=$chatId -d text="$message" 2>&1)

	if [ "$?" -ne "0" ] ; then
		# curl antoi virheilmoituksen
		logLineTelegram="Ilmoittamisessa virhe! $curlOutput"

	else
		# curl ok, tutkitaan botin vastaus
	        # JSON-vastauksen alussa on joko "ok":true tai "ok":false
		botIsOk=$(echo "$curlOutput" | grep '"ok":true')

		if [ "$botIsOk" ] ; then
			logLineTelegram="Lähetetty ilmoitus Telegramiin onnistuneesti."
		else
			logLineTelegram="Telegram-viestin lähettämisessä ongelma! Botin vastaus: $curlOutput"
		fi
	fi

	echo "$logLineTelegram"
}


#
# SKRIPTIN RUNKO: haetaan sivuston etusivu ja analysoidaan mahdolliset virheet
#

curlOutput=$(curl --no-progress-meter --user $user:$pw https://$domain/ 2>&1)

if [ "$?" -ne "0" ] ; then
	# curl palauttaa virheviestin
	message="Ongelma! $curlOutput"
	telegramResponse=$(sendToTelegram "$message")
else
	# curl ok, eritellään HTML title-sisältö, joka sisältää joko sisältösivun otsikon tai virheviestin
	title=$(echo "$curlOutput" | grep -o '<title>.*</title>' | sed 's|.*<title>\(.*\)</title>|\1|')

	# sivusto mitä todennäköisimmin toimii, jos näkyy Aloitus-sivun otsikko
	frontPageIsServed=$(echo $title | grep "$frontPageTitleString")

	# ...ja sulkeva html-tägi
	fullPageIsShown=$(echo $curlOutput | grep -i "</html>")

	if [ "$frontPageIsServed" ] && [ "$fullPageIsShown" ] ; then
		message="Kaikki OK!"
	else
		message="Ongelma! $title"
		telegramResponse=$(sendToTelegram "$message")
	fi
fi

addToLog "$message"
addToLog "$telegramResponse"


