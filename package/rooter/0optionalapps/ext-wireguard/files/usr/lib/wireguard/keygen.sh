#!/bin/sh

log() {
	logger -t "Wireguard KeyGen" "$@"
}

WG=$1

EXST=$(uci get wireguard."$WG")
if [ -z $EXST ]; then
	uci set wireguard."$WG"="wireguard"
	uci commit wireguard
fi

PRIV=$(uci get wireguard."$WG".privatekey)
if [ -z $PRIV ]; then
	umask u=rw,g=,o=
	wg genkey | tee /tmp/wgserver.key | wg pubkey > /tmp/wgclient.pub
	wg genpsk > /tmp/wg.psk
	 
	WG_KEY="$(cat /tmp/wgserver.key)" # private key
	WG_PSK="$(cat /tmp/wg.psk)" # shared key
	WG_PUB="$(cat /tmp/wgclient.pub)" # public key to be used on other end
	rm -f /tmp/wgserver.key
	rm -f /tmp/wg.psk
	rm -f /tmp/wgclient.pub
	uci set wireguard."$WG".privatekey=$WG_KEY
	uci set wireguard."$WG".publickey=$WG_PUB
	uci set wireguard."$WG".sharedkey=$WG_PSK
	uci commit wireguard
fi

