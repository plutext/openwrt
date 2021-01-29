#!/bin/sh

ROOTER=/usr/lib/rooter
ROOTER_LINK="/tmp/links"

log() {
        logger -t "Power Toggle" "$@"
}

waitfor() {
	CNTR=0
	while [ ! -e /tmp/modgone ]; do
		sleep 1
		CNTR=`expr $CNTR + 1`
		if [ $CNTR -gt 60 ]; then
			break
		fi
	done
}

rebind() {
	CFUNDONE="no"
	CURRMODEM=$(uci get modem.general.modemnum)
	PROT=$(uci -q get modem.modem$CURRMODEM.proto)
	CPORT=""
	CPORT=$(uci -q get modem.modem$CURRMODEM.commport)
	if [ -n "$CPORT" ]; then
		VENDOR=$(uci -q get modem.modem$CURRMODEM.idV)
		case $VENDOR in
			"12d1" )
				ATCMDD="AT^RESET"
				;;
			* )
				ATCMDD="AT+CFUN=0;+CFUN=1,1"
				;;
		esac
		OX=$($ROOTER/gcom/gcom-locked "/dev/ttyUSB$CPORT" "run-at.gcom" "$CURRMODEM" "$ATCMDD")
		if `echo ${OX} | grep "OK" 1>/dev/null 2>&1`
		then
			CFUNDONE="yes"
			log "Hard modem reset done on /dev/ttyUSB$CPORT to reload drivers"
			ifdown wan$CURRMODEM
			uci delete network.wan$CURRMODEM
			uci set network.wan$CURRMODEM=interface
			uci set network.wan$CURRMODEM.proto=dhcp
			uci set network.wan$CURRMODEM.ifname="wan"$CURRMODEM
			uci set network.wan$CURRMODEM.metric=$CURRMODEM"0"
			uci commit network
			/etc/init.d/network reload
			ifdown wan$CURRMODEM
			echo "1" > /tmp/modgone
			log "Setting Modem Removal flag"
		fi
	fi
	if [ "$CFUNDONE" = "no" ]; then
		PORT=$1
		log "Re-binding USB driver on $PORT to reset modem"
		echo $PORT > /sys/bus/usb/drivers/usb/unbind
		sleep 15
		echo $PORT > /sys/bus/usb/drivers/usb/bind
		sleep 10
		ifdown wan$CURRMODEM
		uci delete network.wan$CURRMODEM
		uci set network.wan$CURRMODEM=interface
		uci set network.wan$CURRMODEM.proto=dhcp
		uci set network.wan$CURRMODEM.ifname="wan"$CURRMODEM
		uci set network.wan$CURRMODEM.metric=$CURRMODEM"0"
		uci commit network
		/etc/init.d/network reload
		ifdown wan$CURRMODEM
		echo "1" > /tmp/modgone
		log "Setting Modem Removal flag"
		if [ -n "$CPORT" ]; then
			ATCMDD="AT+CFUN=0;+CFUN=1,1"
			OX=$($ROOTER/gcom/gcom-locked "/dev/ttyUSB$CPORT" "run-at.gcom" "$CURRMODEM" "$ATCMDD")
			sleep 30
		else
			if [ -f $ROOTER_LINK/reconnect$CURRMODEM ]; then
				$ROOTER_LINK/reconnect$CURRMODEM $CURRMODEM &
			fi
		fi
	fi
}

power_toggle() {
	MODE=$1
	if [ -f "/tmp/gpiopin" ]; then
		rm -f /tmp/modgone
		source /tmp/gpiopin
		echo "$GPIOPIN" > /sys/class/gpio/export
		echo "out" > /sys/class/gpio/gpio$GPIOPIN/direction
		if [ -z $GPIOPIN2 ]; then
			echo 0 > /sys/class/gpio/gpio$GPIOPIN/value
			waitfor
			echo 1 > /sys/class/gpio/gpio$GPIOPIN/value
		else
			echo "$GPIOPIN2" > /sys/class/gpio/export
			echo "out" > /sys/class/gpio/gpio$GPIOPIN2/direction
			if [ $MODE = 1 ]; then
				echo 0 > /sys/class/gpio/gpio$GPIOPIN/value
				waitfor
				echo 1 > /sys/class/gpio/gpio$GPIOPIN/value
			fi
			if [ $MODE = 2 ]; then
				echo 0 > /sys/class/gpio/gpio$GPIOPIN2/value
				waitfor
				echo 1 > /sys/class/gpio/gpio$GPIOPIN2/value
			fi
			if [ $MODE = 3 ]; then
				echo 0 > /sys/class/gpio/gpio$GPIOPIN/value
				echo 0 > /sys/class/gpio/gpio$GPIOPIN2/value
				waitfor
				echo 1 > /sys/class/gpio/gpio$GPIOPIN/value
				echo 1 > /sys/class/gpio/gpio$GPIOPIN2/value
			fi
			sleep 2
		fi
		echo "1" > /tmp/modgone
		log "Setting Modem Removal flag"
	else
		# unbind/bind driver from USB to reset modem when power toggle is selected, but not available
		if [ $MODE = 1 ]; then
			PORT="usb1"
			rebind $PORT
		fi
		if [ $MODE = 2 ]; then
			PORT="usb2"
			rebind $PORT
		fi
		echo "1" > /tmp/modgone
		log "Setting Modem Removal flag"
	fi
}

power_toggle $1
