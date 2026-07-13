#!/bin/sh
# Asettaa etämonitoroinnin päälle/pois, kirjaamalla halutun statuksen monitoring_status -tiedostoon, jonka is-site-up -skripti lukee

statusFile="/path/to/status/file/monitoring_status"

if [ "$1" = "on" ] || [ "$1" = "off" ] ; then
	echo "$1" > "$statusFile"
	echo "Monitoroinnin status nyt: $(head -1 $statusFile)"
else
	echo "Käyttö: set-monitoring-status.sh on|off"
	if [ ! -f "$statusFile" ] || [ ! -s "$statusFile" ] ; then
		echo "Statustiedosto puuttuu tai on tyhjä. Asetetaan oletuksena monitorointi päälle." 
		echo "on" > "$statusFile"
	fi
	echo "Monitoroinnin status nyt: $(head -1 $statusFile)"	
fi

