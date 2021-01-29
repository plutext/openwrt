#!/bin/sh
. /lib/functions.sh

do_ssid() {
	local config=$1
	local ssid

	FLG=$(echo $config | grep "default_")
	if [ ! -z $FLG ]; then
		config_get ssid $1 ssid
		FLG=$(echo $ssid | grep $l4)
		if [ -z $FLG ]; then
			ssid=$ssid:$l4
			uci set wireless.$config.ssid=$ssid
			uci commit wireless
			wifi up
		fi
	fi
}

lanmac=$(echo $(echo $(ifconfig br-lan) | tr " " ",") | cut -d, -f5)
l4=${lanmac:12:5}

while [ ! -e /etc/config/wireless ]
do
	sleep 1
done
sleep 3

config_load wireless
config_foreach do_ssid wifi-iface