#!/bin/sh

ROOTER=/usr/lib/rooter
ROOTER_LINK="/tmp/links"

log() {
	logger -t "Create Connection" "$@"
}

handle_timeout(){
	local wget_pid="$1"
	local count=0
	TIMEOUT=70
	res=1
	if [ -d /proc/${wget_pid} ]; then
		res=0
	fi
	while [ "$res" = 0 -a $count -lt "$((TIMEOUT))" ]; do
		sleep 1
		count=$((count+1))
		res=1
		if [ -d /proc/${wget_pid} ]; then
			res=0
		fi
	done

	if [ "$res" = 0 ]; then
		log "Killing process on timeout"
		kill "$wget_pid" 2> /dev/null
		res=1
		if [ -d /proc/${wget_pid} ]; then
			res=0
		fi
		if [ "$res" = 0 ]; then
			log "Killing process on timeout"
			kill -9 $wget_pid 2> /dev/null
		fi
	fi
}

set_dns() {
	local pDNS1=$(uci -q get modem.modeminfo$CURRMODEM.dns1)
	local pDNS2=$(uci -q get modem.modeminfo$CURRMODEM.dns2)
	local pDNS3=$(uci -q get modem.modeminfo$CURRMODEM.dns3)
	local pDNS4=$(uci -q get modem.modeminfo$CURRMODEM.dns4)
	local ret=0

	echo "$pDNS1 $pDNS2 $pDNS3 $pDNS4" | grep -o "[[:graph:]]" &>/dev/null
	if [ $? = 0 ]; then
		log "Using DNS settings from the Connection Profile"
		ret=1
	else
		log "Using Provider assigned DNS"
		return 0
	fi

local aDNS="$pDNS1 $pDNS2 $pDNS3 $pDNS4"
local bDNS=""

for DNSV in $(echo "$aDNS"); do
        if [ "$DNSV" != "0.0.0.0" ] && [ -z "$(echo "$bDNS" | grep -o "$DNSV")" ]; then
                [ -n "$(echo "$DNSV" | grep -o ":")" ] && continue
                bDNS="$bDNS $DNSV"
        fi
done

bDNS=$(echo $bDNS)
uci set network.wan$INTER.dns="$bDNS"
uci set network.wan$INTER.peerdns=0
echo "$bDNS" > /tmp/v4dns$INTER

bDNS=""
for DNSV in $(echo "$aDNS"); do
	if [ "$DNSV" != "0:0:0:0:0:0:0:0" ] && [ -z "$(echo "$bDNS" | grep -o "$DNSV")" ]; then
		[ -z "$(echo "$DNSV" | grep -o ":")" ] && continue
		bDNS="$bDNS $DNSV"
	fi
done

echo "$bDNS" > /tmp/v6dns$INTER

    return $ret
}

set_dns2() {
	local pDNS1=$(uci -q get modem.modeminfo$CURRMODEM.dns1)
	local pDNS2=$(uci -q get modem.modeminfo$CURRMODEM.dns2)
	local pDNS3=$(uci -q get modem.modeminfo$CURRMODEM.dns3)
	local pDNS4=$(uci -q get modem.modeminfo$CURRMODEM.dns4)

	local _DNS1 _DNS2 _DNS3 _DNS4 aDNS bDNS
	local ret=0

	echo "$pDNS1 $pDNS2 $pDNS3 $pDNS4" | grep -o "[[:graph:]]" &>/dev/null
	if [ $? = 0 ]; then
		log "Using DNS settings from the Connection Profile"
		ret=1
		_DNS1=$pDNS1
		_DNS2=$pDNS2
		_DNS3=$pDNS3
		_DNS4=$pDNS4
        else
		log "Using Provider assigned DNS"
		_DNS1=$DNS1
		_DNS2=$DNS2
		_DNS3=$DNS3
		_DNS4=$DNS4
	fi

aDNS="$_DNS1 $_DNS2 $_DNS3 $_DNS4"

bDNS=""
for DNSV in $(echo "$aDNS"); do
        if [ "$DNSV" != "0.0.0.0" ] && [ "$DNSV" != "0:0:0:0:0:0:0:0" ] && [ -z "$(echo "$bDNS" | grep -o "$DNSV")" ]; then
                [ -n "$(echo "$DNSV" | grep -o ":")" ] && [ -z "$ip6" ] && continue
                bDNS="$bDNS $DNSV"
        fi
done

bDNS=$(echo $bDNS)
uci set network.wan$INTER.dns="$bDNS"

	return $ret
}


check_apn() {
	local IPVAR="IP"
	local COMMPORT="/dev/ttyUSB"$CPORT
	ATCMDD="AT+CGDCONT=?"
	OX=$($ROOTER/gcom/gcom-locked "$COMMPORT" "run-at.gcom" "$CURRMODEM" "$ATCMDD")
	if [ -n "$(echo $OX | grep -o "IPV4V6")" ]; then
		IPVAR="IPV4V6"
	fi
	ATCMDD="AT+CGDCONT?;+CFUN?"
	OX=$($ROOTER/gcom/gcom-locked "$COMMPORT" "run-at.gcom" "$CURRMODEM" "$ATCMDD")
	if `echo ${OX} | grep "+CGDCONT: 1,\"$IPVAR\",\"$NAPN\"," 1>/dev/null 2>&1`
	then
		if [ -z "$(echo $OX | grep -o "+CFUN: 1")" ]; then
			OX=$($ROOTER/gcom/gcom-locked "$COMMPORT" "run-at.gcom" "$CURRMODEM" "AT+CFUN=1")
		fi
	else
		ATCMDD="AT+CGDCONT=1,\"$IPVAR\",\"$NAPN\";+CFUN=4"
		OX=$($ROOTER/gcom/gcom-locked "$COMMPORT" "run-at.gcom" "$CURRMODEM" "$ATCMDD")
		OX=$($ROOTER/gcom/gcom-locked "$COMMPORT" "run-at.gcom" "$CURRMODEM" "AT+CFUN=1")
		sleep 5
	fi
}

save_variables() {
	echo 'MODSTART="'"$MODSTART"'"' > /tmp/variable.file
	echo 'WWAN="'"$WWAN"'"' >> /tmp/variable.file
	echo 'USBN="'"$USBN"'"' >> /tmp/variable.file
	echo 'ETHN="'"$ETHN"'"' >> /tmp/variable.file
	echo 'WDMN="'"$WDMN"'"' >> /tmp/variable.file
	echo 'BASEPORT="'"$BASEPORT"'"' >> /tmp/variable.file
}

chcklog() {
	OOX=$1
	CLOG=$(uci get modem.modeminfo$CURRMODEM.log)
	if [ $CLOG = "1" ]; then
		log "$OOX"
	fi
}

get_connect() {
	NAPN=$(uci -q get modem.modeminfo$CURRMODEM.apn)
	NUSER=$(uci -q get modem.modeminfo$CURRMODEM.user)
	NPASS=$(uci -q get modem.modeminfo$CURRMODEM.passw)
	NAUTH=$(uci -q get modem.modeminfo$CURRMODEM.auth)
	PINC=$(uci -q get modem.modeminfo$CURRMODEM.pincode)
#
# QMI and MBIM can't handle nil
#
	case $PROT in
	"2"|"3"|"30" )
		if [ -z "$NUSER" ]; then
			NUSER="NIL"
		fi
		if [ -z "$NPASS" ]; then
			NPASS="NIL"
		fi
		;;
	esac

	uci set modem.modem$CURRMODEM.apn=$NAPN
	uci set modem.modem$CURRMODEM.user=$NUSER
	uci set modem.modem$CURRMODEM.passw=$NPASS
	uci set modem.modem$CURRMODEM.auth=$NAUTH
	uci set modem.modem$CURRMODEM.pin=$PINC
	uci commit modem
}

chksierra() {
	idV=$(uci get modem.modem$CURRMODEM.idV)
	idP=$(uci get modem.modem$CURRMODEM.idP)
	SIERRAID=0
	if [ $idV = 1199 ]; then
		case $idP in
			"68aa"|"68a2"|"68a3"|"68a9"|"68b0"|"68b1" )
				SIERRAID=1
			;;
			"68c0"|"9040"|"9041"|"9051"|"9054"|"9056"|"90d3" )
				SIERRAID=1
			;;
			"9070"|"907b"|"9071"|"9079"|"901c"|"9091"|"901f"|"90b1" )
				SIERRAID=1
			;;
		esac
	fi
	if [ $idV = 114f -a $idP = 68a2 ]; then
		SIERRAID=1
	fi
	if [ $idV = 413c -a $idP = 81a8 ]; then
		SIERRAID=1
	fi
	if [ $idV = 413c -a $idP = 81b6 ]; then
		SIERRAID=1
	fi
}

chktelitmbim() {
	idV=$(uci get modem.modem$CURRMODEM.idV)
	idP=$(uci get modem.modem$CURRMODEM.idP)
	TELITMBIM=0
	if [ $idV = 1bc7 -a $idP = 0032 ]; then
		TELITMBIM=1
	fi
}

chkT77() {
	idV=$(uci get modem.modem$CURRMODEM.idV)
	idP=$(uci get modem.modem$CURRMODEM.idP)
	T77=0
	if [ $idV = 413c -a $idP = 81d7 ]; then
		T77=1
	fi
	if [ $idV = 0489 -a $idP = e0b4 ]; then
		T77=1
	fi
	if [ $idV = 0489 -a $idP = e0b5 ]; then
		T77=1
	fi
	if [ $T77 = 1 ]; then
		if [ ! -e /dev/ttyUSB0 ]; then
			T77=0
		fi
	fi
}

chkraw() {
	RAW=0
	if [ $idV = 03f0 -a $idP = 0857 ]; then
		RAW=1
	fi
	if [ $idV = 1bc7 -a $idP = 1900 ]; then
                RAW=1
        fi
	if [ $idV = 19d2 -a $idP = 1432 ]; then
		RAW=1
	fi
	if [ $idV = 05c6 -a $idP = f601 ]; then
		RAW=1
	fi
	if [ $idV = 1e0e -a $idP = 9001 ]; then
		RAW=1
	fi
	if [ $idV = 2c7c -a $idP = 0800 ]; then
		RAW=1
	fi
	if [ $idV = 05c6 -a $idP = 90db ]; then
		RAW=1
	fi
	if [ $idV = 2cb7 -a $idP = 0104 ]; then
		RAW=1
	fi
}

sierrabandmask() {
	ATCMDD='AT!ENTERCND="A710";!BAND?'
	OX=$($ROOTER/gcom/gcom-locked "/dev/ttyUSB$CPORT" "run-at.gcom" "$CURRMODEM" "$ATCMDD")
	echo "$OX" > /tmp/scanx
	while IFS= read -r line
	do
		read -r line
		Unk=$(echo $line | grep "Unknown")
		read -r line
		if [ -z $Unk ]; then
			BND=$(echo $line | cut -d, -f3 | tr " " ",")
			L1=$(echo $BND | cut -d, -f3)
			GW=$(echo $BND | cut -d, -f2) 
		else
			BND=$(echo $line | cut -d, -f3 | tr " " ",")
			L1=$(echo $BND | cut -d, -f2)
			GW=$(echo $BND | cut -d, -f1)
		fi
		L2="0"
		break
	done < /tmp/scanx
	uci set modem.modem$CURRMODEM.GW="$GW"
	uci set modem.modem$CURRMODEM.L1="0x$L1"
	uci set modem.modem$CURRMODEM.L2="$L2"
}

quebandmask() {
	ATCMDD='AT+QCFG="band"'
	OX=$($ROOTER/gcom/gcom-locked "/dev/ttyUSB$CPORT" "run-at.gcom" "$CURRMODEM" "$ATCMDD")
	qm=$(echo $OX" " | grep "+QCFG:" | tr -d '"' | tr " " ",")
	L1=$(echo $qm | cut -d, -f5)
	GW=$(echo $qm | cut -d, -f4)
	L2="0"
	qm=$(echo $OX" " | grep "+QCFG:" | tr -d '"' | tr " " ",")
	uci set modem.modem$CURRMODEM.GW="$GW"
	uci set modem.modem$CURRMODEM.L1="$L1"
	uci set modem.modem$CURRMODEM.L2="$L2"
}

fibomask() {
	ATCMDD='AT+XACT?'
	OX=$($ROOTER/gcom/gcom-locked "/dev/ttyUSB$CPORT" "run-at.gcom" "$CURRMODEM" "$ATCMDD")
	qm=$(echo $OX" " | grep "+XACT:" | tr -d '"' | tr " " ",")
	bd=3
	msk=""
	L1=$(echo $qm | cut -d, -f"$bd")
	while [ $L1 != "OK" ]
	do
		if [ $L1 -ge 100 -a $L1 -lt 200 ]; then
			L1=$((L1-100))
			msk=$msk$L1" "
		fi
		bd=$((bd+1))
		L1=$(echo $qm | cut -d, -f"$bd")
	done
	L1=$(lua $ROOTER/luci/encodemask.lua $msk)
	uci set modem.modem$CURRMODEM.L1="0x$L1"
}

CURRMODEM=$1
RECON=$2
SIERRAID=0
source /tmp/variable.file

MAN=$(uci get modem.modem$CURRMODEM.manuf)
MOD=$(uci get modem.modem$CURRMODEM.model)
BASEP=$(uci get modem.modem$CURRMODEM.baseport)
PROT=$(uci get modem.modem$CURRMODEM.proto)

if [ ! -z "$RECON" ]; then
	$ROOTER/signal/status.sh $CURRMODEM "$MAN $MOD" "ReConnecting"
	uci set modem.modem$CURRMODEM.connected=0
	uci commit modem
	INTER=$(uci get modem.modeminfo$CURRMODEM.inter)
	jkillall getsignal$CURRMODEM
	rm -f $ROOTER_LINK/getsignal$CURRMODEM
	jkillall con_monitor$CURRMODEM
	rm -f $ROOTER_LINK/con_monitor$CURRMODEM
	jkillall mbim_monitor$CURRMODEM
	rm -f $ROOTER_LINK/mbim_monitor$CURRMODEM
	ifdown wan$INTER
	CPORT=$(uci get modem.modem$CURRMODEM.commport)
	WWANX=$(uci get modem.modem$CURRMODEM.wwan)
	WDMNX=$(uci get modem.modem$CURRMODEM.wdm)

	case $PROT in
	"3"|"30" )
		TIMEOUT=10
		#$ROOTER/mbim/mbim_connect.lua stop wwan$WWANX cdc-wdm$WDMNX $CURRMODEM &
		#handle_timeout "$!"
		;;
	* )
		$ROOTER/gcom/gcom-locked "/dev/ttyUSB$CPORT" "reset.gcom" "$CURRMODEM"
		;;
	esac

else

	DELAY=$(uci -q get modem.modem$CURRMODEM.delay)
	if [ -z "$DELAY" ]; then
		DELAY=5
	fi

	uci set modem.modem$CURRMODEM.wdm=$WDMN
	uci set modem.modem$CURRMODEM.wwan=$WWAN
	uci set modem.modem$CURRMODEM.interface=wwan$WWAN
	uci commit modem


#
# QMI, NCM and MBIM use cdc-wdm
#
	case $PROT in
	"2"|"3"|"30"|"4"|"6"|"7" )
		WDMNX=$WDMN
		WDMN=`expr 1 + $WDMN`
		;;
	esac

	WWANX=$WWAN
	WWANZ=$WWAN
	WWAN=`expr 1 + $WWAN`
	save_variables
	rm -f /tmp/usbwait

	case $PROT in
#
# Sierra Direct-IP modem comm port
#
	"1" )
		log "Start Direct-IP Connection"
		while [ ! -e /dev/ttyUSB$BASEP ]; do
			sleep 1
		done
		sleep $DELAY

		OX=$(grep . /sys/class/tty/ttyUSB*/../../../bInterfaceNumber | grep ":03" | cut -d'/' -f5)
		if [ $BASEP -eq 0 ]; then
        		CPORT=$(echo $OX | cut -d' ' -f1)
		else
       			CPORT=$(echo $OX | cut -d' ' -f2)
		fi
		CPORT=$(echo $CPORT | grep -o "[[:digit:]]\+")
		CPORT=`expr $CPORT - $BASEP`

		idV=$(uci get modem.modem$CURRMODEM.idV)
		idP=$(uci get modem.modem$CURRMODEM.idP)
		lua $ROOTER/common/modemchk.lua "$idV" "$idP" "$CPORT" "$CPORT"
		source /tmp/parmpass
		CPORT=`expr $CPORT + $BASEP`

		log "Sierra Comm Port : /dev/ttyUSB$CPORT"
		;;
#
# QMI modem comm port
#
	"2" )
		log "Start QMI Connection"
		while [ ! -e /dev/cdc-wdm$WDMNX ]; do
			sleep 1
		done
		sleep $DELAY

		chksierra
		if [ $SIERRAID -eq 1 ]; then
			OX=$(grep . /sys/class/tty/ttyUSB*/../../../bInterfaceNumber | grep ":03" | cut -d'/' -f5)
			if [ $BASEP -eq 0 ]; then
        			CPORT=$(echo $OX | cut -d' ' -f1)
			else
       				CPORT=$(echo $OX | cut -d' ' -f2)
			fi
			CPORT=$(echo $CPORT | grep -o "[[:digit:]]\+")
			CPORT=`expr $CPORT - $BASEP`
		else
			if [ $idV = 1bc7 ]; then
				CPORT=2
			else
				if [ $idV = 2c7c -a $idP = 0620 ]; then
					CPORT=2
				else
					CPORT=1
				fi
			fi
		fi
		lua $ROOTER/common/modemchk.lua "$idV" "$idP" "$CPORT" "$CPORT"
		source /tmp/parmpass

		CPORT=`expr $CPORT + $BASEP`

		log "QMI Comm Port : /dev/ttyUSB$CPORT"
		device=/dev/cdc-wdm$WDMNX
		devname="$(basename "$device")"
		devpath="$(readlink -f /sys/class/usbmisc/$devname/device/)"
		ifname="$( ls "$devpath"/net )"
		idV=$(uci get modem.modem$CURRMODEM.idV)
		idP=$(uci get modem.modem$CURRMODEM.idP)
		chkraw
		if [ $RAW -eq 1 ]; then
			DATAFORM="raw-ip"
			uqmi -s -d "$device" --stop-network 0xffffffff --autoconnect > /dev/null & sleep 10 ; kill -9 $!
		else
			if [ $idV = 1199 -a $idP = 9055 ]; then
				$ROOTER/gcom/gcom-locked "/dev/ttyUSB$CPORT" "reset.gcom" "$CURRMODEM"
				DATAFORM="802.3"
				uqmi -s -d "$device" --stop-network 0xffffffff --autoconnect > /dev/null & sleep 10 ; kill -9 $!
				uqmi -s -d "$device" --set-data-format 802.3
				uqmi -s -d "$device" --wda-set-data-format 802.3
			else
				DATAFORM=$(uqmi -s -d "$device" --wda-get-data-format)
			fi
		fi
		log "WDA-GET-DATA-FORMAT is $DATAFORM"
		if [ "$DATAFORM" = '"raw-ip"' ]; then
			if [ -f /sys/class/net/$ifname/qmi/raw_ip ]; then
				echo "Y" > /sys/class/net/$ifname/qmi/raw_ip
			fi
		fi
		;;
	"3"|"30" )
		log "Start MBIM Connection"
		while [ ! -e /dev/cdc-wdm$WDMNX ]; do
			sleep 1
		done
		sleep $DELAY

		chksierra
		if [ $SIERRAID -eq 1 ]; then
			OX=$(grep . /sys/class/tty/ttyUSB*/../../../bInterfaceNumber | grep ":03" | cut -d'/' -f5)
			if [ -z "$OX" ]; then
				idV=$(uci get modem.modem$CURRMODEM.idV)
				idP=$(uci get modem.modem$CURRMODEM.idP)
				if [ $idP = "90d3" ]; then
					CPORT=0
					CPORT=`expr $CPORT - $BASEP`
					lua $ROOTER/common/modemchk.lua "$idV" "$idP" "$CPORT" "$CPORT"
					source /tmp/parmpass
					CPORT=`expr $CPORT + $BASEP`
					uci set modem.modem$CURRMODEM.commport=$CPORT
					if [ -n "$CPORT" ]; then
						uci set modem.modem$CURRMODEM.proto="30"
					fi
					log "MBIM Comm Port : /dev/ttyUSB$CPORT"
				else
					uci set modem.modem$CURRMODEM.commport=""
					uci set modem.modem$CURRMODEM.proto="3"
					log "No MBIM Comm Port"
				fi
			else
				OX=$(grep . /sys/class/tty/ttyUSB*/../../../bInterfaceNumber | grep ":03" | cut -d'/' -f5)
				if [ $BASEP -eq 0 ]; then
					CPORT=$(echo $OX | cut -d' ' -f1)
				else
						CPORT=$(echo $OX | cut -d' ' -f2)
				fi
				CPORT=$(echo $CPORT | grep -o "[[:digit:]]\+")
				CPORT=`expr $CPORT - $BASEP`
				idV=$(uci get modem.modem$CURRMODEM.idV)
				idP=$(uci get modem.modem$CURRMODEM.idP)
				lua $ROOTER/common/modemchk.lua "$idV" "$idP" "$CPORT" "$CPORT"
				source /tmp/parmpass
				CPORT=`expr $CPORT + $BASEP`
				uci set modem.modem$CURRMODEM.commport=$CPORT
				if [ -n "$CPORT" ]; then
					uci set modem.modem$CURRMODEM.proto="30"
				fi
				log "MBIM Comm Port : /dev/ttyUSB$CPORT"
			fi
		else
			chktelitmbim
			if [ $TELITMBIM -eq 1 ]; then
				OX=$(grep . /sys/class/tty/ttyACM*/../../bInterfaceNumber | grep ":00" | cut -d'/' -f5)
				ACMPORT=$(echo $OX | grep -o "[[:digit:]]\+")
				CPORT=9$ACMPORT
				ln -s /dev/ttyACM$ACMPORT /dev/ttyUSB$CPORT
				idV=$(uci get modem.modem$CURRMODEM.idV)
				idP=$(uci get modem.modem$CURRMODEM.idP)
				lua $ROOTER/common/modemchk.lua "$idV" "$idP" "$CPORT" "$CPORT"
				source /tmp/parmpass
				uci set modem.modem$CURRMODEM.commport=$CPORT
				if [ -n "$CPORT" ]; then
					uci set modem.modem$CURRMODEM.proto="30"
				fi
				log "MBIM Comm Port : /dev/ttyUSB$CPORT"
			else
				chkT77
				if [ $T77 -eq 1 ]; then
					lua $ROOTER/common/modemchk.lua "$idV" "$idP" "0" "0"
					source /tmp/parmpass
					CPORT=`expr $CPORT + $BASEP`
					uci set modem.modem$CURRMODEM.commport=$CPORT
					uci set modem.modem$CURRMODEM.proto="30"
					log "MBIM Comm Port : /dev/ttyUSB$CPORT"
				else
					case $idV in
						"2c7c"|"05c6" )
							lua $ROOTER/common/modemchk.lua "$idV" "$idP" "3" "2"
							source /tmp/parmpass
							CPORT=`expr $CPORT + $BASEP`
							uci set modem.modem$CURRMODEM.commport=$CPORT
							uci set modem.modem$CURRMODEM.proto="30"
							log "MBIM Comm Port : /dev/ttyUSB$CPORT"
						;;
						"1bc7" )
							lua $ROOTER/common/modemchk.lua "$idV" "$idP" "2" "2"
							source /tmp/parmpass
							CPORT=`expr $CPORT + $BASEP`
							uci set modem.modem$CURRMODEM.commport=$CPORT
							uci set modem.modem$CURRMODEM.proto="30"
							log "MBIM Comm Port : /dev/ttyUSB$CPORT"
						;;
						"03f0" )
							if [ $idP = 0a57 ]; then
								lua $ROOTER/common/modemchk.lua "$idV" "$idP" "2" "2"
								source /tmp/parmpass
								CPORT=`expr $CPORT + $BASEP`
								uci set modem.modem$CURRMODEM.commport=$CPORT
								uci set modem.modem$CURRMODEM.proto="30"
								log "MBIM Comm Port : /dev/ttyUSB$CPORT"
							fi
						;;
						"2cb7" )
							lua $ROOTER/common/modemchk.lua "$idV" "$idP" "0" "0"
							source /tmp/parmpass
							ACMPORT=`expr $CPORT + $BASEP`
							CPORT="8$ACMPORT"
							ln -fs /dev/ttyACM$ACMPORT /dev/ttyUSB$CPORT
							uci set modem.modem$CURRMODEM.commport=$CPORT
							uci set modem.modem$CURRMODEM.proto="30"
							log "Fibocom MBIM Comm Port : /dev/ttyUSB$CPORT"
							fibomask
						;;
						* )
							uci set modem.modem$CURRMODEM.commport=""
							log "No MBIM Comm Port"
						;;
					esac
				fi
			fi
		fi
		uci commit modem
		;;
#
# Huawei NCM
#
	"4"|"6"|"7"|"24"|"26"|"27" )
		log "Start NCM Connection"
		case $PROT in
		"4"|"6"|"7" )
			while [ ! -e /dev/cdc-wdm$WDMNX ]; do
				sleep 1
			done
			;;
		"24"|"26"|"27" )
			while [ ! -e /dev/ttyUSB$BASEP ]; do
				sleep 1
			done
			;;
		esac
		sleep $DELAY

		idV=$(uci get modem.modem$CURRMODEM.idV)
		idP=$(uci get modem.modem$CURRMODEM.idP)
		cat /sys/kernel/debug/usb/devices > /tmp/wdrv
		$ROOTER/ncmfind.lua $idV $idP
		retval=$?
		rm -f /tmp/wdrv
		lua $ROOTER/common/modemchk.lua "$idV" "$idP" "$retval" "$retval"
		source /tmp/parmpass

		CPORT=`expr $CPORT + $BASEP`

		log "NCM Comm Port : /dev/ttyUSB$CPORT"
		;;
	"28" )
		log "Start Fibocom NCM Connection"
		idV=$(uci get modem.modem$CURRMODEM.idV)
		idP=$(uci get modem.modem$CURRMODEM.idP)
		lua $ROOTER/common/modemchk.lua "$idV" "$idP" "0" "0"
		source /tmp/parmpass
		ACMPORT=`expr $CPORT + $BASEP`
		CPORT="8$ACMPORT"
		ln -fs /dev/ttyACM$ACMPORT /dev/ttyUSB$CPORT
		log "Fibocom NCM Comm Port : /dev/ttyUSB$CPORT"
		fibomask
		;;
	esac

	uci set modem.modem$CURRMODEM.commport=$CPORT
	uci commit modem

fi
if [ $PROT = "3" ]; then
# May have got changed to 30 above
	PROT=$(uci get modem.modem$CURRMODEM.proto)
fi
if [ -z "$idV" ]; then
	idV=$(uci get modem.modem$CURRMODEM.idV)
fi
QUECTEL=false
if [ "$idV" = "2c7c" ]; then
	QUECTEL=true
elif [ "$idV" = "05c6" ]; then
	QUELST="9090,9003,9215"
	if [[ $(echo "$QUELST" | grep -o "$idP") ]]; then
		QUECTEL=true
	fi
fi
if $QUECTEL; then
	ATCMDD="AT+CNMI?"
	OX=$($ROOTER/gcom/gcom-locked "/dev/ttyUSB$CPORT" "run-at.gcom" "$CURRMODEM" "$ATCMDD")
	if `echo $OX | grep -o "+CNMI: [0-3],2," >/dev/null 2>&1`; then
		ATCMDD="AT+CNMI=0,0,0,0,0"
		OX=$($ROOTER/gcom/gcom-locked "/dev/ttyUSB$CPORT" "run-at.gcom" "$CURRMODEM" "$ATCMDD")
	fi
	ATCMDD="AT+QINDCFG=\"smsincoming\""
	OX=$($ROOTER/gcom/gcom-locked "/dev/ttyUSB$CPORT" "run-at.gcom" "$CURRMODEM" "$ATCMDD")
	if `echo $OX | grep -o ",1" >/dev/null 2>&1`; then
		ATCMDD="AT+QINDCFG=\"smsincoming\",0,1"
		OX=$($ROOTER/gcom/gcom-locked "/dev/ttyUSB$CPORT" "run-at.gcom" "$CURRMODEM" "$ATCMDD")
	fi
	ATCMDD="AT+QINDCFG=\"all\""
	OX=$($ROOTER/gcom/gcom-locked "/dev/ttyUSB$CPORT" "run-at.gcom" "$CURRMODEM" "$ATCMDD")
	if `echo $OX | grep -o ",1" >/dev/null 2>&1`; then
		ATCMDD="AT+QINDCFG=\"all\",0,1"
		OX=$($ROOTER/gcom/gcom-locked "/dev/ttyUSB$CPORT" "run-at.gcom" "$CURRMODEM" "$ATCMDD")
	fi
	log "Quectel Unsolicited Responses Disabled"
#	ATCMDD="AT+QCFG=\"nwscanmode\",3"
#	OX=$($ROOTER/gcom/gcom-locked "/dev/ttyUSB$CPORT" "run-at.gcom" "$CURRMODEM" "$ATCMDD")
	quebandmask
	$ROOTER/luci/celltype.sh $CURRMODEM
fi
if [ $SIERRAID -eq 1 ]; then
#	ATCMDD="AT!SELRAT=6"
#	OX=$($ROOTER/gcom/gcom-locked "/dev/ttyUSB$CPORT" "run-at.gcom" "$CURRMODEM" "$ATCMDD")
	sierrabandmask
	$ROOTER/luci/celltype.sh $CURRMODEM
fi
CHKPORT=$(uci -q get modem.modem$CURRMODEM.commport)
if [ -n "$CHKPORT" ]; then
	$ROOTER/common/gettype.sh $CURRMODEM
	$ROOTER/connect/get_profile.sh $CURRMODEM
	INTER=$(uci get modem.modeminfo$CURRMODEM.inter)
	[ $INTER = 3 ] && log "Modem Modem $CURRMODEM disabled in Connection Profile" && exit 1
	$ROOTER/sms/check_sms.sh $CURRMODEM &
	get_connect
	if [ -z "$INTER" ]; then
		INTER=$CURRMODEM
	else
		if [ $INTER = 0 ]; then
			INTER=$CURRMODEM
		fi
	fi
	log "Profile for Modem $CURRMODEM sets interface to WAN$INTER"
	OTHER=1
	if [ $CURRMODEM = 1 ]; then
		OTHER=2
	fi
	EMPTY=$(uci get modem.modem$OTHER.empty)
	if [ $EMPTY = 0 ]; then
		OINTER=$(uci get modem.modem$OTHER.inter)
		if [ ! -z "$OINTER" ]; then
			if [ $INTER = $OINTER ]; then
				INTER=1
				if [ $OINTER = 1 ]; then
					INTER=2
				fi
				log "Switched Modem $CURRMODEM to WAN$INTER as Modem $OTHER is using WAN$OINTER"
			fi
		fi
	fi
	uci set modem.modem$CURRMODEM.inter=$INTER
	uci commit modem
	log "Modem $CURRMODEM is using WAN$INTER"

	if [ ! $PROT = "28" ]; then
		uci delete network.wan$INTER
		uci set network.wan$INTER=interface
		uci set network.wan$INTER.proto=dhcp
		uci set network.wan$INTER.ifname=wwan$WWANZ
		uci set network.wan$INTER._orig_bridge=false
		uci set network.wan$INTER.metric=$INTER"0"
		set_dns
		pdns=$?
		uci commit network
	fi

	export SETAPN=$NAPN
	export SETUSER=$NUSER
	export SETPASS=$NPASS
	export SETAUTH=$NAUTH
	export PINCODE=$PINC
	idV=$(uci get modem.modem$CURRMODEM.idV)
	if [ $idV = 12d1 ]; then
		OX=$($ROOTER/gcom/gcom-locked "/dev/ttyUSB$CPORT" "curc.gcom" "$CURRMODEM")
		log "Huawei Unsolicited Responses Disabled"
		ATCMDD="AT^USSDMODE=0"
		OX=$($ROOTER/gcom/gcom-locked "/dev/ttyUSB$CPORT" "run-at.gcom" "$CURRMODEM" "$ATCMDD")
	fi
	FORCE=$(uci get modem.modeminfo$CURRMODEM.ppp)
	if [ -n "$FORCE" ]; then
		if [ $FORCE = 1 ]; then
			log "Forcing PPP mode"
			case $idV in
			"12d1" )
				retval=10
				;;
			* )
				retval=11
				;;
			esac
			uci set modem.modem$CURRMODEM.proto=$retval
			rm -f $ROOTER_LINK/create_proto$CURRMODEM
			log "Forced Protcol Value : $retval"
			log "Connecting a PPP Modem"
			ln -s $ROOTER/ppp/create_ppp.sh $ROOTER_LINK/create_proto$CURRMODEM
			$ROOTER_LINK/create_proto$CURRMODEM $CURRMODEM &
			exit 0
		fi
	fi
fi

if $QUECTEL; then
	ATCMDD="AT+QINDCFG=\"all\",1"
	OX=$($ROOTER/gcom/gcom-locked "/dev/ttyUSB$CPORT" "run-at.gcom" "$CURRMODEM" "$ATCMDD")
fi

while [ 1 -lt 6 ]; do

	case $PROT in
	"1" )
		OX=$($ROOTER/gcom/gcom-locked "/dev/ttyUSB$CPORT" "auto.gcom" "$CURRMODEM")
		chcklog "$OX"
		M7=$(echo "$OX" | sed -e "s/SCPROF:/SCPROF: /;s!  ! !g")
		AU=$(echo "$M7" | awk -F[,\ ] '/^\!SCPROF:/ {print $4}')
		if [ $AU = "1" ]; then
			AUTO="1"
			log "Autoconnect is Enabled"
		else
			AUTO="0"
			log "Autoconnect is not Enabled"
		fi
		;;
	esac
	uci set modem.modem$CURRMODEM.auto=$AUTO
	uci commit modem

	case $PROT in
#
# Check provider Lock
#
	"1"|"2"|"4"|"6"|"7"|"24"|"26"|"27"|"30"|"28" )
		$ROOTER/common/lockchk.sh $CURRMODEM
		;;
	* )
		log "No Provider Lock Done"
		;;
	esac

	case $PROT in
#
# Sierra and NCM uses separate Pincode setting
#
	"1"|"4"|"6"|"7"|"24"|"26"|"27"|"28" )
		if [ -n "$PINCODE" ]; then
			OX=$($ROOTER/gcom/gcom-locked "/dev/ttyUSB$CPORT" "setpin.gcom" "$CURRMODEM")
			chcklog "$OX"
			ERROR="ERROR"
			if `echo ${OX} | grep "${ERROR}" 1>/dev/null 2>&1`
			then
				log "Modem $CURRMODEM Failed to Unlock SIM Pin"
				$ROOTER/signal/status.sh $CURRMODEM "$MAN $MOD" "Failed to Connect : Pin Locked"
				exit 0
			fi
		fi
		;;
	* )
		log "Pincode in script"
		;;
	esac
	$ROOTER/log/logger "Attempting to Connect Modem #$CURRMODEM"
	log "Attempting to Connect Modem $CURRMODEM"

	if [ -e $ROOTER/modem-led.sh ]; then
		$ROOTER/modem-led.sh $CURRMODEM 2
	fi
	
	BRK=0
	case $PROT in
#
# Sierra connect script
#
	"1" )
		if [ $AUTO = "0" ]; then
			OX=$($ROOTER/gcom/gcom-locked "/dev/ttyUSB$CPORT" "connect-directip.gcom" "$CURRMODEM")
			chcklog "$OX"
			ERROR="ERROR"
			if `echo ${OX} | grep "${ERROR}" 1>/dev/null 2>&1`
			then
				BRK=1
				$ROOTER/signal/status.sh $CURRMODEM "$MAN $MOD" "Failed to Connect : Retrying"
			fi
			M7=$(echo "$OX" | sed -e "s/SCACT:/SCACT: /;s!  ! !g")
			SCACT="!SCACT: 1,1"
			if `echo ${M7} | grep "${SCACT}" 1>/dev/null 2>&1`
			then
				BRK=0
				ifup wan$INTER
				sleep 20
			else
				BRK=1
				$ROOTER/signal/status.sh $CURRMODEM "$MAN $MOD" "Failed to Connect : Retrying"
			fi
		else
			ifup wan$INTER
			sleep 20
		fi
		;;
#
# QMI connect script
#
	"2" )
		check_apn
		$ROOTER/qmi/connectqmi.sh $CURRMODEM cdc-wdm$WDMNX $NAUTH $NAPN $NUSER $NPASS $PINCODE
		if [ -f /tmp/qmigood ]; then
			rm -f /tmp/qmigood
			ifup wan$INTER
			sleep 20
		else
			BRK=1
			$ROOTER/signal/status.sh $CURRMODEM "$MAN $MOD" "Failed to Connect : Retrying"
		fi
		;;
#
# NCM connect script
#
	"4"|"6"|"7"|"24"|"26"|"27" )
		OX=$($ROOTER/gcom/gcom-locked "/dev/ttyUSB$CPORT" "run-at.gcom" "$CURRMODEM" "ati")
		E5372=$(echo ${OX} | grep "E5372")
		R215=$(echo ${OX} | grep "R215")
		E5787=$(echo ${OX} | grep "E5787")
		check_apn
		if [ -n "$E5372" -o -n "$R215" -o -n "$E5787" ]; then
			ifup wan$INTER
			BRK=0
		else
			OX=$($ROOTER/gcom/gcom-locked "/dev/cdc-wdm$WDMNX" "connect-ncm.gcom" "$CURRMODEM")
			chcklog "$OX"
			ERROR="ERROR"
			if `echo ${OX} | grep "${ERROR}" 1>/dev/null 2>&1`
			then
				OX=$($ROOTER/gcom/gcom-locked "/dev/ttyUSB$CPORT" "connect-ncm.gcom" "$CURRMODEM")
				chcklog "$OX"
			fi
			ERROR="ERROR"
			if `echo ${OX} | grep "${ERROR}" 1>/dev/null 2>&1`
			then
				BRK=1
				$ROOTER/signal/status.sh $CURRMODEM "$MAN $MOD" "Failed to Connect : Retrying"
			else
				ifup wan$INTER
				sleep 25
				OX=$($ROOTER/gcom/gcom-locked "/dev/ttyUSB$CPORT" "cgpaddr.gcom" "$CURRMODEM")
				chcklog "$OX"
				OX=$($ROOTER/common/processat.sh "$OX")
				STATUS=$(echo "$OX" | awk -F[,\ ] '/^\^SYSINFOEX:/ {print $2}' | sed 's/"//g')
				DOMAIN=$(echo "$OX" | awk -F[,\ ] '/^\^SYSINFOEX:/ {print $3}' | sed 's/"//g')
				if [ "x$STATUS" = "x" ]; then
					STATUS=$(echo "$OX" | awk -F[,\ ] '/^\^SYSINFO:/ {print $2}')
					DOMAIN=$(echo "$OX" | awk -F[,\ ] '/^\^SYSINFO:/ {print $3}')
				fi
				CGPADDR="+CGPADDR:"
				if `echo ${OX} | grep "${CGPADDR}" 1>/dev/null 2>&1`
				then
					if [ $STATUS = "2" ]; then
						if [ $DOMAIN = "1" ]; then
							BRK=0
						else
							if [ $DOMAIN = "2" ]; then
								BRK=0
							else
								if [ $DOMAIN = "3" ]; then
									BRK=0
								else
									BRK=1
									$ROOTER/signal/status.sh $CURRMODEM "$MAN $MOD" "Network Error : Retrying"
								fi
							fi
						fi
					else
						BRK=1
						$ROOTER/signal/status.sh $CURRMODEM "$MAN $MOD" "Network Error : Retrying"
					fi
				else
					BRK=1
					$ROOTER/signal/status.sh $CURRMODEM "$MAN $MOD" "No IP Address : Retrying"
				fi
			fi
		fi
		if [ $BRK = 0 ]; then
			. /lib/functions.sh
			. /lib/netifd/netifd-proto.sh
			interface="wan"$INTER
			log "IPv6 interface"
			json_init
			json_add_string name "${interface}_6"
			json_add_string ifname "@$interface"
			json_add_string proto "dhcpv6"
			json_add_string extendprefix 1
			if [ "$pdns" = 1 ]; then
				aDNS=$(cat /tmp/v6dns$INTER 2>/dev/null)
				json_add_boolean peerdns 0
				json_add_array dns
				for DNSV in $(echo "$aDNS"); do
					json_add_string "" "$DNSV"
				done
				json_close_array
			fi
			proto_add_dynamic_defaults
			ubus call network add_dynamic "$(json_dump)"
		fi
		;;
#
# Fibocom NCM connect
#
	"28" )
		. /lib/functions.sh
		. /lib/netifd/netifd-proto.sh
		COMMPORT="/dev/ttyUSB"$CPORT
		ATCMDD="AT+CGACT=0,1"
		OX=$($ROOTER/gcom/gcom-locked "$COMMPORT" "run-at.gcom" "$CURRMODEM" "$ATCMDD")
		check_apn
		ATCMDD="AT+CGPIAF=1,0,0,0;+XDNS=1,1;+XDNS=1,2"
		OX=$($ROOTER/gcom/gcom-locked "$COMMPORT" "run-at.gcom" "$CURRMODEM" "$ATCMDD")
		ATCMDD="AT+CGACT=1,1"
		OX=$($ROOTER/gcom/gcom-locked "$COMMPORT" "run-at.gcom" "$CURRMODEM" "$ATCMDD")

		ATCMDD="AT+CGCONTRDP=1"
		OX=$($ROOTER/gcom/gcom-locked "$COMMPORT" "run-at.gcom" "$CURRMODEM" "$ATCMDD")
		OX=$(echo "${OX//[\" ]/}")
		ip=$(echo $OX | cut -d, -f4 | grep -o "[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}")
		ip=$(echo $ip | cut -d' ' -f1)
		DNS1=$(echo $OX | cut -d, -f6)
		DNS2=$(echo $OX | cut -d, -f7)
		OX6=$(echo $OX | grep -o "+CGCONTRDP:1,[0-9]\+,[^,]\+,[0-9A-F]\{1,4\}:[0-9A-F]\{1,4\}.\+")
		ip6=$(echo $OX6 | grep -o "[0-9A-F]\{1,4\}:[0-9A-F]\{1,4\}:[0-9A-F]\{1,4\}:[0-9A-F]\{1,4\}:[0-9A-F]\{1,4\}:[0-9A-F]\{1,4\}:[0-9A-F]\{1,4\}:[0-9A-F]\{1,4\}")
		ip6=$(echo $ip6 | cut -d' ' -f1)
		DNS3=$(echo "$OX6" | cut -d, -f6)
		DNS4=$(echo "$OX6" | cut -d, -f7)

			if [[ $(echo "$ip6" | grep -o "^[23]") ]]; then
				# Global unicast IP acquired
				v6cap=1
			elif
				[[ $(echo "$ip6" | grep -o "^[0-9a-fA-F]\{1,4\}:") ]]; then
					# non-routable address
					v6cap=2
			else
				v6cap=0
			fi

		ATCMDD="AT+XDATACHANNEL=1,1,\"/USBCDC/0\",\"/USBHS/NCM/0\",2,1"
		OX=$($ROOTER/gcom/gcom-locked "$COMMPORT" "run-at.gcom" "$CURRMODEM" "$ATCMDD")
		RDNS=$(uci -q get network.wan$INTER.dns)
		uci delete network.wan$INTER
		uci set network.wan$INTER=interface
		uci set network.wan$INTER.proto=static
		uci set network.wan$INTER.ifname=usb0
		uci set network.wan$INTER.metric=$INTER"0"
		uci set network.wan$INTER.ipaddr=$ip/32
		uci set network.wan$INTER.gateway='0.0.0.0'
		[ "$v6cap" -gt 0 ] && uci set network.wan$INTER.ip6addr=$ip6

		log "IP address(es): $ip $ip6"
		log "DNS servers 1&2: $DNS1 $DNS2"
		log "DNS servers 3&4: $DNS3 $DNS4"

		if [ -n "$RDNS" ]; then
                        uci set network.wan$INTER.dns="$RDNS"
                else
			set_dns2
			pdns=$?
		fi

		uci commit network
		uci set modem.modem$CURRMODEM.interface=usb0
		uci commit modem
		ip link set dev usb0 arp off
		OX=$($ROOTER/gcom/gcom-locked "$COMMPORT" "raw-ip.gcom" "$CURRMODEM")
		RESP=$(echo $OX | sed "s/AT+CGDATA=\"M-RAW_IP\",1 //")
		log "Final Modem $CURRMODEM result code is $RESP"
		[ ! "$RESP" = "OK CONNECT" ] && log "Failed to Connect, exiting" && exit 1
		ifup wan$INTER

                if [ -e /sys/class/net/usb0/cdc_ncm/tx_timer_usecs ]; then
                        echo "0" >  /sys/class/net/usb0/cdc_ncm/tx_timer_usecs
                fi

		if [ $v6cap = 2 ]; then
			interface="wan"$INTER
			log "adding IPv6 dynamic interface"
			json_init
			json_add_string name "${interface}_6"
			json_add_string ifname "@$interface"
			json_add_string proto "dhcpv6"
			json_add_string extendprefix 1
			[ "$pdns" = 1 ] && json_add_boolean peerdns 0
			proto_add_dynamic_defaults
			ubus call network add_dynamic "$(json_dump)"
		fi
		sleep 2
		BRK=0
		;;
#
# MBIM connect script
#
	"3"|"30" )
		if [ -n "$CPORT" ]; then
			check_apn
		fi
		log "Using Netifd Method"
		uci delete network.wan$INTER
		uci set network.wan$INTER=interface
		uci set network.wan$INTER.proto=mbim
		uci set network.wan$INTER.device=/dev/cdc-wdm$WDMNX
		uci set network.wan$INTER.metric=$INTER"0"
		uci set network.wan$INTER.currmodem=$CURRMODEM
		uci -q commit network
		rm -f /tmp/usbwait
		ifup wan$INTER
		MIFACE=$(uci get modem.modem$CURRMODEM.interface)
		if [ -e /sys/class/net/$MIFACE/cdc_ncm/tx_timer_usecs ]; then
			echo "0" >  /sys/class/net/$MIFACE/cdc_ncm/tx_timer_usecs
		fi
		exit 0
		;;
	esac

	if [ $BRK = 1 ]; then
		$ROOTER/log/logger "Retry Connection with Modem #$CURRMODEM"
		log "Retry Connection"
		sleep 10
	else
		$ROOTER/log/logger "Modem #$CURRMODEM Connected"
		log "Connected"
		break
	fi
done

if [ -e $ROOTER/modem-led.sh ]; then
	$ROOTER/modem-led.sh $CURRMODEM 3
fi

case $PROT in
#
# Sierra, NCM and QMI use modemsignal.sh and reconnect.sh
#
	"1"|"2"|"4"|"6"|"7"|"24"|"26"|"27"|"28" )
		ln -s $ROOTER/signal/modemsignal.sh $ROOTER_LINK/getsignal$CURRMODEM
		ln -s $ROOTER/connect/reconnect.sh $ROOTER_LINK/reconnect$CURRMODEM
		# send custom AT startup command
		if [ $(uci get modem.modeminfo$CURRMODEM.at) -eq "1" ]; then
			ATCMDD=$(uci get modem.modeminfo$CURRMODEM.atc)
			if [ ! -z "${ATCMDD}" ]; then
				OX=$($ROOTER/gcom/gcom-locked "/dev/ttyUSB$CPORT" "run-at.gcom" "$CURRMODEM" "$ATCMDD")
				OX=$($ROOTER/common/processat.sh "$OX")
				ERROR="ERROR"
				if `echo ${OX} | grep "${ERROR}" 1>/dev/null 2>&1`
				then
					log "Error sending custom AT command: $ATCMDD with result: $OX"
				else
					log "Sent custom AT command: $ATCMDD with result: $OX"
				fi
			fi
		fi
		;;
esac

	$ROOTER_LINK/getsignal$CURRMODEM $CURRMODEM $PROT &
	ln -s $ROOTER/connect/conmon.sh $ROOTER_LINK/con_monitor$CURRMODEM
	$ROOTER_LINK/con_monitor$CURRMODEM $CURRMODEM &
	uci set modem.modem$CURRMODEM.connected=1
	uci commit modem
	
	if [ -e $ROOTER/timezone.sh ]; then
		TZ=$(uci -q get modem.modeminfo$CURRMODEM.tzone)
		if [ "$TZ" = "1" ]; then
			log "Set TimeZone"
			$ROOTER/timezone.sh &
		fi
	fi

	CLB=$(uci get modem.modeminfo$CURRMODEM.lb)
	if [ -e /etc/config/mwan3 ]; then
		ENB=$(uci get mwan3.wan$INTER.enabled)
		if [ ! -z "$ENB" ]; then
			if [ $CLB = "1" ]; then
				uci set mwan3.wan$INTER.enabled=1
			else
				uci set mwan3.wan$INTER.enabled=0
			fi
			uci commit mwan3
			/usr/sbin/mwan3 restart
		fi
	fi
