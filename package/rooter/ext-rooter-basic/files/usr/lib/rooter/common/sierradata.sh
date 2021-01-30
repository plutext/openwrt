#!/bin/sh

ROOTER=/usr/lib/rooter

log() {
	logger -t "Sierra Data" "$@"
}

CURRMODEM=$1
COMMPORT=$2

TEMP="-"

get_sierra() {
	OX=$($ROOTER/gcom/gcom-locked "$COMMPORT" "sierrainfo.gcom" "$CURRMODEM")

	O=$($ROOTER/common/processat.sh "$OX")
	O=$(echo $O)
}

read_ssc() {
	SLBAND=$(echo $Oup | grep -o ":ACTIVE LTE "$SSCx" BAND: B[0-9]\+ LTE "$SSCx" BW :")
	SLBAND=$(echo $SLBAND | grep -o " BAND: B[0-9]\+ ")
	if [ -n "$SLBAND" ]; then
		SLBAND=$(echo $SLBAND | grep -o "[0-9]\+")
		SLBAND=$(printf " aggregated with:<br />B%d" $SLBAND)
		BWD=$(echo $Oup | grep -o " LTE "$SSCx" BW : [.012345]\+ LTE")
		BWD=$(echo $BWD | grep -o " BW : [.012345]\+" | grep -o "[.012345]\+")
		if [ -n "$BWD" ]; then
			SLBAND=$SLBAND$(printf " (Bandwidth %s MHz)" $BWD)
		else
			SLBAND=$SLBAND$(printf " (Bandwidth unknown)")
		fi
		LBAND=$LBAND$SLBAND
		XTRACHAN=$(echo $Oup | grep -o " LTE "$SSCx" CHAN: [0-9]\+")
		XTRACHAN=$(echo "$XTRACHAN" | grep -o "[0-9]\{2,6\}")
		if [ -n "$XTRACHAN" ]; then
			CHANNEL=$(echo "$CHANNEL", "$XTRACHAN")
		fi
	fi
}

get_sierra

Oup=$(echo $O | tr 'a-z' 'A-Z')

PCI="-"
PCIx=$(echo $Oup | grep -o "!LTEINFO: .\+ INTERFREQ:" | tr " " ",")
if [ -n "$PCIx" ]; then
	PCI=$(echo $PCIx | cut -d, -f26 | grep -o "[0-9]\{1,3\}")
	if [ -z "$PCI" ]; then
		PCI="-"
	fi
fi
CSQ=$(echo $O | grep -o "CSQ: [0-9]\+" | grep -o "[0-9]\+")
[ "x$CSQ" = "x" ] && CSQ=-1

if [ $CSQ -ge 0 -a $CSQ -le 31 ]; then
	CSQ_PER=$(($CSQ * 100/31))
	CSQ_RSSI=$((2 * CSQ - 113))
	CSQX=$CSQ_RSSI
	[ $CSQ -eq 0 ] && CSQ_RSSI="<= "$CSQ_RSSI
	[ $CSQ -eq 31 ] && CSQ_RSSI=">= "$CSQ_RSSI
	CSQ_PER=$CSQ_PER"%"
	CSQ_RSSI=$CSQ_RSSI" dBm"
else
	CSQ="-"
	CSQ_PER="-"
	CSQ_RSSI="-"
fi

WCHANNEL=$(echo "$O" | awk -F[\ ] '/^\UMTS:/ {print $2}')
if [ "x$WCHANNEL" = "x" ]; then
	WCHANNEL="-"
fi

CHANNEL=$(echo "$O" | awk -F[\ ] '/^\Channel:/ {print $2}')
if [ "x$CHANNEL" = "x" ]; then
	CHANNEL="-"
fi

if [ "$WCHANNEL" != "-" ]; then
	CHANNEL=$WCHANNEL" ("$CHANNEL")"
fi

LCHAN=$(echo $Oup | grep -o "LTE RX CHAN: [0-9]\+")
if [ -n "$LCHAN" ]; then
	CHANNEL=$(echo $LCHAN | grep -o "[0-9]\+")
fi

if [ "$CHANNEL" == "-" ]; then
	CHANNEL=$(echo $OX | tr 'a-z' 'A-Z' | grep -o " WCDMA CHANNEL: [0-9]\+ GMM")
	if [ -n "$CHANNEL" ]; then
		CHANNEL=$(echo "$CHANNEL" | grep -o "[0-9]\+")
	else
		CHANNEL="-"
	fi
fi

LBAND=$(echo $Oup | grep -o "LTE BAND:[ ]*B[0-9]\+ LTE BW:[ .012345]\+ MHZ")
if [ -z "$LBAND" ]; then
	LBAND="-"
else
	LBAND=$(echo $LBAND | grep -o "[.0-9]\+")
	LBAND=$(printf "B%d (Bandwidth %s MHz)" $LBAND)
fi

SLBAND=$(echo $Oup | grep -o " ACTIVE LTE SCELL BAND:[ ]*B[0-9]\+ LTE SCELL BW:[ ]*[.012345]\+ MHZ")
if [ -n "$SLBAND" ]; then
	SLBAND=$(echo $SLBAND | grep -o "[.0-9]\+")
	SLBAND=$(printf " aggregated with:<br />B%d (Bandwidth %s MHz)" $SLBAND)
	LBAND=$LBAND$SLBAND
	XTRACHAN=$(echo $Oup | grep -o " LTE SCELL CHAN:[0-9]\+")
	XTRACHAN=$(echo "$XTRACHAN" | grep -o "[0-9]\{2,6\}")
	if [ -n "$XTRACHAN" ]; then
		CHANNEL=$(echo "$CHANNEL", "$XTRACHAN")
	fi
fi

SSCx="SSC1"
read_ssc
SSCx="SSC2"
read_ssc
SSCx="SSC3"
read_ssc
SSCx="SSC4"
read_ssc

ECIO=$(echo $O | grep -oE "ECIOx: [+-]?[.0-9]+" | grep -o "[:].\+" | grep -o "[^: ]\+")
[ "x$ECIO" = "x" ] && ECIO="-"
ECIO1=$(echo $O | grep -oE "ECIO1x: [+-]?[.0-9]+" | grep -o "[:].\+" | grep -o "[^: ]\+")
[ "x$ECIO1" = "x" ] && ECIO1=" "
[ "$ECIO1" = "n/a" ] && ECIO1=" "

RSCP=$(echo $O | grep -oE "RSCPx: -[0-9]+" | grep -o "[:].\+" | grep -o "[^: ]\+")
[ "x$RSCP" = "x" ] && RSCP="-"
RSCP1=$(echo $O | grep -oE "RSCP1x: -[0-9]+" | grep -o "[:].\+" | grep -o "[^: ]\+")
[ "x$RSCP1" = "x" ] && RSCP1=" "
[ "$RSCP1" = "n/a" ] && RSCP1=" "

RSSI3=$(echo $O | grep -oE "RSSSI3: -[0-9]+" | grep -o "[:].\+" | grep -o "[^: ]\+")
if [ "x$RSSI3" != "x" ]; then
	CSQ_RSSI=$RSSI3" dBm"
else
	if [ "$ECIO" != "-" -a "$RSCP" != "-" ]; then
		EX=$(printf %.0f $ECIO)
		CSQ_RSSI=`expr $RSCP - $EX`
		CSQ_RSSI=$CSQ_RSSI" dBm"
	fi
fi

RSSI4=$(echo $O | grep -oE "RSSI4: -[0-9]+" | grep -o "[:].\+" | grep -o "[^: ]\+")
if [ "x$RSSI4" != "x" ]; then
	CSQ_RSSI=$RSSI4" dBm"
	RSRP4=$(echo $O | grep -oE "RSRP4: -[0-9]+" | grep -o "[:].\+" | grep -o "[^: ]\+")
	if [ "x$RSRP4" != "x" ]; then
		RSCP=$RSRP4
		RSRQ4=$(echo $O | grep -oE "RSRQ: -[0-9]+" | grep -o "[:].\+" | grep -o "[^: ]\+")
		if [ "x$RSRQ4" != "x" ]; then
			ECIO=$RSRQ4
		fi
	fi
fi

if [ "$RSCP" == "-" ]; then
	RSCP=$(echo $O | grep -o "RSRP4: -[0-9]\+")
	if [ -z "$RSCP" ]; then
		RSCP=$(echo $Oup | grep -o "PCC RXM RSRP: -[0-9]\+")
	fi
	ECIO=$(echo $O | grep -o "RSRQ4: -[.0-9]\+")
	if [ -z "$RSCP" ] || [ -z "$ECIO" ]; then
		RSCP="-"
		ECIO="-"
	else
		RSCP=$(echo $RSCP | grep -o " -[0-9]\+")
		RSCP=${RSCP%%$'\n'*}
		ECIO=$(echo $ECIO | grep -o " -[.0-9]\+")
		ECIO=${ECIO%%$'\n'*}
	fi
fi

if [ "$RSCP" == "-" ]; then
	RSCP=$(echo "$O" | grep -o "CESQ: 99,99,[0-9]\{1,2\},[0-9]\{1,2\},255,255")
	if [ -n "$RSCP" ]; then
		ECIO=$(echo $RSCP | cut -d, -f4)
		RSCP=$(echo $RSCP | cut -d, -f3)
		RSCP=$(($RSCP - 121))
		ECIO=$((($ECIO / 2) - 24))
	else
		RSCP="-"
	fi
fi

MODE="-"
TECH=$(echo $OX | grep -o " \*CNTI: 0,[^ ]\+")
if [ -n "$TECH" ]; then
	MODE=$(echo ${TECH:10})
fi

SELRAT=$(echo $OX | grep -o "!SELRAT:[^0-9]\+[0-9]\{2\}" | grep -o "[0-9]\{2\}")
if [ -n "$SELRAT" ]; then
	MODTYPE="2"
	case $SELRAT in
	"01" )
		NETMODE="5"
		;;
	"02" )
		NETMODE="3"
		;;
	"06" )
		NETMODE="7"
		;;
	* )
		NETMODE="1"
		;;
	esac
fi

TEMP=$(echo "$OX" | awk -F[\ ] '/^\Temperature:/ {print $2}')
if [ "x$TEMP" != "x" ]; then
	TEMP=$TEMP$(printf "\xc2\xb0")"C"
else
	TEMP="unknown"
fi

CMODE=$(uci -q get modem.modem$CURRMODEM.cmode)
if [ "$CMODE" = 0 ]; then
	NETMODE="10"
fi

{
	echo 'CSQ="'"$CSQ"'"'
	echo 'CSQ_PER="'"$CSQ_PER"'"'
	echo 'CSQ_RSSI="'"$CSQ_RSSI"'"'
	echo 'ECIO="'"$ECIO"'"'
	echo 'RSCP="'"$RSCP"'"'
	echo 'ECIO1="'"$ECIO1"'"'
	echo 'RSCP1="'"$RSCP1"'"'
	echo 'MODE="'"$MODE"'"'
	echo 'MODTYPE="'"$MODTYPE"'"'
	echo 'NETMODE="'"$NETMODE"'"'
	echo 'CHANNEL="'"$CHANNEL"'"'
	echo 'LBAND="'"$LBAND"'"'
	echo 'PCI="'"$PCI"'"'
	echo 'TEMP="'"$TEMP"'"'
} > /tmp/signal$CURRMODEM.file

CONNECT=$(uci get modem.modem$CURRMODEM.connected)
if [ $CONNECT -eq 0 ]; then
	exit 0
fi

if [ $CSQ = "-" ]; then
	log "$OX"
fi

ENB="0"
if [ -e /etc/config/failover ]; then
	ENB=$(uci get failover.enabled.enabled)
fi
if [ $ENB = "1" ]; then
	exit 0
fi

WWANX=$(uci get modem.modem$CURRMODEM.interface)
OPER=$(cat /sys/class/net/$WWANX/operstate 2>/dev/null)

if [ ! $OPER ]; then
	exit 0
fi
if echo $OPER | grep -q "unknown"; then
	exit 0
fi

if echo $OPER | grep -q "down"; then
	echo "1" > "/tmp/connstat"$CURRMODEM
fi
