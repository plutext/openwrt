#!/bin/sh

ROOTER=/usr/lib/rooter

log() {
	logger -t "Scan Command" "$@"
}

CURRMODEM=$(uci get modem.general.miscnum)
COMMPORT="/dev/ttyUSB"$(uci get modem.modem$CURRMODEM.commport)
uVid=$(uci get modem.modem$CURRMODEM.uVid)
uPid=$(uci get modem.modem$CURRMODEM.uPid)
ACTIVE=$(uci get modem.pinginfo$CURRMODEM.alive)
uci set modem.pinginfo$CURRMODEM.alive='0'
uci commit modem
L1=$(uci get modem.modem$CURRMODEM.L1)
length=${#L1}
L1="${L1:2:length-2}"
L1=$(echo $L1 | sed 's/^0*//')

case $uVid in
	"2c7c" )
		M2='AT+QENG="neighbourcell"'
		case $uPid in
			"0125" ) # EC25-A
				M3="181a"
			;;
			"0306" ) # EP06-A
				M3="2000001003300185A"
			;;
			"0512" ) # EM12-G
				M3="2000001E0BB1F39DF"
			;;
			"0620" ) # EM20-G
				EM20=$(echo $model | grep "EM20")
				if [ ! -z $EM20 ]; then
					M3="20000A7E03B0F38DF"
				else
					exit 0
				fi
			;;
			* )
				M3="AT"
			;;
		esac
		M4='AT+QCFG="band",0,'$M3',0'
		OX=$($ROOTER/gcom/gcom-locked "$COMMPORT" "run-at.gcom" "$CURRMODEM" "$M4")
		log "$OX"
		sleep 5
	;;
	"1199" )
		M2='AT!LTEINFO?'
		case $uPid in

			"68c0"|"9041"|"901f" ) # MC7354 EM/MC7355
				M3="101101A"
			;;
			"9070"|"9071"|"9078"|"9079"|"907a"|"907b" ) # EM/MC7455
				M3="100030818DF"
			;;
			"9090"|"9091"|"90b1" ) # EM7565
				M3="20000A700BA0E19DF"

			;;
			* )
				M3="AT"
			;;
		esac
		M1='AT!ENTERCND="A710"'
		M4='AT!BAND=11,"Test",0,'$M3',0'
		OX=$($ROOTER/gcom/gcom-locked "$COMMPORT" "run-at.gcom" "$CURRMODEM" "$M1")
		log "$OX"
		OX=$($ROOTER/gcom/gcom-locked "$COMMPORT" "run-at.gcom" "$CURRMODEM" "$M4")
		log "$OX"
		M4='AT!BAND=00;!BAND=11'
		OX=$($ROOTER/gcom/gcom-locked "$COMMPORT" "run-at.gcom" "$CURRMODEM" "$M4")
		log "$OX"
	;;
	* )
		rm -f /tmp/scanx
		echo "Scan for Neighbouring cells not supported" >> /tmp/scan
		uci set modem.pinginfo$CURRMODEM.alive=$ALIVE
		uci commit modem
		exit 0
	;;
esac

export TIMEOUT="10"
OX=$($ROOTER/gcom/gcom-locked "$COMMPORT" "run-at.gcom" "$CURRMODEM" "$M2")
OX=$($ROOTER/gcom/gcom-locked "$COMMPORT" "run-at.gcom" "$CURRMODEM" "$M2")
log "$OX"
ERR=$(echo "$OX" | grep "ERROR")
if [ ! -z $ERR ]; then
	OX=$($ROOTER/gcom/gcom-locked "$COMMPORT" "run-at.gcom" "$CURRMODEM" "$M2")
	OX=$($ROOTER/gcom/gcom-locked "$COMMPORT" "run-at.gcom" "$CURRMODEM" "$M2")
	log "$OX"
fi
if [ ! -z $ERR ]; then
	OX=$($ROOTER/gcom/gcom-locked "$COMMPORT" "run-at.gcom" "$CURRMODEM" "$M2")
	OX=$($ROOTER/gcom/gcom-locked "$COMMPORT" "run-at.gcom" "$CURRMODEM" "$M2")
	log "$OX"
fi
log "$OX"
echo "$OX" > /tmp/scanx
rm -f /tmp/scan
echo "Cell Scanner Start ..." > /tmp/scan
echo " " >> /tmp/scan
flg=0
while IFS= read -r line
do
	case $uVid in
	"2c7c" )
		qm=$(echo $line" " | grep "+QENG:" | tr -d '"' | tr " " ",")
		if [ "$qm" ]; then
			INT=$(echo $qm | cut -d, -f3)
			BND=$(echo $qm | cut -d, -f5)
			RSSI=$(echo $qm | cut -d, -f9)
			BAND=$(/usr/lib/rooter/chan2band.sh $BND)
			if [ "$INT" = "intra" ]; then
				echo "Band : $BAND    Signal : $RSSI (dBm) (current connected band)" >> /tmp/scan
			else
				echo "Band : $BAND    Signal : $RSSI (dBm)" >> /tmp/scan
			fi
			flg=1
		fi
	;;
	"1199" )
		qm=$(echo $line" " | grep "Serving:" | tr -d '"' | tr " " ",")
		if [ "$qm" ]; then
			read -r line
			qm=$(echo $line" " | tr -d '"' | tr " " ",")
			BND=$(echo $qm | cut -d, -f1)
			BAND=$(/usr/lib/rooter/chan2band.sh $BND)
			RSSI=$(echo $qm | cut -d, -f13)
			echo "Band : $BAND    Signal : $RSSI (dBm) (current connected band)" >> /tmp/scan
			flg=1
		else
			qm=$(echo $line" " | grep "InterFreq:" | tr -d '"' | tr " " ",")
			log "$line"
			if [ "$qm" ]; then
				while [ 1 = 1 ]
				do
					read -r line
					log "$line"
					qm=""
					qm=$(echo $line" " | grep ":" | tr -d '"' | tr " " ",")
					if [ "$qm" ]; then
						break
					fi
					qm=$(echo $line" " | grep "OK" | tr -d '"' | tr " " ",")
					if [ "$qm" ]; then
						break
					fi
					qm=$(echo $line" " | tr -d '"' | tr " " ",")
					if [ "$qm" = "," ]; then
						break
					fi
					BND=$(echo $qm | cut -d, -f1)
					BAND=$(/usr/lib/rooter/chan2band.sh $BND)
					RSSI=$(echo $qm | cut -d, -f8)
					echo "Band : $BAND    Signal : $RSSI (dBm)" >> /tmp/scan
					flg=1
				done
				break
			fi
		fi
	;;
	* )
	
	;;
	esac
done < /tmp/scanx

rm -f /tmp/scanx
if [ $flg -eq 0 ]; then
	echo "No Neighbouring cells were found" >> /tmp/scan
fi
echo " " >> /tmp/scan
echo "Done" >> /tmp/scan

case $uVid in
	"2c7c" )
		M4='AT+QCFG="band",0,'$L1',0'
		OX=$($ROOTER/gcom/gcom-locked "$COMMPORT" "run-at.gcom" "$CURRMODEM" "$M4")
		log "$OX"
	;;
	"1199" )
		M1='AT!ENTERCND="A710"'
		M4='AT!BAND=11,"Test",0,'$L1',0'
		OX=$($ROOTER/gcom/gcom-locked "$COMMPORT" "run-at.gcom" "$CURRMODEM" "$M1")
		log "$OX"
		OX=$($ROOTER/gcom/gcom-locked "$COMMPORT" "run-at.gcom" "$CURRMODEM" "$M4")
		log "$OX"
		M4='AT!BAND=00;!BAND=11'
		OX=$($ROOTER/gcom/gcom-locked "$COMMPORT" "run-at.gcom" "$CURRMODEM" "$M4")
		log "$OX"
	;;
esac
uci set modem.pinginfo$CURRMODEM.alive=$ACTIVE
uci commit modem

log "Finished Scan"
