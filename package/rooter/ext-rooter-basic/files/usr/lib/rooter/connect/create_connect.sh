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
	local DNS1=$(uci get modem.modeminfo$CURRMODEM.dns1)
	local DNS2=$(uci get modem.modeminfo$CURRMODEM.dns2)
	if [ -z $DNS1 ]; then
		if [ -z $DNS2 ]; then
			return
		else
			uci set network.wan$INTER.peerdns=0
			uci set network.wan$INTER.dns=$DNS2
		fi
	else
		uci set network.wan$INTER.peerdns=0
		if [ -z $DNS2 ]; then
			uci set network.wan$INTER.dns="$DNS1"
		else
			uci set network.wan$INTER.dns="$DNS2 $DNS1"
		fi
	fi
}

check_apn() {
	local IPVAR="IP"
	local COMMPORT="/dev/ttyUSB"$CPORT
	ATCMDD="AT+CGDCONT=?"
	OX=$($ROOTER/gcom/gcom-locked "$COMMPORT" "run-at.gcom" "$CURRMODEM" "$ATCMDD")
	if `echo ${OX} | grep "IPV4V6" 1>/dev/null 2>&1`
	then
		IPVAR="IPV4V6"
	fi
	ATCMDD="AT+CGDCONT?;+CFUN?"
	OX=$($ROOTER/gcom/gcom-locked "$COMMPORT" "run-at.gcom" "$CURRMODEM" "$ATCMDD")
	if `echo ${OX} | grep "+CGDCONT: 1,\"$IPVAR\",\"$NAPN\"," 1>/dev/null 2>&1`
	then
		if `echo ${OX} | grep "+CFUN: 0" 1>/dev/null 2>&1`
		then
			OX=$($ROOTER/gcom/gcom-locked "$COMMPORT" "run-at.gcom" "$CURRMODEM" "AT+CFUN=1")
		fi
	else
		ATCMDD="AT+CGDCONT=1,\"$IPVAR\",\"$NAPN\";+CFUN=0;+CFUN=1"
		OX=$($ROOTER/gcom/gcom-locked "$COMMPORT" "run-at.gcom" "$CURRMODEM" "$ATCMDD")
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
	NAPN=$(uci get modem.modeminfo$CURRMODEM.apn)
	NUSER=$(uci get modem.modeminfo$CURRMODEM.user)
	NPASS=$(uci get modem.modeminfo$CURRMODEM.passw)
	NAUTH=$(uci get modem.modeminfo$CURRMODEM.auth)
	PINC=$(uci get modem.modeminfo$CURRMODEM.pincode)
#
# QMI and MBIM can't handle nil
#
	case $PROT in
	"2"|"3"|"30" )
		if [ -z $NUSER ]; then
			NUSER="NIL"
		fi
		if [ -z $NPASS ]; then
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
			"68c0"|"9040"|"9041"|"9051"|"9054"|"9056" )
				SIERRAID=1
			;;
			"9070"|"907b"|"9071"|"9079"|"901c"|"9091"|"901f" )
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

CURRMODEM=$1
RECON=$2
SIERRAID=0
source /tmp/variable.file

MAN=$(uci get modem.modem$CURRMODEM.manuf)
MOD=$(uci get modem.modem$CURRMODEM.model)
BASEP=$(uci get modem.modem$CURRMODEM.baseport)
PROT=$(uci get modem.modem$CURRMODEM.proto)

if [ ! -z $RECON ]; then
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

	DELAY=$(uci get modem.modem$CURRMODEM.delay)
	if [ -z $DELAY ]; then
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
				CPORT=1
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
		if [ $idV = 03f0 -a $idP = 0857 ]; then
#		if [ $idV = 413c -a $idP = 81d7 ]; then
			DATAFORM="raw-ip"
			uqmi -s -d "$device" --stop-network 0xffffffff --autoconnect > /dev/null & sleep 10 ; kill -9 $!
		else
			if [ $idV = 05c6 -a $idP = f601 ]; then
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
			if [ -z $OX ]; then
				uci set modem.modem$CURRMODEM.commport=""
				uci set modem.modem$CURRMODEM.proto="3"
				log "No MBIM Comm Port"
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
QUE=0
if [ $idV = 2c7c ]; then
	QUE=1
fi
if [ "$idV" = "05c6" -a "$idP" -ne "f601" ]; then
	QUE=1
fi

if [ $QUE -eq 1 ]; then
	ATCMDD="AT"
	OX=$($ROOTER/gcom/gcom-locked "/dev/ttyUSB$CPORT" "run-at.gcom" "$CURRMODEM" "$ATCMDD")
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
	log "Quectel Unsolicited Responses Disabled"
	$ROOTER/luci/celltype.sh $CURRMODEM
fi
if [ $SIERRAID -eq 1 ]; then
	$ROOTER/luci/celltype.sh $CURRMODEM
fi
CHKPORT=$(uci get modem.modem$CURRMODEM.commport)
if [ ! -z $CHKPORT ]; then
	$ROOTER/sms/check_sms.sh $CURRMODEM &
	$ROOTER/common/gettype.sh $CURRMODEM
	$ROOTER/connect/get_profile.sh $CURRMODEM
	get_connect
	
	INTER=$(uci get modem.modeminfo$CURRMODEM.inter)
	if [ -z $INTER ]; then
		INTER=$CURRMODEM
	else
		if [ $INTER = 0 ]; then
			INTER=$CURRMODEM
		fi
	fi
	log "Profile for Modem$CURRMODEM sets interface to WAN$INTER"
	OTHER=1
	if [ $CURRMODEM = 1 ]; then
		OTHER=2
	fi
	EMPTY=$(uci get modem.modem$OTHER.empty)
	if [ $EMPTY = 0 ]; then
		OINTER=$(uci get modem.modem$OTHER.inter)
		if [ ! -z $OINTER ]; then
			if [ $INTER = $OINTER ]; then
				INTER=1
				if [ $OINTER = 1 ]; then
					INTER=2
				fi
				log "Switched Modem$CURRMODEM to WAN$INTER as Modem$OTHER is using WAN$OINTER"
			fi
		fi
	fi
	uci set modem.modem$CURRMODEM.inter=$INTER
	uci commit modem
	log "Modem$CURRMODEM is using WAN$INTER"
	
	uci delete network.wan$INTER
	uci set network.wan$INTER=interface
	uci set network.wan$INTER.proto=dhcp
	uci set network.wan$INTER.ifname=wwan$WWANZ
	uci set network.wan$INTER._orig_bridge=false
	uci set network.wan$INTER.metric=$INTER"0"
	set_dns
	uci commit network	
	
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
	if [ -n $FORCE ]; then
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
	"1"|"2"|"4"|"6"|"7"|"24"|"26"|"27"|"30" )
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
	"1"|"4"|"6"|"7"|"24"|"26"|"27" )
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
	$ROOTER/log/logger "Attempting to Connect Modem #$CURRMODEM ($MAN $MOD)"
	log "Attempting to Connect"

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
			proto_add_dynamic_defaults
			ubus call network add_dynamic "$(json_dump)"
		fi
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

case $PROT in
#
# Sierra, NCM and QMI use modemsignal.sh and reconnect.sh
#
	"1"|"2"|"4"|"6"|"7"|"24"|"26"|"27" )
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

	CLB=$(uci get modem.modeminfo$CURRMODEM.lb)
	if [ -e /etc/config/mwan3 ]; then
		ENB=$(uci get mwan3.wan$INTER.enabled)
		if [ ! -z $ENB ]; then
			if [ $CLB = "1" ]; then
				uci set mwan3.wan$INTER.enabled=1
			else
				uci set mwan3.wan$INTER.enabled=0
			fi
			uci commit mwan3
			/usr/sbin/mwan3 restart
		fi
	fi
