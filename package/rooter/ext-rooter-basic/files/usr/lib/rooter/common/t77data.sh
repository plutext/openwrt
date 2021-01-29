#!/bin/sh

ROOTER=/usr/lib/rooter

log() {
	logger -t "T77 Data" "$@"
}

CURRMODEM=$1
COMMPORT=$2

OX=$($ROOTER/gcom/gcom-locked "$COMMPORT" "t77info.gcom" "$CURRMODEM" | tr 'a-z' 'A-Z')
O=$($ROOTER/common/processat.sh "$OX")
O=$(echo $O)

RSRP=""
RSRQ=""
CHANNEL="-"
ECIO="-"
RSCP="-"
ECIO1=" "
RSCP1=" "
MODE="-"
MODTYPE="-"
NETMODE="-"
LBAND="-"
TEMP="-"

Oup=$(echo $O | tr 'a-z' 'A-Z')

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

MODE="-"
WS46=$(echo $O" " | grep -o "+COPS: .\+ OK " | tr " " ",")
TECH=$(echo $WS46 | cut -d, -f5)

if [ ! -z "$TECH" ]; then
	MODE=$TECH
	SGCELL=$(echo $O" " | grep -o "\$QCSQ .\+ OK " | tr " " "," | tr ",:" ",")

	WS46=$(echo $O" " | grep -o "AT\$QCSYSMODE? .\+ OK ")
	WS46=$(echo "$WS46" | sed -e "s/AT\$QCSYSMODE? //g")
	WS46=$(echo "$WS46" | sed -e "s/ OK//g")
	
	case $MODE in
		*)
			RSCP=$(echo $SGCELL | cut -d, -f8)
			RSCP="-"$(echo $RSCP | grep -o "[0-9]\{1,3\}")
			ECIO=$(echo $SGCELL| cut -d, -f5)
			ECIO="-"$(echo $ECIO | grep -o "[0-9]\{1,3\}")
			RSSI=$(echo $SGCELL | cut -d, -f4)
			CSQ_RSSI="-"$(echo $RSSI | grep -o "[0-9]\{1,3\}")" dBm"
			;;
		"7")
			RSSI=$(echo $SGCELL | cut -d, -f4)
			CSQ_RSSI=$(echo $RSSI | grep -o "[0-9]\{1,3\}")" dBm"
			RSCP=$(echo $SGCELL | cut -d, -f8)
			RSCP="-"$(echo $RSCP | grep -o "[0-9]\{1,3\}")" (RSRP)"
			ECIO=$(echo $SGCELL| cut -d, -f4)
			ECIO="-"$(echo $ECIO | grep -o "[0-9]\{1,3\}")" (RSRQ)"
			;;	
	esac

	MODE=$WS46
fi

NETMODE="1"
MODTYPE="8"


echo 'CSQ="'"$CSQ"'"' > /tmp/signal$CURRMODEM.file
echo 'CSQ_PER="'"$CSQ_PER"'"' >> /tmp/signal$CURRMODEM.file
echo 'CSQ_RSSI="'"$CSQ_RSSI"'"' >> /tmp/signal$CURRMODEM.file
echo 'ECIO="'"$ECIO"'"' >> /tmp/signal$CURRMODEM.file
echo 'RSCP="'"$RSCP"'"' >> /tmp/signal$CURRMODEM.file
echo 'ECIO1="'"$ECIO1"'"' >> /tmp/signal$CURRMODEM.file
echo 'RSCP1="'"$RSCP1"'"' >> /tmp/signal$CURRMODEM.file
echo 'MODE="'"$MODE"'"' >> /tmp/signal$CURRMODEM.file
echo 'MODTYPE="'"$MODTYPE"'"' >> /tmp/signal$CURRMODEM.file
echo 'NETMODE="'"$NETMODE"'"' >> /tmp/signal$CURRMODEM.file
echo 'CHANNEL="'"$CHANNEL"'"' >> /tmp/signal$CURRMODEM.file
echo 'LBAND="'"$LBAND"'"' >> /tmp/signal$CURRMODEM.file
echo 'TEMP="'"$TEMP"'"' >> /tmp/signal$CURRMODEM.file

CONNECT=$(uci get modem.modem$CURRMODEM.connected)
if [ $CONNECT -eq 0 ]; then
    exit 0
fi

if [ "$CSQ" = "-" ]; then
	log "$OX"
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
