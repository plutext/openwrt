#!/bin/sh 

# automatic build maker 8meg routers

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

#Archer C7v1			*QCA9558				
#GL6408					*AR9331				
#wr1043nv2				*QCA9558				
#wr1043nv3				*QCA9558				
#wr2543v1				*AR9389
#mw4530r				*AR9580				
#dir-505 a1				*AR1311				
#dir-825 b1				*AR922x
#wdr3500				*AR9344 AR9582
#wdr3600				*AR9344 AR9582
#wdr4300				*AR9344 AR9580
#wdr4310				*AR9344 AR9580
#wnr2200v3				*AR9287				
#wndr3700				*AR9220 AR9223	
#MR200					MT7620A MT7610EN - kmod-mt76x0e
#MR3020V3				MT7628N				
#MR3420v5				MT7628N				
#WR902ACv1				QCA9531 QCA9887	
#WR902ACv3				MT7628AN MT7610EN - kmod-mt76x0e
#RT-N56U				RT3662 RT3092
#WT3020					MT7620N				
#RT-13UB1				RT3052				
#Archer C20v1

#
# Samba build
#

cp ./configfiles/8meg/.config_multi8_s ./.config
configfix
make -j5 V=s

# Archer C7v1

MOD3="archer-c7-v1"
EXTB=".bin"

ORIG3=$BASEQ$MOD3$ENDO$EXTB
FIRM3c7v1=$BASE$MOD3$END-samba$EXTB
cp ./bin/targets/ar71xx/generic/$ORIG3 ./images/$FIRM3c7v1

# GL6408

MOD="gl-inet-6408A-v1"
EXTB=".bin"

ORIG=$BASEQ$MOD$ENDO$EXTB
FIRM6408s=$BASE$MOD$END-samba$EXTB
cp ./bin/targets/ar71xx/generic/$ORIG ./images/$FIRM6408s

# wr1043nv2 and v3

MOD2="wr1043nd-v2"
MOD3="wr1043nd-v3"
EXTB=".bin"

ORIG2=$BASEO$MOD2$ENDO$EXTB
FIRM21043v2s=$BASE$MOD2$END-samba$EXTB
ORIG3=$BASEO$MOD3$ENDO$EXTB
FIRM31043v3s=$BASE$MOD3$END-samba$EXTB
cp ./bin/targets/ar71xx/generic/$ORIG2 ./images/$FIRM21043v2s
cp ./bin/targets/ar71xx/generic/$ORIG3 ./images/$FIRM31043v3s

# wr2543

MOD="wr2543-v1"
EXTB=".bin"

ORIG=$BASEO$MOD$ENDO$EXTB
FIRM2530s=$BASE$MOD$END-samba$EXTB
cp ./bin/targets/ar71xx/generic/$ORIG ./images/$FIRM2530s

# mw4530r

MOD="mw4530r-v1"
EXTB=".bin"

ORIG=$BASEQ$MOD$ENDO$EXTB
FIRM4530s=$BASE$MOD$END-samba$EXTB
cp ./bin/targets/ar71xx/generic/$ORIG ./images/$FIRM4530s

# dir-505 a1

MOD="dir-505-a1"
EXTB=".bin"

ORIG=$BASEQ$MOD$ENDO$EXTB
FIRM505s=$BASE$MOD$END"-samba-factory"$EXTB
ORIG2=$BASEQ$MOD$ENDU$EXTB
FIRM2505s=$BASE$MOD$END"-samba-upgrade"$EXTB
cp ./bin/targets/ar71xx/generic/$ORIG ./images/$FIRM505s
cp ./bin/targets/ar71xx/generic/$ORIG2 ./images/$FIRM2505s

# dir-825 b1

MOD="dir-825-b1"
EXTB=".bin"

ORIG=openwrt-ar71xx-generic-dir-825-b1-fat-squashfs-sysupgrade.bin
FIRM825s=$BASE$MOD$END-samba$EXTB
cp ./bin/targets/ar71xx/generic/$ORIG ./images/$FIRM825s

# wdr3500/3600/4300/4310

MOD="wdr3500-v1"
MOD2="wdr3600-v1"
MOD3="wdr4300-v1"
MOD4="wdr4310-v1"
EXTB=".bin"

ORIG=$BASEO$MOD$ENDO$EXTB
FIRM3500s=$BASE$MOD$END-samba$EXTB
ORIG2=$BASEO$MOD2$ENDO$EXTB
FIRM23600s=$BASE$MOD2$END-samba$EXTB
ORIG3=$BASEO$MOD3$ENDO$EXTB
FIRM34300s=$BASE$MOD3$END-samba$EXTB
ORIG4=$BASEO$MOD4$ENDO$EXTB
FIRM44310s=$BASE$MOD4$END-samba$EXTB
cp ./bin/targets/ar71xx/generic/$ORIG ./images/$FIRM3500s
cp ./bin/targets/ar71xx/generic/$ORIG2 ./images/$FIRM23600s
cp ./bin/targets/ar71xx/generic/$ORIG3 ./images/$FIRM34300s
cp ./bin/targets/ar71xx/generic/$ORIG4 ./images/$FIRM44310s

# wnr2200v3

MOD="wnr2200"
EXTB=".img"
EXTU=".bin"

ORIG=$BASEQ$MOD$ENDO$EXTB
ORIG1=$BASEQ$MOD$ENDU$EXTU
FIRM2200s=$BASE$MOD$END"-samba-factory"$EXTB
FIRM12200s=$BASE$MOD$END"-samba-upgrade"$EXTU
cp ./bin/targets/ar71xx/generic/$ORIG ./images/$FIRM2200s
cp ./bin/targets/ar71xx/generic/$ORIG1 ./images/$FIRM12200s

# wndr3700

MOD="wndr3700"
EXTB=".img"
EXTX=".bin"

ORIG=$BASEQ$MOD$ENDO$EXTB
FIRM3700s=$BASE$MOD$END-samba-factory$EXTB
ORIGU=$BASEQ$MOD$ENDU$EXTX
FIRMU3700s=$BASE$MOD$END-samba-update$EXTX
cp ./bin/targets/ar71xx/generic/$ORIG ./images/$FIRM3700s
cp ./bin/targets/ar71xx/generic/$ORIGU ./images/$FIRMU3700s

#
# OpenVpn build
#

cp ./configfiles/8meg/.config_multi8_v ./.config
configfix
make -j5 V=s

# Archer C7v1

MOD3="archer-c7-v1"
EXTB=".bin"

ORIG3=$BASEQ$MOD3$ENDO$EXTB
FIRM3=$BASE$MOD3$END-vpn$EXTB
cp ./bin/targets/ar71xx/generic/$ORIG3 ./images/$FIRM3
cp ./configfiles/8meg/8meg.txt ./images/8meg.txt
cd ./images
zip $MOD3$END.zip $FIRM3 $FIRM3c7v1  8meg.txt
rm -f $FIRM3
rm -f $FIRM3c7v1
rm -f 8meg.txt
cd ..

# GL6408

MOD="gl-inet-6408A-v1"
EXTB=".bin"

ORIG=$BASEQ$MOD$ENDO$EXTB
FIRM=$BASE$MOD$END-vpn$EXTB
cp ./bin/targets/ar71xx/generic/$ORIG ./images/$FIRM
cp ./configfiles/8meg/8meg.txt ./images/8meg.txt
cd ./images
zip $MOD$END.zip $FIRM $FIRM6408s 8meg.txt
rm -f $FIRM
rm -f $FIRM6408s
rm -f 8meg.txt
cd ..

# wr1043nv2 and v3

MOD2="wr1043nd-v2"
MOD3="wr1043nd-v3"
EXTB=".bin"

ORIG2=$BASEO$MOD2$ENDO$EXTB
FIRM2=$BASE$MOD2$END-vpn$EXTB
ORIG3=$BASEO$MOD3$ENDO$EXTB
FIRM3=$BASE$MOD3$END-vpn$EXTB
cp ./bin/targets/ar71xx/generic/$ORIG2 ./images/$FIRM2
cp ./bin/targets/ar71xx/generic/$ORIG3 ./images/$FIRM3
cp ./configfiles/8meg/8meg.txt ./images/8meg.txt
cd ./images
zip $MOD2$END.zip $FIRM2 $FIRM21043v2s 8meg.txt
zip $MOD3$END.zip $FIRM3 $FIRM31043v3s 8meg.txt
rm -f $FIRM2
rm -f $FIRM3
rm -f $FIRM21043v2s
rm -f $FIRM31043v3s
rm -f 8meg.txt
cd ..

# wr2543

MOD="wr2543-v1"
EXTB=".bin"

ORIG=$BASEO$MOD$ENDO$EXTB
FIRM=$BASE$MOD$END-vpn$EXTB
cp ./bin/targets/ar71xx/generic/$ORIG ./images/$FIRM
cp ./configfiles/8meg/8meg.txt ./images/8meg.txt
cd ./images
zip $MOD$END.zip $FIRM $FIRM2530s 8meg.txt
rm -f $FIRM
rm -f $FIRM2530s
rm -f 8meg.txt
cd ..

# mw4530r

MOD="mw4530r-v1"
EXTB=".bin"

ORIG=$BASEQ$MOD$ENDO$EXTB
FIRM=$BASE$MOD$END-vpn$EXTB
cp ./bin/targets/ar71xx/generic/$ORIG ./images/$FIRM
cp ./configfiles/8meg/8meg.txt ./images/8meg.txt
cd ./images
zip $MOD$END.zip $FIRM $FIRM4530s 8meg.txt
rm -f $FIRM
rm -f $FIRM4530s
rm -f 8meg.txt
cd ..

# dir-505 a1

MOD="dir-505-a1"
EXTB=".bin"

ORIG=$BASEQ$MOD$ENDO$EXTB
FIRM=$BASE$MOD$END"-factory-vpn"$EXTB
ORIG2=$BASEQ$MOD$ENDU$EXTB
FIRM2=$BASE$MOD$END"-upgrade-vpn"$EXTB
cp ./bin/targets/ar71xx/generic/$ORIG ./images/$FIRM
cp ./bin/targets/ar71xx/generic/$ORIG2 ./images/$FIRM2
cp ./configfiles/Generic/readme.txt ./images/readme.txt
cp ./configfiles/8meg/8meg.txt ./images/8meg.txt
cd ./images
zip $MOD$END.zip $FIRM $FIRM2 $FIRM505s $FIRM2505s readme.txt 8meg.txt
rm -f $FIRM
rm -f $FIRM2
rm -f $FIRM505s
rm -f $FIRM2505s
rm -f readme.txt
rm -f 8meg.txt
cd ..

# dir-825 b1

MOD="dir-825-b1"
EXTB=".bin"

ORIG=openwrt-ar71xx-generic-dir-825-b1-fat-squashfs-sysupgrade.bin
FIRM=$BASE$MOD$END-vpn$EXTB
cp ./bin/targets/ar71xx/generic/$ORIG ./images/$FIRM
cp ./configfiles/8meg/8meg.txt ./images/8meg.txt
cd ./images
zip $MOD$END.zip $FIRM $FIRM825s 8meg.txt
rm -f $FIRM
rm -f $FIRM825s
rm -f 8meg.txt
cd ..

# wdr3500/3600/4300/4310

MOD="wdr3500-v1"
MOD2="wdr3600-v1"
MOD3="wdr4300-v1"
MOD4="wdr4310-v1"
EXTB=".bin"

ORIG=$BASEO$MOD$ENDO$EXTB
FIRM=$BASE$MOD$END-vpn$EXTB
ORIG2=$BASEO$MOD2$ENDO$EXTB
FIRM2=$BASE$MOD2$END-vpn$EXTB
ORIG3=$BASEO$MOD3$ENDO$EXTB
FIRM3=$BASE$MOD3$END-vpn$EXTB
ORIG4=$BASEO$MOD4$ENDO$EXTB
FIRM4=$BASE$MOD4$END-vpn$EXTB
cp ./bin/targets/ar71xx/generic/$ORIG ./images/$FIRM
cp ./bin/targets/ar71xx/generic/$ORIG2 ./images/$FIRM2
cp ./bin/targets/ar71xx/generic/$ORIG3 ./images/$FIRM3
cp ./bin/targets/ar71xx/generic/$ORIG4 ./images/$FIRM4
cp ./configfiles/8meg/8meg.txt ./images/8meg.txt
cd ./images
zip $MOD$END.zip $FIRM $FIRM3500s 8meg.txt
zip $MOD2$END.zip $FIRM2 $FIRM23600s 8meg.txt
zip $MOD3$END.zip $FIRM3 $FIRM34300s 8meg.txt
zip $MOD4$END.zip $FIRM4 $FIRM44310s 8meg.txt
rm -f $FIRM
rm -f $FIRM2
rm -f $FIRM3
rm -f $FIRM4
rm -f $FIRM3500s
rm -f $FIRM23600s
rm -f $FIRM34300s
rm -f $FIRM44310s
rm -f 8meg.txt
cd ..

# wnr2200v3

MOD="wnr2200"
EXTB=".img"
EXTU=".bin"

ORIG=$BASEQ$MOD$ENDO$EXTB
ORIG1=$BASEQ$MOD$ENDU$EXTU
FIRM=$BASE$MOD$END"-factory-vpn"$EXTB
FIRM1=$BASE$MOD$END"-upgrade-vpn"$EXTU
cp ./bin/targets/ar71xx/generic/$ORIG ./images/$FIRM
cp ./bin/targets/ar71xx/generic/$ORIG1 ./images/$FIRM1
cp ./configfiles/Generic/readme.txt ./images/readme.txt
cp ./configfiles/8meg/8meg.txt ./images/8meg.txt
cd ./images
zip $MOD$END.zip $FIRM $FIRM1 $FIRM2200s $FIRM12200s readme.txt 8meg.txt
rm -f $FIRM
rm -f $FIRM1
rm -f $FIRM2200s
rm -f $FIRM12200s
rm -f readme.txt
rm -f 8meg.txt
cd ..

# wndr3700

MOD="wndr3700"
EXTB=".img"
EXTX=".bin"

ORIG=$BASEQ$MOD$ENDO$EXTB
FIRM=$BASE$MOD$END-vpn-factory$EXTB
ORIGU=$BASEQ$MOD$ENDU$EXTX
FIRMU=$BASE$MOD$END-vpn-update$EXTX
cp ./bin/targets/ar71xx/generic/$ORIG ./images/$FIRM
cp ./bin/targets/ar71xx/generic/$ORIGU ./images/$FIRMU
cp ./configfiles/WNDR3700/SpecialFlashingInstructions.pdf ./images/SpecialFlashingInstructions.pdf
cp ./configfiles/8meg/8meg.txt ./images/8meg.txt
cd ./images
zip -r $MOD$END.zip $FIRM $FIRMU $FIRM3700s $FIRMU3700s SpecialFlashingInstructions.pdf 8meg.txt
rm -f $FIRM
rm -f $FIRMU
rm -f $FIRM3700s
rm -f $FIRMU3700s
rm -f SpecialFlashingInstructions.pdf
rm -f 8meg.txt
cd ..




# MR200

MOD="mr200"
EXTB=".bin"

cp ./configfiles/8meg/.config_200_s ./.config
configfix
make -j5 V=s
ORIG=openwrt-ramips-mt7620-ArcherMR200-squashfs-sysupgrade.bin
FIRM=$BASE$MOD$END-samba-upgrade$EXTB
cp ./bin/targets/ramips/mt7620/$ORIG ./images/$FIRM

cp ./configfiles/8meg/.config_200_v ./.config
configfix
make -j5 V=s
FIRM1=$BASE$MOD$END-vpn-upgrade$EXTB
cp ./bin/targets/ramips/mt7620/$ORIG ./images/$FIRM1
cp ./configfiles/8meg/8meg.txt ./images/8meg.txt
cd ./images
zip $MOD$END.zip $FIRM $FIRM1 8meg.txt
rm -f $FIRM
rm -f $FIRM1
rm -f 8meg.txt
cd ..

# MR3420V6

MOD="mr3420v5"
EXTB=".bin"

cp ./configfiles/8meg/.config_3420v5_s ./.config
configfix
make -j5 V=s
ORIG="openwrt-ramips-mt76x8-tplink_tl-mr3420-v5-squashfs-tftp-recovery.bin"
FIRM=$BASE$MOD$END"-samba-tftp-recovery"$EXTB
ORIG2="openwrt-ramips-mt76x8-tplink_tl-mr3420-v5-squashfs-sysupgrade.bin"
FIRM2=$BASE$MOD$END"-samba-upgrade"$EXTB
cp ./bin/targets/ramips/mt76x8/$ORIG ./images/$FIRM
cp ./bin/targets/ramips/mt76x8/$ORIG2 ./images/$FIRM2

cp ./configfiles/8meg/.config_3420v5_v ./.config
configfix
make -j5 V=s
ORIG1="openwrt-ramips-mt76x8-tplink_tl-mr3420-v5-squashfs-tftp-recovery.bin"
FIRM1=$BASE$MOD$END"-vpn-tftp-recovery"$EXTB
ORIG21="openwrt-ramips-mt76x8-tplink_tl-mr3420-v5-squashfs-sysupgrade.bin"
FIRM21=$BASE$MOD$END"-vpn-upgrade"$EXTB
cp ./bin/targets/ramips/mt76x8/$ORIG1 ./images/$FIRM1
cp ./bin/targets/ramips/mt76x8/$ORIG21 ./images/$FIRM21

cp ./configfiles/8meg/8meg.txt ./images/8meg.txt
cd ./images
zip -r $MOD$END.zip $FIRM $FIRM2 $FIRM1 $FIRM21 8meg.txt
rm -f $FIRM
rm -f $FIRM2
rm -f $FIRM1
rm -f $FIRM21
rm -f 8meg.txt
cd ..


# WR902ACv1

cp ./configfiles/8meg/.config_902v1_s ./.config
configfix
make -j5 V=s

MOD="wr902ac-v1"
EXTB=".bin"

ORIG=$BASEO$MOD$ENDO$EXTB
FIRM=$BASE$MOD$END-samba-factory$EXTB
ORIG1=$BASEO$MOD$ENDU$EXTB
FIRM1=$BASE$MOD$END-samba-upgrade$EXTB
cp ./bin/targets/ar71xx/generic/$ORIG ./images/$FIRM
cp ./bin/targets/ar71xx/generic/$ORIG1 ./images/$FIRM1

cp ./configfiles/8meg/.config_902v1_v ./.config
configfix
make -j5 V=s

ORIG2=$BASEO$MOD$ENDO$EXTB
FIRM2=$BASE$MOD$END-vpn-factory$EXTB
ORIG3=$BASEO$MOD$ENDU$EXTB
FIRM3=$BASE$MOD$END-vpn-upgrade$EXTB
cp ./bin/targets/ar71xx/generic/$ORIG2 ./images/$FIRM2
cp ./bin/targets/ar71xx/generic/$ORIG3 ./images/$FIRM3

cp ./configfiles/8meg/8meg.txt ./images/8meg.txt
cd ./images
zip $MOD$END.zip $FIRM $FIRM1 $FIRM2 $FIRM3 8meg.txt
rm -f $FIRM
rm -f $FIRM1
rm -f $FIRM2
rm -f $FIRM3
rm -f 8meg.txt
cd ..

# WR902ACv3

MOD="wr902v3"
EXTB=".bin"

cp ./configfiles/8meg/.config_902v3_s ./.config
configfix
make -j5 V=s
ORIG="openwrt-ramips-mt76x8-tplink_tl-wr902ac-v3-squashfs-tftp-recovery.bin"
FIRM=$BASE$MOD$END"-samba-tftp-recovery"$EXTB
ORIG2="openwrt-ramips-mt76x8-tplink_tl-wr902ac-v3-squashfs-sysupgrade.bin"
FIRM2=$BASE$MOD$END"-samba-upgrade"$EXTB
cp ./bin/targets/ramips/mt76x8/$ORIG ./images/$FIRM
cp ./bin/targets/ramips/mt76x8/$ORIG2 ./images/$FIRM2

cp ./configfiles/8meg/.config_902v3_v ./.config
configfix
make -j5 V=s
ORIG1="openwrt-ramips-mt76x8-tplink_tl-wr902ac-v3-squashfs-tftp-recovery.bin"
FIRM1=$BASE$MOD$END"-vpn-tftp-recovery"$EXTB
ORIG21="openwrt-ramips-mt76x8-tplink_tl-wr902ac-v3-squashfs-sysupgrade.bin"
FIRM21=$BASE$MOD$END"-vpn-upgrade"$EXTB
cp ./bin/targets/ramips/mt76x8/$ORIG1 ./images/$FIRM1
cp ./bin/targets/ramips/mt76x8/$ORIG21 ./images/$FIRM21

cp ./configfiles/8meg/8meg.txt ./images/8meg.txt
cd ./images
zip -r $MOD$END.zip $FIRM $FIRM2 $FIRM1 $FIRM21 8meg.txt
rm -f $FIRM
rm -f $FIRM2
rm -f $FIRM1
rm -f $FIRM21
rm -f 8meg.txt
cd ..


# RT-N56U

MOD="rt-n56u"
EXTB=".bin"

cp ./configfiles/8meg/.config_n56u_s ./.config
configfix
make -j5 V=s
ORIG2="openwrt-ramips-rt3883-rt-n56u-squashfs-sysupgrade.bin"
FIRM2=$BASE$MOD$END"-samba"$EXTB
cp ./bin/targets/ramips/rt3883/$ORIG2 ./images/$FIRM2

cp ./configfiles/8meg/.config_n56u_v ./.config
configfix
make -j5 V=s
ORIG21="openwrt-ramips-rt3883-rt-n56u-squashfs-sysupgrade.bin"
FIRM21=$BASE$MOD$END"-vpn"$EXTB
cp ./bin/targets/ramips/rt3883/$ORIG21 ./images/$FIRM21

cp ./configfiles/Generic/readme.txt ./images/readme.txt
cp ./configfiles/8meg/8meg.txt ./images/8meg.txt
cd ./images
zip $MOD$END.zip $FIRM2 $FIRM21 readme.txt 8meg.txt
rm -f $FIRM2
rm -f $FIRM21
rm -f readme.txt
rm -f 8meg.txt
cd ..

# MT3020

MOD="wt3020-8M"
EXTB=".bin"

cp ./configfiles/8meg/.config_nexx_s ./.config
configfix
make -j5 V=s
ORIG="openwrt-ramips-mt7620-wt3020-8M-squashfs-factory.bin"
FIRM=$BASE$MOD$END"-samba-factory"$EXTB
ORIG2="openwrt-ramips-mt7620-wt3020-8M-squashfs-sysupgrade.bin"
FIRM2=$BASE$MOD$END"-samba-upgrade"$EXTB
cp ./bin/targets/ramips/mt7620/$ORIG ./images/$FIRM
cp ./bin/targets/ramips/mt7620/$ORIG2 ./images/$FIRM2

cp ./configfiles/8meg/.config_nexx_v ./.config
configfix
make -j5 V=s
ORIG1="openwrt-ramips-mt7620-wt3020-8M-squashfs-factory.bin"
FIRM1=$BASE$MOD$END"-vpn-factory"$EXTB
ORIG21="openwrt-ramips-mt7620-wt3020-8M-squashfs-sysupgrade.bin"
FIRM21=$BASE$MOD$END"-vpn-upgrade"$EXTB
cp ./bin/targets/ramips/mt7620/$ORIG1 ./images/$FIRM1
cp ./bin/targets/ramips/mt7620/$ORIG21 ./images/$FIRM21

cp ./configfiles/Generic/readme.txt ./images/readme.txt
cp ./configfiles/8meg/8meg.txt ./images/8meg.txt
cd ./images
zip -r $MOD$END.zip $FIRM $FIRM2 $FIRM1 $FIRM21 readme.txt 8meg.txt
rm -f $FIRM
rm -f $FIRM2
rm -f $FIRM1
rm -f $FIRM21
rm -f readme.txt
rm -f 8meg.txt
cd ..

# RT-13U

MOD="rt-n13u-b1"
EXTB=".bin"

cp ./configfiles/8meg/.config_n13u_s ./.config
configfix
make -j5 V=s
ORIG1="openwrt-ramips-rt305x-rt-n13u-squashfs-sysupgrade.bin"
FIRM1=$BASE$MOD$END-samba$EXTB
cp ./bin/targets/ramips/rt305x/$ORIG1 ./images/$FIRM1

cp ./configfiles/8meg/.config_n13u_v ./.config
configfix
make -j5 V=s
ORIG11="openwrt-ramips-rt305x-rt-n13u-squashfs-sysupgrade.bin"
FIRM11=$BASE$MOD$END-vpn$EXTB
cp ./bin/targets/ramips/rt305x/$ORIG11 ./images/$FIRM11

cp ./configfiles/RT13U/tftp2.exe ./images/tftp2.exe
cp ./configfiles/RT13U/Flashing_an_Asus_RT-N13U_Router.pdf ./images/Flashing_an_Asus_RT-N13U_Router.pdf
cp ./configfiles/8meg/8meg.txt ./images/8meg.txt
cd ./images
zip $MOD$END.zip $FIRM1 $FIRM11 tftp2.exe Flashing_an_Asus_RT-N13U_Router.pdf 8meg.txt
rm -f $FIRM1
rm -f $FIRM11
rm -f tftp2.exe
rm -f Flashing_an_Asus_RT-N13U_Router.pdf
rm -f 8meg.txt
cd ..

# Archer C20V1

MOD="C20v1"
EXTB=".bin"

cp ./configfiles/8meg/.config_c20v1_s ./.config
configfix
make -j5 V=s
ORIG="openwrt-ramips-mt7620-tplink_c20-v1-squashfs-factory.bin"
FIRM=$BASE$MOD$END"-samba-factory"$EXTB
ORIG2="openwrt-ramips-mt7620-tplink_c20-v1-squashfs-sysupgrade.bin"
FIRM2=$BASE$MOD$END"-samba-upgrade"$EXTB
cp ./bin/targets/ramips/mt7620/$ORIG ./images/$FIRM
cp ./bin/targets/ramips/mt7620/$ORIG2 ./images/$FIRM2

cp ./configfiles/8meg/.config_c20v1_v ./.config
configfix
make -j5 V=s
ORIG1="openwrt-ramips-mt7620-tplink_c20-v1-squashfs-factory.bin"
FIRM1=$BASE$MOD$END"-vpn-factory"$EXTB
ORIG21="openwrt-ramips-mt7620-tplink_c20-v1-squashfs-sysupgrade.bin"
FIRM21=$BASE$MOD$END"-vpn-upgrade"$EXTB
cp ./bin/targets/ramips/mt7620/$ORIG1 ./images/$FIRM1
cp ./bin/targets/ramips/mt7620/$ORIG21 ./images/$FIRM21

cp ./configfiles/8meg/8meg.txt ./images/8meg.txt
cd ./images
zip -r $MOD$END.zip $FIRM $FIRM2 $FIRM1 $FIRM21 8meg.txt
rm -f $FIRM
rm -f $FIRM2
rm -f $FIRM1
rm -f $FIRM21
rm -f 8meg.txt
cd ..

# MR3020v3

MOD="MR3020v3"
EXTB=".bin"

cp ./configfiles/8meg/.config_3020v3_s ./.config
configfix
make -j5 V=s
ORIG="openwrt-ramips-mt76x8-tplink_tl-mr3020-v3-squashfs-tftp-recovery.bin"
FIRM=$BASE$MOD$END"-samba-tftp-recovery"$EXTB
ORIG2="openwrt-ramips-mt76x8-tplink_tl-mr3020-v3-squashfs-sysupgrade.bin"
FIRM2=$BASE$MOD$END"-samba-upgrade"$EXTB
cp ./bin/targets/ramips/mt76x8/$ORIG ./images/$FIRM
cp ./bin/targets/ramips/mt76x8/$ORIG2 ./images/$FIRM2

cp ./configfiles/8meg/.config_3020v3_v ./.config
configfix
make -j5 V=s
ORIG1="openwrt-ramips-mt76x8-tplink_tl-mr3020-v3-squashfs-tftp-recovery.bin"
FIRM1=$BASE$MOD$END"-vpn-tftp-recovery"$EXTB
ORIG21="openwrt-ramips-mt76x8-tplink_tl-mr3020-v3-squashfs-sysupgrade.bin"
FIRM21=$BASE$MOD$END"-vpn-upgrade"$EXTB
cp ./bin/targets/ramips/mt76x8/$ORIG1 ./images/$FIRM1
cp ./bin/targets/ramips/mt76x8/$ORIG21 ./images/$FIRM21

cp ./configfiles/8meg/8meg.txt ./images/8meg.txt
cd ./images
zip -r $MOD$END.zip $FIRM $FIRM2 $FIRM1 $FIRM21 8meg.txt
rm -f $FIRM
rm -f $FIRM2
rm -f $FIRM1
rm -f $FIRM21
rm -f 8meg.txt
cd ..