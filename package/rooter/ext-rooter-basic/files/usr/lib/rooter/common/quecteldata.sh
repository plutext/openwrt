#!/bin/sh

ROOTER=/usr/lib/rooter

log() {
	logger -t "Quectel Data" "$@"
}

CURRMODEM=$1
COMMPORT=$2

decode_bw() {
	BW=$(echo $BW | grep -o "[0-5]\{1\}")
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
	esac
}

OX=$($ROOTER/gcom/gcom-locked "$COMMPORT" "quectelinfo.gcom" "$CURRMODEM" | tr 'a-z' 'A-Z')

OX=$(echo $OX)

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
CTEMP="-"

CSQ=$(echo $OX | grep -o "+CSQ: .\+ +QENG" | tr " " ",")
QENG=$(echo $OX" " | grep -o "+QENG: .\+ OK " | tr " " ",")
QNW=$(echo $OX | grep -o "+QNWINFO: .\+,")
QCA=$(echo $OX" " | grep -o "+QCAINFO: \"S[CS]\{2\}\".\+NWSCANMODE" | tr " " ",")
QNSM=$(echo $OX | grep -o "+QCFG: \"NWSCANMODE\",[0-9]")
QTEMP=$(echo $OX | grep -o "+QTEMP: [0-9]\{1,3\}")
if [ -z $QTEMP ]; then
	QTEMP=$(echo $OX | grep -o "+QTEMP: .\+\",\"[0-9]\{1,3\}\"" | tr " " "," | cut -d, -f3)
fi
CSQ=$(echo $CSQ | cut -d, -f2)
CSQ=$(echo $CSQ | grep -o "[0-9]\{1,2\}")

if [ $CSQ -eq "99" ]; then
	CSQ=""
fi
if [ -n $CSQ ]; then
	CSQ_PER=$(($CSQ * 100/31))"%"
	CSQ_RSSI=$((2 * CSQ - 113))" dBm"
else
	CSQ="-"
	CSQ_PER="-"
	CSQ_RSSI="-"
fi
if [ -n "$QTEMP" ]; then
	CTEMP=$(echo $QTEMP | grep -o "[0-9]\{1,3\}")$(printf "\xc2\xb0")"C"
fi
RAT=$(echo $QENG | cut -d, -f4 | grep -o "[-A-Z]\{3,6\}")
case $RAT in
	"GSM")
		MODE="GSM"
		;;
	"WCDMA")
		MODE="WCDMA"
		CHANNEL=$(echo $QENG | cut -d, -f9)
		RSCP=$(echo $QENG | cut -d, -f12)
		RSCP="-"$(echo $RSCP | grep -o "[0-9]\{1,3\}")
		ECIO=$(echo $QENG | cut -d, -f13)
		ECIO="-"$(echo $ECIO | grep -o "[0-9]\{1,3\}")
		;;
	"LTE"|"CAT-M"|"CAT-NB")
		MODE="$RAT"
		CHANNEL=$(echo $QENG | cut -d, -f10)
		LBAND=$(echo $QENG | cut -d, -f11)
		BW=$(echo $QENG | cut -d, -f12)
		decode_bw
		BWU=$BW
		BW=$(echo $QENG | cut -d, -f13)
		decode_bw
		BWD=$BW
		if [ -z "$BWD" ]; then
			LBAND=""
		fi
		if [ -z "$BWU" ]; then
			LBAND=""
		fi
		if [ -z "$LBAND" ]; then
			LBAND="-"
		else
			LBAND="B"$LBAND" (Bandwidth $BWD MHz Down | $BWU MHz Up)"
			if [ -n "$QCA" ]; then
				QCA=$(echo $QCA | grep -o "\"S[CS]\{2\}\"[0-9A-Z,\"]\+")
				printf '%s\n' "$QCA" | while read QCAL; do
					if [ $(echo "$QCAL" | cut -d, -f7) = "2" ]; then
						SLBV=$(echo $QCAL | cut -d, -f6 | grep -o "[0-9]\{1,2\}")
						if [ -n "$SLBV" ]; then
							if `echo $LBAND | grep -o "aggregated" >/dev/null 2>&1`; then
								LBAND=$LBAND"<br />B"$SLBV
							else
								LBAND=$LBAND" aggregated with:<br />B"$SLBV
							fi
							BWD=$(echo $QCAL | cut -d, -f3 | grep -o "[0-9]\{1,3\}")
							if [ -n "$BWD" ]; then
								if [ $BWD -gt 14 ]; then
									LBAND=$LBAND" (Bandwidth "$(($(echo $BWD) / 5))" MHz)"
								else
									LBAND=$LBAND" (Bandwidth 1.4 MHz)"
								fi
							fi
						fi
						SCHV=$(echo $QCAL | cut -d, -f2 | grep -o "[0-9]\+")
						if [ -n "$SCHV" ]; then
							CHANNEL=$(echo "$CHANNEL", "$SCHV")
						fi
						echo "$LBAND" > /tmp/lbandvar$CURRMODEM
						echo "$CHANNEL" >> /tmp/lbandvar$CURRMODEM
					fi
				done
			fi
			if [ -e /tmp/lbandvar$CURRMODEM ]; then
				read LBAND < /tmp/lbandvar$CURRMODEM
				CHANNEL=$(tail -n 1 /tmp/lbandvar$CURRMODEM)
				rm /tmp/lbandvar$CURRMODEM
			fi
		fi
		if [ $RAT = "CAT-M" ] || [ $RAT = "CAT-NB" ]; then
			LBAND="B$(echo $QENG | cut -d, -f11)"
		fi
		RSRP=$(echo $QENG | cut -d, -f15)
		RSRP=$(echo $RSRP | grep -o "[0-9]\{1,3\}")
		if [ -n "$RSRP" ]; then
			RSCP="-"$RSRP" (RSRP)"
		fi
		RSRQ=$(echo $QENG | cut -d, -f16)
		RSRQ=$(echo $RSRQ | grep -o "[0-9]\{1,3\}")
		if [ -n $RSRQ ]; then
			ECIO="-"$RSRQ" (RSRQ)"
		fi
		;;
esac

if [ -n "$QNW" ]; then
	QNW=$(echo $QNW | cut -d\" -f2)
	if [ -n "$QNW" ]; then
		MODE=$QNW
	fi
fi

QNSM=$(echo "$QNSM" | grep -o "[0-9]")
if [ -n "$QNSM" ]; then
	MODTYPE="6"
	case $QNSM in
	"0" )
		NETMODE="1"
		;;
	"1" )
		NETMODE="3"
		;;
	"2"|"5" )
		NETMODE="5"
		;;
	"3" )
		NETMODE="7"
		;;
	esac
fi

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
echo 'TEMP="'"$CTEMP"'"' >> /tmp/signal$CURRMODEM.file

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
