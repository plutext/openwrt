#!/bin/sh

ROOTER=/usr/lib/rooter

CURRMODEM=$1
COMMPORT=$2

log() {
	logger -t "Telit Data" "$@"
}
decode_bw() {
	case $BW in
		"0")
			BW="1.4"
			;;
		"1")
			BW="3"
			;;
		"2")
			BW="5"
			;;
		"3")
			BW="10"
			;;
		"4")
			BW="15"
			;;
		"5")
			BW="20"
			;;
		*)
			BW=""
			;;
	esac
}
decode_band() {
	if [ "$SLBV" -lt 134 ]; then
		SLBV=$(($SLBV - 119))
	elif [ "$SLBV" -eq 134 ]; then
		SLBV="17"
	elif [ "$SLBV" -lt 143 ]; then
		SLBV=$(($SLBV - 102))
	elif [ "$SLBV" -lt 147 ]; then
		SLBV=$(($SLBV - 125))
	elif [ "$SLBV" -lt 149 ]; then
		SLBV=$(($SLBV - 123))
	elif [ "$SLBV" -lt 152 ]; then
		SLBV=$(($SLBV - 108))
	elif [ "$SLBV" -eq 152 ]; then
		SLBV="23"
	elif [ "$SLBV" -eq 153 ]; then
		SLBV="26"
	elif [ "$SLBV" -eq 154 ]; then
		SLBV="32"
	elif [ "$SLBV" -lt 158 ]; then
		SLBV=$(($SLBV - 30))
	elif [ "$SLBV" -lt 161 ]; then
		SLBV=$(($SLBV - 130))
	elif [ "$SLBV" -eq 161 ]; then
		SLBV="66"
	elif [ "$SLBV" -eq 162 ]; then
		SLBV="250"
	else
		SLBV="46"
	fi

}

idV=$(uci get modem.modem$CURRMODEM.idV)
idP=$(uci get modem.modem$CURRMODEM.idP)

if [ $idP = 1040 -o $idP = 1041 ]; then
	OX=$($ROOTER/gcom/gcom-locked "$COMMPORT" "telitinfo.gcom" "$CURRMODEM" | tr 'a-z' 'A-Z')
else
	OX=$($ROOTER/gcom/gcom-locked "$COMMPORT" "telitinfoln.gcom" "$CURRMODEM" | tr 'a-z' 'A-Z')
fi

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

TMP=$(echo $O" " | grep -o "#TEMPSENS: .\+ OK " | tr " " ",")
if [ -n "$TMP" ]; then
	TEMP=$(echo $TMP | cut -d, -f3)$(printf "\xc2\xb0")"C"
fi

MODE="-"
WS46=$(echo $O | grep -o "+COPS: [0-3],[0-3,\"[^\"].\+\",[027]")
TECH=$(echo $WS46 | cut -d, -f4)

if [ -n "$TECH" ]; then
	MODE=$TECH
	case $MODE in
		"7")
			MODE="LTE"
			CAINFO=$(echo $O | grep -o "#CAINFO: 1.\+OK")
			SGCELL=$(echo $O | grep -o "[#^]RFSTS: \"[ 0-9]\{6,7\}\",[0-9]\{1,5\},.\+,\"[0-9]\{15\}\",\".\+\",[0-3],[0-9]\{1,2\}")
			if [ -n "$SGCELL" ]; then
				RSCP=$(echo $SGCELL | cut -d, -f3)" RSRP"
				ECIO=$(echo $SGCELL | cut -d, -f5)" RSRQ"
				RSSI=$(echo $SGCELL | cut -d, -f4)
				CSQ_RSSI=$(echo "$RSSI dBm")
				CHANNEL=$(echo $SGCELL | cut -d, -f2)
				if [ $(echo ${SGCELL:0:1}) = "#" ]; then
					LBAND=$(echo $SGCELL | cut -d, -f16)
				else
					LBAND=$(echo $SGCELL | cut -d, -f15)
				fi
				BW=$(echo $CAINFO | cut -d, -f3)
				decode_bw
				if [ -n "$BW" ];then
					LBAND=$LBAND" (Bandwidth $BW MHz)"
				fi
				if [ -n "$CAINFO" ]; then
					SCCLIST=$(echo $CAINFO | grep -o "1[2-6][0-9],[0-9]\{1,5\},[0-5],[0-9]\{1,3\},-[0-9]\+,-[0-9]\+,-[0-9]\+,[0-9]\{1,3\},2,[0-5],")
					printf '%s\n' "$SCCLIST" | while read SCCVAL; do
						SLBV=$(echo $SCCVAL | cut -d, -f1)
						decode_band
						if `echo $LBAND | grep -o "aggregated" >/dev/null 2>&1`; then
							LBAND=$LBAND"<br />B"$SLBV
						else
							LBAND=$LBAND" aggregated with:<br />B"$SLBV
						fi
						BW=$(echo $SCCVAL | cut -d, -f3)
						decode_bw
						LBAND=$LBAND" (Bandwidth $BW MHz)"
						SCHV=$(echo $SCCVAL | cut -d, -f2)
						CHANNEL=$(echo "$CHANNEL", "$SCHV")
						echo "$LBAND" > /tmp/lbandvar$CURRMODEM
						echo "$CHANNEL" >> /tmp/lbandvar$CURRMODEM
					done
				fi
				if [ -e /tmp/lbandvar$CURRMODEM ]; then
					read LBAND < /tmp/lbandvar$CURRMODEM
					CHANNEL=$(tail -n 1 /tmp/lbandvar$CURRMODEM)
					rm /tmp/lbandvar$CURRMODEM
				fi
			fi
			;;
		2)
			MODE="UMTS"
			SGCELL=$(echo $O | grep -o "[#^]RFSTS: \"[ 0-9]\{5,7\}\",[0-9]\{1,5\},.\+,\"[0-9]\{15\}\",")
			if [ -n "$SGCELL" ]; then
				RSSI=$(echo $SGCELL | cut -d, -f6)
				CSQ_RSSI=$(echo "$RSSI dBm")
				RSCP=$(echo $SGCELL | cut -d, -f5)
				ECIO=$(echo $SGCELL| cut -d, -f4)
				CHANNEL=$(echo $SGCELL | cut -d, -f2)
			fi
			;;
	esac
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
