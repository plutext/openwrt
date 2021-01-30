#!/bin/sh

ROOTER=/usr/lib/rooter

log() {
	logger -t "Lock Band" "$@"
}

mask=$1
length=${#mask}
i=0
ii=1
lst=""
ij=$((length-1))
while [ $i -le $ij ]
do
	dgt=${mask:$i:1}
	if [ $dgt == "1" ]; then
		lst=$lst$ii" "
	fi
	i=$((i+1))
	ii=$((ii+1))
done
mask=$(lua $ROOTER/luci/encodemask.lua $lst)
mask=$(echo $mask | sed 's/^0*//')

CURRMODEM=$(uci get modem.general.miscnum)
COMMPORT="/dev/ttyUSB"$(uci get modem.modem$CURRMODEM.commport)
CPORT=$(uci -q get modem.modem$CURRMODEM.commport)
uVid=$(uci get modem.modem$CURRMODEM.uVid)
uPid=$(uci get modem.modem$CURRMODEM.uPid)
GW=$(uci get modem.modem$CURRMODEM.GW)

export TIMEOUT="5"
case $uVid in
	"2c7c" )
		M2='AT+QCFG="band",0,'$mask',0'
		ATCMDD="AT"
		NOCFUN=$uVid
		OX=$($ROOTER/gcom/gcom-locked "$COMMPORT" "run-at.gcom" "$CURRMODEM" "$M2")
		log "$OX"
		OX=$($ROOTER/gcom/gcom-locked "$COMMPORT" "run-at.gcom" "$CURRMODEM" "$ATCMDD")
	;;
	"1199" )
		M1='AT!ENTERCND="A710"'
		M2='AT!BAND=11,"Test",0,'$mask',0'
		log "$mask"
		OX=$($ROOTER/gcom/gcom-locked "$COMMPORT" "run-at.gcom" "$CURRMODEM" "$M1")
		log "$OX"
		ATCMDD="AT+CFUN=1,1"
		OX=$($ROOTER/gcom/gcom-locked "$COMMPORT" "run-at.gcom" "$CURRMODEM" "$M2")
		log "$OX"
		M2='AT!BAND=00;!BAND=11'
		OX=$($ROOTER/gcom/gcom-locked "$COMMPORT" "run-at.gcom" "$CURRMODEM" "$M2")
		log "$OX"
		OX=$($ROOTER/gcom/gcom-locked "$COMMPORT" "run-at.gcom" "$CURRMODEM" "$ATCMDD")
	;;
	"8087" )
		ATCMDD='AT+XACT?'
		OX=$($ROOTER/gcom/gcom-locked "/dev/ttyUSB$CPORT" "run-at.gcom" "$CURRMODEM" "$ATCMDD")
		qm=$(echo $OX" " | grep "+XACT:" | tr -d '"' | tr " " ",")
		L1=$(echo $qm | cut -d, -f3)
		if [ $L1 -ge 4 ]; then
			Lx=$(echo $qm | cut -d, -f4)
			L1="AT+XACT="$L1","$Lx
			Lx=$(echo $qm | cut -d, -f5)
			L1=$L1","$Lx","
		fi
		j=$mask
		length=${#j}
		jx=$j
		length=${#jx}

		str=""
		i=$((length-1))
		while [ $i -ge 0 ]
		do
			dgt="0x"${jx:$i:1}
			DecNum=`printf "%d" $dgt`
			Binary=
			Number=$DecNum
			while [ $DecNum -ne 0 ]
			do
				Bit=$(expr $DecNum % 2)
				Binary=$Bit$Binary
				DecNum=$(expr $DecNum / 2)
			done
			if [ -z $Binary ]; then
				Binary="0000"
			fi
			len=${#Binary}
			while [ $len -lt 4 ]
			do
				Binary="0"$Binary
				len=${#Binary}
			done
			revstr=""
			length=${#Binary}
			ii=$((length-1))
			while [ $ii -ge 0 ]
			do
				revstr=$revstr${Binary:$ii:1}
				ii=$((ii-1))
			done
			str=$str$revstr
			i=$((i-1))
		done
		len=${#str}
		ii=0
		lst=""
		while [ $ii -lt $len ]
		do
			bnd=${str:$ii:1}
			if [ $bnd -eq 1 ]; then
				jj=$((ii+101))
				if [ -z $lst ]; then
					lst=$jj
				else
					lst=$lst","$jj
				fi
			fi
			ii=$((ii+1))
		done
		ATCMDD="$L1$lst"
		OX=$($ROOTER/gcom/gcom-locked "/dev/ttyUSB$CPORT" "run-at.gcom" "$CURRMODEM" "$ATCMDD")
		log "$OX"
		ATCMDD="AT+CFUN=1,1"
		OX=$($ROOTER/gcom/gcom-locked "/dev/ttyUSB$CPORT" "run-at.gcom" "$CURRMODEM" "$ATCMDD")
	;;
	* )
		exit 0
	;;
esac

CFUNDONE=false
if `echo ${OX} | grep "OK" 1>/dev/null 2>&1` && \
[[ ! `echo $NOCFUN | grep -o "$uVid"` ]]; then
	CFUNDONE=true
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
	log "Setting Modem Removal flag (1)"
fi
if ! $CFUNDONE; then
		PORT="usb1"
		log "Re-binding USB driver on $PORT to reset modem"
		echo $PORT > /sys/bus/usb/drivers/usb/unbind
		sleep 15
		echo $PORT > /sys/bus/usb/drivers/usb/bind
		sleep 10
		PORT="usb2"
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
		log "Setting Modem Removal flag (2)"
		if [[ -n "$CPORT" ]] && [[ ! `echo $NOCFUN | grep -o "$uVid"` ]]; then
			OX=$($ROOTER/gcom/gcom-locked "/dev/ttyUSB$CPORT" "run-at.gcom" "$CURRMODEM" "$ATCMDD")
			sleep 30
		else
			if [ -f $ROOTER_LINK/reconnect$CURRMODEM ]; then
				$ROOTER_LINK/reconnect$CURRMODEM $CURRMODEM &
			fi
		fi
	fi
	