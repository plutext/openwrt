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
	rm -rf ./bin
}

DATE="2020-11-28"

NAME="GoldenOrb_"
CODE=$NAME$DATE
rm -rf ./files
rm -rf ./bin
mkdir -p ./files/etc

echo 'CODENAME="'"$CODE"'"' > ./files/etc/codename

echo "                            <model>" > ./files/etc/header_msg
echo "/img/header.png" >> ./files/etc/header_msg
echo "/img/rosy.png" >> ./files/etc/header_msg

BASE="openwrt-"
BASEO="openwrt-ar71xx-generic-tl-"
BASEQ="openwrt-ar71xx-generic-"
ENDO="-squashfs-factory"
ENDU="-squashfs-sysupgrade"

TYP="-GO"
END=$TYP$DATE

# HG553
# R8000
# RT-AC56U
# RT-AC68U
# RT-AC87U
# AR5387un
# dgnd3700v4
# R7000
# e6300
# RT-N66U
# RT-N16
# R5010UNv2



# HW553

cp ./configfiles/broad/.config_hg553 ./.config
configfix
make V=s

MOD="HG553"
EXTB=".bin"

ORIG="openwrt-brcm63xx-generic-HG553-squashfs-cfe.bin"
FIRM=$BASE$MOD$END$EXTB
cp ./bin/targets/brcm63xx/generic/$ORIG ./images/$FIRM
cp ./configfiles/HG/readme.txt ./images/readme.txt
cd ./images
zip -r $MOD$END.zip $FIRM readme.txt
rm -f $FIRM
rm -f readme.txt
cd ..

# mk8000

cp ./configfiles/broad/.config_8000 ./.config
configfix
make V=s

MOD="r8000"
EXTB=".chk"

ORIG="openwrt-bcm53xx-netgear-r8000-squashfs.chk"
FIRM=$BASE$MOD$END$EXTB
cp ./bin/targets/bcm53xx/generic/$ORIG ./images/$FIRM
cd ./images
zip -r $MOD$END.zip $FIRM 
rm -f $FIRM
cd ..

# RT-AC56U

cp ./configfiles/broad/.config_ac56u ./.config
configfix
make V=s

MOD="rt-ac56u"
EXTB=".trx"

ORIG="openwrt-bcm53xx-asus-rt-ac56u-squashfs.trx"
FIRM=$BASE$MOD$END$EXTB
cp ./bin/targets/bcm53xx/generic/$ORIG ./images/$FIRM
cd ./images
zip -r $MOD$END.zip $FIRM 
rm -f $FIRM
cd ..

# RT-N66U

cp ./configfiles/broad/.config_n66u ./.config
configfix
make V=s

MOD="rt-n66u"
EXTB=".trx"

ORIG=openwrt-brcm47xx-mips74k-asus-rt-n66u-squashfs.trx
FIRM=$BASE$MOD$END$EXTB
cp ./bin/targets/brcm47xx/mips74k/$ORIG ./images/$FIRM
cd ./images
zip $MOD$END.zip $FIRM
rm -f $FIRM
cd ..

# RT-AC68U

cp ./configfiles/broad/.config_ac68u ./.config
configfix
make V=s

MOD="rt-ac68u"
EXTB=".trx"

ORIG=openwrt-bcm53xx-asus-rt-ac68u-squashfs.trx
FIRM=$BASE$MOD$END$EXTB
cp ./bin/targets/bcm53xx/generic/$ORIG ./images/$FIRM
cd ./images
zip $MOD$END.zip $FIRM
rm -f $FIRM
cd ..

# RT-AC87U

cp ./configfiles/broad/.config_ac87u ./.config
configfix
make V=s

MOD="rt-ac87u"
EXTB=".trx"

ORIG="openwrt-bcm53xx-asus-rt-ac87u-squashfs.trx"
FIRM=$BASE$MOD$END$EXTB
cp ./bin/targets/bcm53xx/generic/$ORIG ./images/$FIRM
cd ./images
zip -r $MOD$END.zip $FIRM 
rm -f $FIRM
cd ..

# AR5387un

cp ./configfiles/broad/.config_ar5387 ./.config
configfix
make V=s

MOD="AR5387"
EXTB=".bin"

ORIG="openwrt-brcm63xx-generic-AR5387un-squashfs-cfe.bin"
FIRM=$BASE$MOD$END$EXTB
cp ./bin/targets/brcm63xx/generic/$ORIG ./images/$FIRM
cp ./configfiles/AR/readme.txt ./images/readme.txt
cd ./images
zip -r $MOD$END.zip $FIRM readme.txt
rm -f $FIRM
rm -f readme.txt
cd ..

# dgnd3700v4

cp ./configfiles/broad/.config_dgnd3700 ./.config
configfix
make V=s

MOD="dgnd3700v1"
EXTB=".chk"

ORIG="openwrt-brcm63xx-generic-DGND3700v1-squashfs-factory.chk"
FIRM=$BASE$MOD$END$EXTB
cp ./bin/targets/brcm63xx/generic/$ORIG ./images/$FIRM
cd ./images
zip -r $MOD$END.zip $FIRM 
rm -f $FIRM
cd ..

# R7000

cp ./configfiles/broad/.config_r7000 ./.config
configfix
make V=s

MOD="r7000"
MOD1="r6300-v2"
EXTB=".chk"
ORIG=openwrt-bcm53xx-netgear-r7000-squashfs.chk
ORIG1=openwrt-bcm53xx-netgear-r6300-v2-squashfs.chk
FIRM=$BASE$MOD$END$EXTB
FIRM1=$BASE$MOD1$END$EXTB
cp ./bin/targets/bcm53xx/generic/$ORIG ./images/$FIRM
cp ./bin/targets/bcm53xx/generic/$ORIG1 ./images/$FIRM1
cd ./images
zip -r $MOD$END.zip $FIRM 
zip -r $MOD1$END.zip $FIRM1 
rm -f $FIRM
rm -f $FIRM1
cd ..

# RT-N16

cp ./configfiles/broad/.config_n16 ./.config
configfix
make V=s

MOD="rt-n16"
EXTB=".trx"

ORIG="openwrt-brcm47xx-mips74k-asus-rt-n16-squashfs.trx"
FIRM=$BASE$MOD$END$EXTB
cp ./bin/targets/brcm47xx/mips74k/$ORIG ./images/$FIRM
cd ./images
zip -r $MOD$END.zip $FIRM 
rm -f $FIRM
cd ..

# R5010UNv2

cp ./configfiles/broad/.config_r5010 ./.config
configfix
make V=s

MOD="R5010UNv2"
EXTB=".bin"

ORIG="openwrt-brcm63xx-generic-R5010UNv2-squashfs-cfe.bin"
FIRM=$BASE$MOD$END-factory$EXTB
ORIG1="openwrt-brcm63xx-generic-R5010UNv2-squashfs-sysupgrade.bin"
FIRM1=$BASE$MOD$END-upgrade$EXTB
cp ./bin/targets/brcm63xx/generic/$ORIG ./images/$FIRM
cp ./bin/targets/brcm63xx/generic/$ORIG1 ./images/$FIRM1
cd ./images
zip -r $MOD$END.zip $FIRM $FIRM1
rm -f $FIRM
rm -f $FIRM1
cd ..

cp ./configfiles/broad/.config_3500l ./.config
configfix
make -j5 V=s

MOD="WNR3500Lv1"
EXTB=".chk"
ORIG=openwrt-brcm47xx-mips74k-netgear-wnr3500l-v1-na-squashfs.chk
FIRM=$BASE$MOD$END-upgrade$EXTB
cp ./bin/targets/brcm47xx/mips74k/$ORIG ./images/$FIRM
cd ./images
zip $MOD$END.zip $FIRM
rm -f $FIRM
cd ..
