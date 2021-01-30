#!/bin/sh

ROOTER=/usr/lib/rooter

log() {
	logger -t "QMI Connect" "$@"
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

	. /lib/functions.sh
	. /lib/netifd/netifd-proto.sh

CURRMODEM=$1
device=/dev/$2
auth=$3
NAPN=$4
username=$5
password=$6
pincode=$7

INTER=$(uci -q get modem.modem$CURRMODEM.inter)
interface="wan"$INTER

case $auth in
	"0" )
		auth="none"
	;;
	"1" )
		auth="pap"
	;;
	"2" )
		auth="chap"
	;;
	*)
		auth="none"
	;;
esac
if [ $username = NIL ]; then
	username=
fi
if [ $password = NIL ]; then
	password=
fi

devname="$(basename "$device")"
devpath="$(readlink -f /sys/class/usbmisc/$devname/device/)"
ifname="$( ls "$devpath"/net )"

#while uqmi -s -d "$device" --get-pin-status | grep '"UIM uninitialized"' > /dev/null; do
#		sleep 1;
#done

[ -n "$pincode" ] && {
	uqmi -s -d "$device" --verify-pin1 "$pincode" || {
		log "Unable to verify PIN"
		exit 1
	}
}

uqmi -s -d "$device" --stop-network 0xffffffff --autoconnect > /dev/null & sleep 10 ; kill -9 $!

#uqmi -s -d "$device" --set-data-format 802.3
#uqmi -s -d "$device" --wda-set-data-format 802.3
idV=$(uci get modem.modem$CURRMODEM.idV)
idP=$(uci get modem.modem$CURRMODEM.idP)
chkraw
if [ $RAW -eq 1 ]; then
	DATAFORM='"raw-ip"'
	echo "Y" > /sys/class/net/$ifname/qmi/raw_ip
else
	DATAFORM=$(uqmi -s -d "$device" --wda-get-data-format)
fi
log "WDA-GET-DATA-FORMAT is $DATAFORM"
if [ "$DATAFORM" = '"raw-ip"' ]; then
	[ -f /sys/class/net/$ifname/qmi/raw_ip ] || {
		log "Device only supports raw-ip mode but is missing this required driver attribute: /sys/class/net/$ifname/qmi/raw_ip"
		exit 1
	}
	echo "Y" > /sys/class/net/$ifname/qmi/raw_ip
fi

uqmi -d $device --fcc-auth
sleep 1

log "Waiting for network registration"
while uqmi -s -d "$device" --get-serving-system | grep '"searching"' > /dev/null; do
	sleep 5;
done

log "Starting network $NAPN"
cid=`uqmi -s -d "$device" --get-client-id wds`
[ $? -ne 0 ] && {
	log "Unable to obtain client ID"
	exit 1
}

uqmi -s -d "$device" --set-client-id wds,"$cid" --set-ip-family ipv4 > /dev/null

ST=$(uqmi -s -d "$device" --set-client-id wds,"$cid" --start-network ${NAPN:+--apn $NAPN} ${auth:+--auth-type $auth} \
	${username:+--username $username} ${password:+--password $password} --autoconnect)
log "Connection returned : $ST"

CONN=$(uqmi -s -d "$device" --get-data-status)
log "Status is $CONN"

CONNZX=$(uqmi -s -d $device --set-client-id wds,$cid --get-current-settings)
log "GET-CURRENT-SETTINGS is $CONNZX"

T=$(echo $CONN | grep "disconnected")
if [ -z $T ]; then
	echo "1" > /tmp/qmigood
	
	cid6=`uqmi -s -d "$device" --get-client-id wds`
	[ $? -ne 0 ] && {
		log "Unable to obtain client ID"
		exit 1
	}
	uqmi -s -d "$device" --set-client-id wds,"$cid6" --set-ip-family ipv6 > /dev/null
	ST6=$(uqmi -s -d "$device" --set-client-id wds,"$cid6" --start-network ${NAPN:+--apn $NAPN} ${auth:+--auth-type $auth} \
	${username:+--username $username} ${password:+--password $password} --autoconnect)
	log "IPv6 Connection returned : $ST6"
	CONNZX=$(uqmi -s -d $device --set-client-id wds,$cid6 --get-current-settings)
	CONF6=$(jsonfilter -s $CONNZX -e '@.ipv6')
	[ -n "$CONF6" ] && log "IPv6 settings are $CONF6"
	
	if [ $DATAFORM = '"raw-ip"' ]; then
		log "Handle raw-ip"
		json_load "$(uqmi -s -d $device --set-client-id wds,$cid --get-current-settings)"
		json_select ipv4
		json_get_vars ip subnet gateway dns1 dns2
		
		json_load "$(uqmi -s -d $device --set-client-id wds,$cid6 --get-current-settings)"
		json_select ipv6
		json_get_var ip_6 ip
		json_get_var gateway_6 gateway
		json_get_var dns1_6 dns1
		json_get_var dns2_6 dns2
		json_get_var ip_prefix_length ip-prefix-length

		if [ -e /tmp/v4dns$INTER -o -e /tmp/v6dns$INTER ]; then
			pdns=1
			if [ -e /tmp/v4dns$INTER ]; then
				v4dns=$(cat /tmp/v4dns$INTER 2>/dev/null)
			fi
			if [ -e /tmp/v6dns$INTER ]; then
				v6dns=$(cat /tmp/v6dns$INTER 2>/dev/null)
			fi
		else
			v4dns="$dns1 $dns2"
			v6dns="$dns1_6 $dns2_6"
		fi

		proto_init_update "$ifname" 1
		proto_set_keep 1
		proto_add_ipv4_address "$ip" "$subnet"
		proto_add_ipv4_route "0.0.0.0" 0
		for DNSV in $(echo "$v4dns"); do
			proto_add_dns_server "$DNSV"
		done

		if [ -n "$CONF6" ]; then
			json_init
			json_add_string name "${interface}_6"
			json_add_string ifname "@$interface"
			json_add_string proto "dhcpv6"
			[ -n "$ip6table" ] && json_add_string ip6table "$ip6table"
			proto_add_dynamic_defaults
			# RFC 7278: Extend an IPv6 /64 Prefix to LAN
			json_add_string extendprefix 1
			json_add_boolean peerdns 0
			json_add_array dns
				for DNSV in $(echo "$v6dns"); do
					json_add_string "" "$DNSV"
				done
			json_close_array
			json_close_object
			ubus call network add_dynamic "$(json_dump)"
		fi
			
		proto_add_data
		json_add_string "cid_4" "$cid"
		json_add_string "pdh_4" "$ST"
		json_add_string "cid_6" "$cid6"
		json_add_string "pdh_6" "$ST6"
		proto_close_data
		proto_send_update "$interface"
	fi
else
	uqmi -s -d "$device" --stop-network 0xffffffff --autoconnect > /dev/null & sleep 10 ; kill -9 $!
fi
