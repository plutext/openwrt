#!/bin/sh

# automatic build maker

#build version

configfix() {
	DNS=$(cat "./.config" | grep "CONFIG_PACKAGE_dnsmasq-full=y")
	if [ ! -z $DNS ]; then
		sed -i -e 's/CONFIG_PACKAGE_dnsmasq=y/# CONFIG_PACKAGE_dnsmasq is not set/g' ./.config
	fi
	WPAD=$(cat "./.config" | grep "CONFIG_PACKAGE_wpad-basic=y")
	if [ ! -z $WPAD ]; then
		sed -i -e 's/CONFIG_PACKAGE_wpad-basic=y/# CONFIG_PACKAGE_wpad-basic is not set/g' ./.config
	fi
	WPAD=$(cat "./.config" | grep "CONFIG_PACKAGE_wpad=y")
	if [ ! -z $WPAD ]; then
		sed -i -e 's/CONFIG_PACKAGE_wpad-mini=y/# CONFIG_PACKAGE_wpad-mini is not set/g' ./.config
	fi
}

DATE="2020-03-01"

NAME="GoldenOrb_"
CODE=$NAME$DATE
rm -rf ./files
mkdir -p ./files/etc

echo 'CODENAME="'"$CODE"'"' > ./files/etc/codename

echo "                            <model>" > ./files/etc/header_msg
echo "/img/header.png" >> ./files/etc/header_msg
echo "/img/rosy.jpg" >> ./files/etc/header_msg

BASE="openwrt-"
BASEO="openwrt-ar71xx-generic-tl-"
BASEQ="openwrt-ar71xx-generic-"
ENDO="-squashfs-factory"
ENDU="-squashfs-sysupgrade"

TYP="-GO"
END=$TYP$DATE

# TD-W8970v1
# TD-W8980v1
# Easy Box 802



# TD-W8970

cp ./configfiles/4meg/.config_8970 ./.config
make V=s

MOD="TDW8970v1"
EXTB=".bin"

ORIG=openwrt-lantiq-xrx200-tplink_tdw8970-squashfs-sysupgrade.bin
FIRM=$BASE$MOD$END$EXTB
cp ./bin/targets/lantiq/xrx200/$ORIG ./images/$FIRM
cd ./images
zip $MOD$END.zip $FIRM
rm -f $FIRM
cd ..

# TD-W8980

cp ./configfiles/4meg/.config_8980 ./.config
make V=s

MOD="TDW8980v1"
EXTB=".bin"

ORIG=openwrt-lantiq-xrx200-tplink_tdw8980-squashfs-sysupgrade.bin
FIRM=$BASE$MOD$END$EXTB
cp ./bin/targets/lantiq/xrx200/$ORIG ./images/$FIRM
cd ./images
zip $MOD$END.zip $FIRM
rm -f $FIRM
cd ..

# Easy Box 802

cp ./configfiles/4meg/.config_eb802 ./.config
make V=s

MOD="EasyBox802"
EXTB=".bin"

ORIG=openwrt-lantiq-xway-arcadyan_arv752dpw-squashfs-sysupgrade.bin
FIRM=$BASE$MOD$END$EXTB
cp ./bin/targets/lantiq/xway/$ORIG ./images/$FIRM
cd ./images
zip $MOD$END.zip $FIRM
rm -f $FIRM
cd ..

