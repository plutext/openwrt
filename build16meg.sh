#!/bin/sh 

# automatic build maker 16meg routers

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

rm -rf ./bin
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

# Alix 2D13

# MT300A
# MT300N
# MT300Nv2
# AR750
# AR750S
# b1300
# ar150
# ar300-16
# domino pi
# GL6416
# GL-Mifi

# HW556 A,B,C

# WE826/WE1026
# WE3526
# WE1026-5G
# WE1326
# WE1326v5
# WG3526
# WE826-Q

# DIR-860L
# dir-825 c1
# dir-835 a1

# WRT1200AC
# WRT1900AC
# WRT1900ACS
# WRT3200ACM
# WRT32x

# wndr3700v4
# wndr3700/3800/mac

# MT7620-d240
# EA8500
# ea3500
# ea4500

# R6220
# R7800
# R7500
# RT-AC51U
# APU2C4

# archer C5
# archer C7v2
# archer C7v3
# archer c7v4
# archer C7v5
# C2600
# wdr4900
# wr1043nv4
# wr1043nv5
# wr842nv3
# WR703N-16
# archer C9v1

# BT Home Hub 5A
# Mikrotik

# R36a
# Alfa Tube-E4G

# mynet N600
# mynet N750

# WZR-HP-G300NH
# WZR-HP-AG300H
# WZR-600DHP

# DGL-5500
# Turris Omnia
# Orange Pi Zero Plus
# RBM11G
# RBM33G

# Raspberry Pi
# Raspberry Pi 2
# Raspberry Pi 3

# U7621-06
# U7628-01

# x86
# Xiaomi Mini
# Xiaomi Mini 3G
# Y1
# Y1S
# DHP-1565
# NanoPi Neo Plus 2

# Youhua WR1200JS




# Alix 2D13

cp ./configfiles/16meg/.config_2d13 ./.config
configfix
make -j5 V=s

MOD="alix-2d13"
EXTB=".img.gz"

ORIG=openwrt-x86-geode-combined-ext4.img.gz
FIRM=$BASE$MOD$END$EXTB
cp ./bin/targets/x86/geode/$ORIG ./images/$FIRM
cd ./images
zip $MOD$END.zip $FIRM
rm -f $FIRM
cd ..

# MT300A

cp ./configfiles/16meg/.config_300a ./.config
configfix
make -j5 V=s

MOD="mt300a"
EXTB=".bin"

ORIG=openwrt-ramips-mt7620-gl-mt300a-squashfs-sysupgrade.bin
FIRM=$BASE$MOD$END"-upgrade"$EXTB
cp ./bin/targets/ramips/mt7620/$ORIG ./images/$FIRM
cd ./images
zip $MOD$END.zip $FIRM
rm -f $FIRM
cd ..

# MT300N

cp ./configfiles/16meg/.config_300n ./.config
configfix
make -j5 V=s

MOD="mt300n"
EXTB=".bin"

ORIG=openwrt-ramips-mt7620-gl-mt300n-squashfs-sysupgrade.bin
FIRM=$BASE$MOD$END"-upgrade"$EXTB
cp ./bin/targets/ramips/mt7620/$ORIG ./images/$FIRM
cd ./images
zip $MOD$END.zip $FIRM
rm -f $FIRM
cd ..

#MT300Nv2

cp ./configfiles/16meg/.config_300nv2 ./.config
configfix
make -j5 V=s

MOD="mt300n-v2"
EXTB=".bin"

ORIG=openwrt-ramips-mt76x8-gl-mt300n-v2-squashfs-sysupgrade.bin
FIRM=$BASE$MOD$END"-upgrade"$EXTB
cp ./bin/targets/ramips/mt76x8/$ORIG ./images/$FIRM
cd ./images
zip $MOD$END.zip $FIRM
rm -f $FIRM
cd ..

# HW556

cp ./configfiles/16meg/.config_hg556a ./.config
configfix
make -j5 V=s
cp ./configfiles/16meg/.config_hg556b ./.config
configfix
make -j5 V=s
cp ./configfiles/16meg/.config_hg556c ./.config
configfix
make -j5 V=s

MOD="HG556"
EXTB=".bin"

ORIG="openwrt-brcm63xx-generic-HG556a-A-squashfs-cfe.bin"
ORIG1="openwrt-brcm63xx-generic-HG556a-B-squashfs-cfe.bin"
ORIG2="openwrt-brcm63xx-generic-HG556a-C-squashfs-cfe.bin"
FIRM=$BASE$MOD"_A"$END$EXTB
FIRM1=$BASE$MOD"_B"$END$EXTB
FIRM2=$BASE$MOD"_C"$END$EXTB
cp ./bin/targets/brcm63xx/generic/$ORIG ./images/$FIRM
cp ./bin/targets/brcm63xx/generic/$ORIG1 ./images/$FIRM1
cp ./bin/targets/brcm63xx/generic/$ORIG2 ./images/$FIRM2
cp ./configfiles/HG/readme.txt ./images/readme.txt
cd ./images
zip -r $MOD"_A"$END.zip $FIRM readme.txt
zip -r $MOD"_B"$END.zip $FIRM1 readme.txt
zip -r $MOD"_C"$END.zip $FIRM2 readme.txt
rm -f $FIRM
rm -f $FIRM1
rm -f $FIRM2
rm -f readme.txt
cd ..

# WE826/WE1026

cp ./configfiles/16meg/.config_826 ./.config
configfix
make -j5 V=s

MOD="we826"
EXTB=".bin"

ORIG=openwrt-ramips-mt7620-zbt-we826-16M-squashfs-sysupgrade.bin
FIRM=$BASE$MOD$END-upgrade$EXTB
cp ./bin/targets/ramips/mt7620/$ORIG ./images/$FIRM
cd ./images
zip $MOD$END.zip $FIRM
rm -f $FIRM
cd ..

# DIR-860L

cp ./configfiles/16meg/.config_860 ./.config
configfix
make -j5 V=s

MOD="dir-860l"
EXTB=".bin"

ORIG="openwrt-ramips-mt7621-dir-860l-b1-squashfs-factory.bin"
FIRM=$BASE$MOD$END"-factory"$EXTB
ORIG1="openwrt-ramips-mt7621-dir-860l-b1-squashfs-sysupgrade.bin"
FIRM1=$BASE$MOD$END"-upgrade"$EXTB
cp ./bin/targets/ramips/mt7621/$ORIG ./images/$FIRM
cp ./bin/targets/ramips/mt7621/$ORIG1 ./images/$FIRM1
cp ./configfiles/Generic/readme.txt ./images/readme.txt
cd ./images
zip -r $MOD$END.zip $FIRM $FIRM1 readme.txt
rm -f $FIRM
rm -f $FIRM1
rm -f readme.txt
cd ..

# 1200AC

cp ./configfiles/16meg/.config_1200ac ./.config
configfix
make -j5 V=s

MOD="WRT1200AC"
EXTB="-factory.img"
EXTB1="-upgrade.bin"

ORIG="openwrt-mvebu-cortexa9-linksys-wrt1200ac-squashfs-factory.img"
ORIG1="openwrt-mvebu-cortexa9-linksys-wrt1200ac-squashfs-sysupgrade.bin"
FIRM=$BASE$MOD$END$EXTB
FIRM1=$BASE$MOD$END$EXTB1
cp ./bin/targets/mvebu/cortexa9/$ORIG ./images/$FIRM
cp ./bin/targets/mvebu/cortexa9/$ORIG1 ./images/$FIRM1
cp ./configfiles/Generic/readme.txt ./images/readme.txt
cd ./images
zip -r $MOD$END.zip $FIRM $FIRM1 readme.txt
rm -f $FIRM
rm -f $FIRM1
rm -f readme.txt
cd ..

# 1900AC 1900ACS 3200ACM

cp ./configfiles/16meg/.config_1900acv1 ./.config
configfix
make -j5 V=s
cp ./configfiles/16meg/.config_1900acv2 ./.config
configfix
make -j5 V=s
cp ./configfiles/16meg/.config_1900acs ./.config
configfix
make -j5 V=s
cp ./configfiles/16meg/.config_3200acm ./.config
configfix
make -j5 V=s
cp ./configfiles/16meg/.config_wrt32x ./.config
configfix
make -j5 V=s

MOD="WRT1900ACS"
EXTB="-factory.img"
EXTB1="-upgrade.bin"

ORIG="openwrt-mvebu-cortexa9-linksys-wrt1900acs-squashfs-factory.img"
ORIG1="openwrt-mvebu-cortexa9-linksys-wrt1900acs-squashfs-sysupgrade.bin"
FIRM=$BASE$MOD$END$EXTB
FIRM1=$BASE$MOD$END$EXTB1
cp ./bin/targets/mvebu/cortexa9/$ORIG ./images/$FIRM
cp ./bin/targets/mvebu/cortexa9/$ORIG1 ./images/$FIRM1
cp ./configfiles/Generic/readme.txt ./images/readme.txt
cd ./images
zip -r $MOD$END.zip $FIRM $FIRM1 readme.txt
rm -f $FIRM
rm -f $FIRM1
rm -f readme.txt
cd ..

MOD="WRT1900AC-V2"
EXTB="-factory.img"
EXTB1="-upgrade.bin"

ORIG="openwrt-mvebu-cortexa9-linksys-wrt1900acv2-squashfs-factory.img"
ORIG1="openwrt-mvebu-cortexa9-linksys-wrt1900acv2-squashfs-sysupgrade.bin"
FIRM=$BASE$MOD$END$EXTB
FIRM1=$BASE$MOD$END$EXTB1
cp ./bin/targets/mvebu/cortexa9/$ORIG ./images/$FIRM
cp ./bin/targets/mvebu/cortexa9/$ORIG1 ./images/$FIRM1
cp ./configfiles/Generic/readme.txt ./images/readme.txt
cd ./images
zip -r $MOD$END.zip $FIRM $FIRM1 readme.txt
rm -f $FIRM
rm -f $FIRM1
rm -f readme.txt
cd ..

MOD="WRT1900AC-V1"
EXTB="-factory.img"
EXTB1="-upgrade.bin"

ORIG="openwrt-mvebu-cortexa9-linksys-wrt1900ac-squashfs-factory.img"
ORIG1="openwrt-mvebu-cortexa9-linksys-wrt1900ac-squashfs-sysupgrade.bin"
FIRM=$BASE$MOD$END$EXTB
FIRM1=$BASE$MOD$END$EXTB1
cp ./bin/targets/mvebu/cortexa9/$ORIG ./images/$FIRM
cp ./bin/targets/mvebu/cortexa9/$ORIG1 ./images/$FIRM1
cp ./configfiles/Generic/readme.txt ./images/readme.txt
cd ./images
zip -r $MOD$END.zip $FIRM $FIRM1 readme.txt
rm -f $FIRM
rm -f $FIRM1
rm -f readme.txt
cd ..

# 3200ACM

MOD="WRT3200ACM"
EXTB="-factory.img"
EXTB1="-upgrade.bin"

ORIG="openwrt-mvebu-cortexa9-linksys-wrt3200acm-squashfs-factory.img"
ORIG1="openwrt-mvebu-cortexa9-linksys-wrt3200acm-squashfs-sysupgrade.bin"
FIRM=$BASE$MOD$END$EXTB
FIRM1=$BASE$MOD$END$EXTB1
cp ./bin/targets/mvebu/cortexa9/$ORIG ./images/$FIRM
cp ./bin/targets/mvebu/cortexa9/$ORIG1 ./images/$FIRM1
cp ./configfiles/Generic/readme.txt ./images/readme.txt
cd ./images
zip -r $MOD$END.zip $FIRM $FIRM1 readme.txt
rm -f $FIRM
rm -f $FIRM1
rm -f readme.txt
cd ..

MOD="WRT32x"
EXTB="-factory.img"
EXTB1="-upgrade.bin"

ORIG="openwrt-mvebu-cortexa9-linksys-wrt32x-squashfs-factory.img"
ORIG1="openwrt-mvebu-cortexa9-linksys-wrt32x-squashfs-sysupgrade.bin"
FIRM=$BASE$MOD$END$EXTB
FIRM1=$BASE$MOD$END$EXTB1
cp ./bin/targets/mvebu/cortexa9/$ORIG ./images/$FIRM
cp ./bin/targets/mvebu/cortexa9/$ORIG1 ./images/$FIRM1
cp ./configfiles/Generic/readme.txt ./images/readme.txt
cd ./images
zip -r $MOD$END.zip $FIRM $FIRM1 readme.txt
rm -f $FIRM
rm -f $FIRM1
rm -f readme.txt
cd ..


# C2600

cp ./configfiles/16meg/.config_2600 ./.config
configfix
make -j5 V=s

MOD="C2600"
EXTB="-factory.bin"
EXTB1="-update.bin"

ORIG=openwrt-ipq806x-tplink_c2600-squashfs-factory.bin
FIRM=$BASE$MOD$END$EXTB
ORIG1=openwrt-ipq806x-tplink_c2600-squashfs-sysupgrade.bin
FIRM1=$BASE$MOD$END$EXTB1
cp ./bin/targets/ipq806x/generic/$ORIG ./images/$FIRM
cp ./bin/targets/ipq806x/generic/$ORIG1 ./images/$FIRM1
cp ./configfiles/Generic/readme.txt ./images/readme.txt
cd ./images
zip $MOD$END.zip $FIRM $FIRM1 readme.txt
rm -f $FIRM
rm -f $FIRM1
rm -f readme.txt
cd ..

# WG3526

cp ./configfiles/16meg/.config_3526 ./.config
configfix
make -j5 V=s

MOD="wg3526"
EXTB=".bin"

ORIG=openwrt-ramips-mt7621-zbt-wg3526-16M-squashfs-sysupgrade.bin
FIRM=$BASE$MOD$END-upgrade$EXTB
cp ./bin/targets/ramips/mt7621/$ORIG ./images/$FIRM
cd ./images
zip $MOD$END.zip $FIRM
rm -f $FIRM
cd ..

# wndr3700v4

cp ./configfiles/16meg/.config_3700v4 ./.config
configfix
make -j5 V=s
cp ./configfiles/16meg/.config_4300 ./.config
configfix
make -j5 V=s

MOD="wndr3700v4"
MOD1="wndr4300"
EXTB="-factory.img"
EXTU="-update.tar"

ORIG="openwrt-ar71xx-nand-wndr3700v4-ubi-factory.img "
ORIG1="openwrt-ar71xx-nand-wndr3700v4-squashfs-sysupgrade.tar"
FIRM=$BASE$MOD$END$EXTB
FIRM1=$BASE$MOD$END$EXTU
ORIG2="openwrt-ar71xx-nand-wndr4300-ubi-factory.img "
ORIG3="openwrt-ar71xx-nand-wndr4300-squashfs-sysupgrade.tar"
FIRM2=$BASE$MOD1$END$EXTB
FIRM3=$BASE$MOD1$END$EXTU
cp ./bin/targets/ar71xx/nand/$ORIG ./images/$FIRM
cp ./bin/targets/ar71xx/nand/$ORIG1 ./images/$FIRM1
cp ./bin/targets/ar71xx/nand/$ORIG2 ./images/$FIRM2
cp ./bin/targets/ar71xx/nand/$ORIG3 ./images/$FIRM3
cp ./configfiles/Generic/readme.txt ./images/readme.txt
cd ./images
zip -r $MOD$END.zip $FIRM $FIRM1 readme.txt
zip -r $MOD1$END.zip $FIRM2 $FIRM3 readme.txt
rm -f $FIRM
rm -f $FIRM1
rm -f $FIRM2
rm -f $FIRM3
rm -f readme.txt
cd ..

# wdr4900

cp ./configfiles/16meg/.config_4900 ./.config
configfix
make -j5 V=s

MOD="wdr4900-v1"
EXTB=".bin"

ORIG="openwrt-mpc85xx-generic-tl-wdr4900-v1-squashfs-factory.bin"
FIRM=$BASE$MOD$END$EXTB
cp ./bin/targets/mpc85xx/generic/$ORIG ./images/$FIRM
cd ./images
zip -r $MOD$END.zip $FIRM
rm -f $FIRM
cd ..

# R6220

cp ./configfiles/16meg/.config_6220 ./.config
configfix
make -j5 V=s

MOD="R6220"
EXTB=".tar"

ORIG=openwrt-ramips-mt7621-r6220-squashfs-sysupgrade.tar
FIRM=$BASE$MOD$END-upgrade$EXTB
ORIG1=openwrt-ramips-mt7621-r6220-squashfs-kernel.bin
FIRM1=kernel.bin
ORIG2=openwrt-ramips-mt7621-r6220-squashfs-rootfs.bin
FIRM2=rootfs.bin
cp ./bin/targets/ramips/mt7621/$ORIG ./images/$FIRM
cp ./bin/targets/ramips/mt7621/$ORIG1 ./images/$FIRM1
cp ./bin/targets/ramips/mt7621/$ORIG2 ./images/$FIRM2
cd ./images
zip $MOD$END.zip $FIRM $FIRM1 $FIRM2
rm -f $FIRM
rm -f $FIRM1
rm -f $FIRM2
cd ..

# MT7620-d240

cp ./configfiles/16meg/.config_d240 ./.config
configfix
make -j5 V=s

MOD="mt7620-d240"
EXTB=".bin"

ORIG=openwrt-ramips-mt7620-d240-squashfs-sysupgrade.bin
FIRM=$BASE$MOD$END-upgrade$EXTB
cp ./bin/targets/ramips/mt7620/$ORIG ./images/$FIRM
cd ./images
zip $MOD$END.zip $FIRM
rm -f $FIRM
cd ..

# EA8500
# R7800

cp ./configfiles/16meg/.config_8500 ./.config
configfix
make -j5 V=s
cp ./configfiles/16meg/.config_7800 ./.config
configfix
make -j5 V=s

MOD="ea8500"
EXTB="-factory.bin"
EXTB1="-update.bin"

ORIG=openwrt-ipq806x-linksys_ea8500-squashfs-factory.bin
FIRM=$BASE$MOD$END$EXTB
ORIG1=openwrt-ipq806x-linksys_ea8500-squashfs-sysupgrade.bin
FIRM1=$BASE$MOD$END$EXTB1
cp ./bin/targets/ipq806x/generic/$ORIG ./images/$FIRM
cp ./bin/targets/ipq806x/generic/$ORIG1 ./images/$FIRM1
cp ./configfiles/Generic/readme.txt ./images/readme.txt
cd ./images
zip $MOD$END.zip $FIRM $FIRM1 readme.txt
rm -f $FIRM
rm -f $FIRM1
rm -f readme.txt
cd ..

MOD="R7800"
EXTB="-factory.img"
EXTB1="-update.bin"

ORIG=openwrt-ipq806x-netgear_r7800-squashfs-factory.img
FIRM=$BASE$MOD$END$EXTB
ORIG1=openwrt-ipq806x-netgear_r7800-squashfs-sysupgrade.bin
FIRM1=$BASE$MOD$END$EXTB1
cp ./bin/targets/ipq806x/generic/$ORIG ./images/$FIRM
cp ./bin/targets/ipq806x/generic/$ORIG1 ./images/$FIRM1
cp ./configfiles/Generic/readme.txt ./images/readme.txt
cd ./images
zip $MOD$END.zip $FIRM $FIRM1 readme.txt
rm -f $FIRM
rm -f $FIRM1
rm -f readme.txt
cd ..

# R7500

cp ./configfiles/16meg/.config_7500 ./.config
configfix
make -j5 V=s

MOD="R7500"
EXTB="-factory.img"
EXTB1="-update.bin"

ORIG=openwrt-ipq806x-netgear_r7500-squashfs-factory.img
FIRM=$BASE$MOD$END$EXTB
ORIG1=openwrt-ipq806x-netgear_r7500-squashfs-sysupgrade.bin
FIRM1=$BASE$MOD$END$EXTB1
cp ./bin/targets/ipq806x/generic/$ORIG ./images/$FIRM
cp ./bin/targets/ipq806x/generic/$ORIG1 ./images/$FIRM1
cp ./configfiles/Generic/readme.txt ./images/readme.txt
cd ./images
zip $MOD$END.zip $FIRM $FIRM1 readme.txt
rm -f $FIRM
rm -f $FIRM1
rm -f readme.txt
cd ..


# RT-AC51U

cp ./configfiles/16meg/.config_ac51u ./.config
configfix
make -j5 V=s

MOD="rt-ac51u"
EXTB=".bin"

ORIG=openwrt-ramips-mt7620-rt-ac51u-squashfs-sysupgrade.bin
FIRM=$BASE$MOD$END-upgrade$EXTB
cp ./bin/targets/ramips/mt7620/$ORIG ./images/$FIRM
cd ./images
zip $MOD$END.zip $FIRM
rm -f $FIRM
cd ..

# APU2C4

cp ./configfiles/16meg/.config_apu2c4 ./.config
configfix
make -j5 V=s

MOD="APU2C4"

ORIG="openwrt-x86-64-combined-squashfs.img.gz"
ORIG1="openwrt-x86-64-combined-squashfs.img"
FIRM=$BASE$MOD$END.img
cp ./bin/targets/x86/64/$ORIG ./images/$ORIG
cd ./images
gunzip $ORIG
mv $ORIG1 $FIRM
zip -r $MOD$END.zip $FIRM
rm -f $FIRM
rm -f $ORIG
cd ..

# AR750

cp ./configfiles/16meg/.config_ar750 ./.config
configfix
make -j5 V=s

MOD="gl-ar750"
EXTB=".bin"

ORIG=$BASEQ$MOD$ENDU$EXTB
FIRM=$BASE$MOD$END$EXTB
cp ./bin/targets/ar71xx/generic/$ORIG ./images/$FIRM
cd ./images
zip $MOD$END.zip $FIRM
rm -f $FIRM
cd ..

# AR750S

cp ./configfiles/16meg/.config_750s ./.config
configfix
make -j5 V=s

MOD="gl-ar750s"
EXTB=".bin"

ORIG=$BASEQ$MOD$ENDU$EXTB
FIRM=$BASE$MOD$END$EXTB
cp ./bin/targets/ar71xx/generic/$ORIG ./images/$FIRM
cd ./images
zip $MOD$END.zip $FIRM
rm -f $FIRM
cd ..

# archer C5/C7

cp ./configfiles/16meg/.config_archerc5 ./.config
configfix
make -j5 V=s
cp ./configfiles/16meg/.config_archerc7v2 ./.config
configfix
make -j5 V=s
cp ./configfiles/16meg/.config_archerc7v2il ./.config
configfix
make -j5 V=s
cp ./configfiles/16meg/.config_archerc7v3 ./.config
configfix
make -j5 V=s

MOD="archer-c5-v1"
MOD3="archer-c7-v2"
MOD4="archer-c7-v2-il"
EXTB=".bin"

ORIG=$BASEQ$MOD$ENDO$EXTB
FIRM=$BASE$MOD$END$EXTB
ORIG3=$BASEQ$MOD3$ENDO$EXTB
FIRM3=$BASE$MOD3$END$EXTB
ORIG3a=$BASEQ$MOD3$ENDO"-eu"$EXTB
FIRM3a=$BASE$MOD3$END"-eu"$EXTB
ORIG3b=$BASEQ$MOD3$ENDO"-us"$EXTB
FIRM3b=$BASE$MOD3$END"-us"$EXTB
ORIG4=$BASEQ$MOD4$ENDO$EXTB
FIRM4=$BASE$MOD4$END$EXTB
cp ./bin/targets/ar71xx/generic/$ORIG ./images/$FIRM
cp ./bin/targets/ar71xx/generic/$ORIG3 ./images/$FIRM3
cp ./bin/targets/ar71xx/generic/$ORIG4 ./images/$FIRM4
mkdir ./images/method1
mkdir ./images/method2
cp ./bin/targets/ar71xx/generic/$ORIG3a ./images/method2/$FIRM3a
cp ./bin/targets/ar71xx/generic/$ORIG3b ./images/method2/$FIRM3b
cp ./configfiles/ARCHER/ArcherC7v2_en_3_14_3.bin ./images/method1/ArcherC7v2_en_3_14_3.bin
cp ./configfiles/ARCHER/Archer-C7-factory-to-ddwrt-US.bin ./images/method1/Archer-C7-factory-to-ddwrt-US.bin
cp ./configfiles/ARCHER/readme.txt ./images/method1/readme.txt
cp ./configfiles/ARCHER/readme1.txt ./images/readme.txt
cd ./images
zip $MOD$END.zip $FIRM
zip $MOD3$END.zip $FIRM3 readme.txt ./method1/ArcherC7v2_en_3_14_3.bin ./method1/Archer-C7-factory-to-ddwrt-US.bin ./method1/readme.txt ./method2/$FIRM3a ./method2/$FIRM3b
zip $MOD4$END.zip $FIRM4
rm -f $FIRM
rm -f $FIRM3
rm -f $FIRM4
rm -r method2
rm -r method1
rm -f readme.txt
cd ..

# mkarcherc7v4

cp ./configfiles/16meg/.config_archerc7v4 ./.config
configfix
make -j5 V=s

MOD="archer-c7-v4"
EXTB=".bin"

ORIG=$BASEQ$MOD$ENDO$EXTB
ORIG1=$BASEQ$MOD$ENDU$EXTB
FIRM=$BASE$MOD$END"-factory"$EXTB
FIRM1=$BASE$MOD$END"-upgrade"$EXTB
cp ./bin/targets/ar71xx/generic/$ORIG ./images/$FIRM
cp ./bin/targets/ar71xx/generic/$ORIG1 ./images/$FIRM1
cp ./configfiles/Generic/readme.txt ./images/readme.txt
cd ./images
zip $MOD$END.zip $FIRM $FIRM1 readme.txt
rm -f $FIRM
rm -f $FIRM1
rm -f readme.txt
cd ..

# Archer C7v5

cp ./configfiles/16meg/.config_archerc7v5 ./.config
configfix
make -j5 V=s

MOD="archer-c7-v5"
EXTB=".bin"

ORIG=$BASEQ$MOD$ENDO$EXTB
ORIG1=$BASEQ$MOD$ENDU$EXTB
FIRM=$BASE$MOD$END"-factory"$EXTB
FIRM1=$BASE$MOD$END"-upgrade"$EXTB
cp ./bin/targets/ar71xx/generic/$ORIG ./images/$FIRM
cp ./bin/targets/ar71xx/generic/$ORIG1 ./images/$FIRM1
cp ./configfiles/Generic/readme.txt ./images/readme.txt
cd ./images
zip $MOD$END.zip $FIRM $FIRM1 readme.txt
rm -f $FIRM
rm -f $FIRM1
rm -f readme.txt
cd ..

# mkb1300

cp ./configfiles/16meg/.config_b1300 ./.config
configfix
make -j5 V=s

MOD="GL-B1300"
EXTB=".bin"

ORIG=openwrt-ipq40xx-glinet_gl-b1300-squashfs-sysupgrade.bin
FIRM="openwrt-"$MOD$END-upgrade$EXTB
FIRM1="lede-gl-b1300.bin"
cp ./bin/targets/ipq40xx/generic/$ORIG ./images/$FIRM
cp ./bin/targets/ipq40xx/generic/$ORIG ./images/$FIRM1
cp ./configfiles/GL/readme.txt ./images/readme.txt
cd ./images
zip $MOD$END.zip $FIRM $FIRM1 readme.txt
rm -f $FIRM
rm -f $FIRM1
rm -f readme.txt
cd ..

# ea3500

cp ./configfiles/16meg/.config_ea3500 ./.config
configfix
make -j5 V=s

MOD="ea3500"
EXTB=".bin"
EXTB1=".tar"

ORIG="openwrt-kirkwood-linksys_audi-squashfs-factory.bin"
FIRM=$BASE$MOD$END"-factory"$EXTB
ORIG1="openwrt-kirkwood-linksys_audi-squashfs-sysupgrade.bin"
FIRM1=$BASE$MOD$END"-upgrade"$EXTB1
cp ./bin/targets/kirkwood/generic/$ORIG ./images/$FIRM
cp ./bin/targets/kirkwood/generic/$ORIG1 ./images/$FIRM1
cp ./configfiles/Generic/readme.txt ./images/readme.txt
cd ./images
zip -r $MOD$END.zip $FIRM $FIRM1 readme.txt
rm -f $FIRM
rm -f $FIRM1
rm -f readme.txt
cd ..

# ea4500

cp ./configfiles/16meg/.config_ea4500 ./.config
configfix
make -j5 V=s

MOD="ea4500"
MOD1="e4200-v2"
EXTB=".bin"
EXTB1=".bin"

ORIG="openwrt-kirkwood-linksys_viper-squashfs-factory.bin"
FIRM=$BASE$MOD$END"-factory"$EXTB
FIRM2=$BASE$MOD1$END"-factory"$EXTB
ORIG1="openwrt-kirkwood-linksys_viper-squashfs-sysupgrade.bin"
FIRM1=$BASE$MOD$END"-upgrade"$EXTB1
FIRM3=$BASE$MOD1$END"-upgrade"$EXTB1
cp ./bin/targets/kirkwood/generic/$ORIG ./images/$FIRM
cp ./bin/targets/kirkwood/generic/$ORIG1 ./images/$FIRM1
cp ./bin/targets/kirkwood/generic/$ORIG ./images/$FIRM2
cp ./bin/targets/kirkwood/generic/$ORIG1 ./images/$FIRM3
cp ./configfiles/Generic/readme.txt ./images/readme.txt
cd ./images
zip -r $MOD$END.zip $FIRM $FIRM1 readme.txt
zip -r $MOD1$END.zip $FIRM2 $FIRM3 readme.txt
rm -f $FIRM
rm -f $FIRM1
rm -f $FIRM2
rm -f $FIRM3
rm -f readme.txt
cd ..

# BT Home Hub 5A

cp ./configfiles/16meg/.config_hh5a ./.config
configfix
make -j5 V=s

MOD="HomeHub5A"
EXTB=".bin"

ORIG=openwrt-lantiq-xrx200-bt_homehub-v5a-squashfs-sysupgrade.bin
FIRM=$BASE$MOD$END$EXTB
cp ./bin/targets/lantiq/xrx200/$ORIG ./images/$FIRM
cd ./images
zip $MOD$END.zip $FIRM
rm -f $FIRM
cd ..

# Mikrotik

cp ./configfiles/16meg/.config_mikro ./.config
configfix
make -j5 V=s

MOD="mikrotik"
EXTB=".bin"

ORIG=openwrt-ar71xx-mikrotik-nand-large-squashfs-sysupgrade.bin
FIRM=$BASE$MOD$END"-squashfs-sysupgrade.bin"
ORIG1=openwrt-ar71xx-mikrotik-vmlinux-initramfs.elf
FIRM1=$BASE$MOD$END"-vmlinux-initramfs.elf"
cp ./bin/targets/ar71xx/mikrotik/$ORIG ./images/$FIRM
cp ./bin/targets/ar71xx/mikrotik/$ORIG1 ./images/$FIRM1
cd ./images
zip $MOD$END.zip $FIRM $FIRM1
rm -f $FIRM
rm -f $FIRM1
cd ..


cp ./configfiles/16meg/.config_multi16 ./.config
configfix
make -j5 V=s

# R36a

MOD3="r36a"
EXTB=".bin"

ORIG3=$BASEQ$MOD3$ENDU$EXTB
FIRM3=$BASE$MOD3$END$EXTB

cp ./bin/targets/ar71xx/generic/$ORIG3 ./images/$FIRM3
cd ./images
zip $MOD3$END.zip $FIRM3
rm -f $FIRM3
cd ..

# ar150

MOD="gl-ar150"
EXTB=".bin"

ORIG=$BASEQ$MOD$ENDU$EXTB
FIRM=$BASE$MOD$END$EXTB
cp ./bin/targets/ar71xx/generic/$ORIG ./images/$FIRM
cd ./images
zip $MOD$END.zip $FIRM
rm -f $FIRM
cd ..

# ar300-16

MOD="gl-ar300m"
EXTB=".bin"

ORIG=$BASEQ$MOD$ENDU$EXTB
FIRM=$BASE$MOD-16$END$EXTB
cp ./bin/targets/ar71xx/generic/$ORIG ./images/$FIRM
cd ./images
zip $MOD-16$END.zip $FIRM
rm -f $FIRM
cd ..


# domino pi

MOD="gl-domino"
EXTB=".bin"

ORIG=$BASEQ$MOD$ENDU$EXTB
FIRM=$BASE$MOD$END$EXTB
cp ./bin/targets/ar71xx/generic/$ORIG ./images/$FIRM
cd ./images
zip $MOD$END.zip $FIRM
rm -f $FIRM
cd ..

# Gl.iNet 6416

MOD="gl-inet-6416A-v1"
EXTB=".bin"

ORIG=$BASEQ$MOD$ENDO$EXTB
FIRM=$BASE$MOD$END$EXTB
cp ./bin/targets/ar71xx/generic/$ORIG ./images/$FIRM
cp ./configfiles/GL/readme.txt ./images/readme.txt
cd ./images
zip $MOD$END.zip $FIRM readme.txt
rm -f $FIRM
rm -f readme.txt
cd ..

# GL-Mifi

MOD="gl-mifi"
EXTB=".bin"

ORIG=$BASEQ$MOD$ENDU$EXTB
FIRM=$BASE$MOD$END-upgrade$EXTB
cp ./bin/targets/ar71xx/generic/$ORIG ./images/$FIRM
cp ./configfiles/GL/readme.txt ./images/readme.txt
cd ./images
zip $MOD$END.zip $FIRM readme.txt
rm -f $FIRM
rm -f readme.txt
cd ..

# wr1043n

MOD3="wr1043n-v5"
MOD4="wr1043nd-v4"
EXTB=".bin"

ORIG3=$BASEO$MOD3$ENDO$EXTB
FIRM3=$BASE$MOD3$END-factory$EXTB
ORIG3a=$BASEO$MOD3$ENDO$EXTB
FIRM3a=$BASE$MOD3$END-upgrade$EXTB
ORIG4=$BASEO$MOD4$ENDO$EXTB
FIRM4=$BASE$MOD4$END-factory$EXTB
ORIG4a=$BASEO$MOD4$ENDU$EXTB
FIRM4a=$BASE$MOD4$END-upgrade$EXTB
cp ./bin/targets/ar71xx/generic/$ORIG3 ./images/$FIRM3
cp ./bin/targets/ar71xx/generic/$ORIG3a ./images/$FIRM3a
cp ./bin/targets/ar71xx/generic/$ORIG4 ./images/$FIRM4
cp ./bin/targets/ar71xx/generic/$ORIG4a ./images/$FIRM4a
cp ./configfiles/Generic/readme.txt ./images/readme.txt
cd ./images
zip $MOD3$END.zip $FIRM3 $FIRM3a readme.txt
zip $MOD4$END.zip $FIRM4 $FIRM4a readme.txt
rm -f $FIRM3
rm -f $FIRM3a
rm -f $FIRM4
rm -f $FIRM4a
rm -f readme.txt
cd ..

# wr842nv3

MOD="wr842n-v3"
EXTB=".bin"

ORIG=$BASEO$MOD$ENDO$EXTB
FIRM=$BASE$MOD$END$EXTB
cp ./bin/targets/ar71xx/generic/$ORIG ./images/$FIRM
cd ./images
zip $MOD$END.zip $FIRM
rm -f $FIRM
cd ..

# dir-825 c1

MOD="dir-825-c1"
EXTB=".bin"

ORIG=$BASEQ$MOD$ENDO$EXTB
FIRM=$BASE$MOD$END$EXTB
cp ./bin/targets/ar71xx/generic/$ORIG ./images/$FIRM
cd ./images
zip $MOD$END.zip $FIRM
rm -f $FIRM
cd ..

# dir-835 a1

MOD="dir-835-a1"
EXTB=".bin"

ORIG=$BASEQ$MOD$ENDO$EXTB
FIRM=$BASE$MOD$END$EXTB
cp ./bin/targets/ar71xx/generic/$ORIG ./images/$FIRM
cd ./images
zip $MOD$END.zip $FIRM
rm -f $FIRM
cd ..

# wndr3700/3800/mac

MOD="wndr3700"
MOD2="wndr3700v2"
MOD3="wndr3800"
MOD4="wndrmac"
MOD5="wndrmacv2"
MOD6="wndr3800ch"
EXTB=".img"
EXTU="-update.bin"
EXTX=".bin"

ORIG=$BASEQ$MOD$ENDO$EXTB
FIRM=$BASE$MOD$END$EXTB
ORIG2=$BASEQ$MOD2$ENDO$EXTB
FIRM2=$BASE$MOD2$END$EXTB
ORIG3=$BASEQ$MOD3$ENDO$EXTB
FIRM3=$BASE$MOD3$END$EXTB
ORIG4=$BASEQ$MOD4$ENDO$EXTB
FIRM4=$BASE$MOD4$END$EXTB
ORIG5=$BASEQ$MOD5$ENDO$EXTB
FIRM5=$BASE$MOD5$END$EXTB
ORIG6=$BASEQ$MOD6$ENDO$EXTB
FIRM6=$BASE$MOD6$END$EXTB
ORIGU=$BASEQ$MOD$ENDU$EXTX
FIRMU=$BASE$MOD$END$EXTU
ORIGU2=$BASEQ$MOD2$ENDU$EXTX
FIRMU2=$BASE$MOD2$END$EXTU
ORIGU3=$BASEQ$MOD3$ENDU$EXTX
FIRMU3=$BASE$MOD3$END$EXTU
ORIGU4=$BASEQ$MOD4$ENDU$EXTX
FIRMU4=$BASE$MOD4$END$EXTU
ORIGU5=$BASEQ$MOD5$ENDU$EXTX
FIRMU5=$BASE$MOD5$END$EXTU
ORIGU6=$BASEQ$MOD6$ENDU$EXTX
FIRMU6=$BASE$MOD6$END$EXTU
cp ./bin/targets/ar71xx/generic/$ORIG2 ./images/$FIRM2
cp ./bin/targets/ar71xx/generic/$ORIG3 ./images/$FIRM3
cp ./bin/targets/ar71xx/generic/$ORIG4 ./images/$FIRM4
cp ./bin/targets/ar71xx/generic/$ORIG5 ./images/$FIRM5
cp ./bin/targets/ar71xx/generic/$ORIG6 ./images/$FIRM6
cp ./bin/targets/ar71xx/generic/$ORIGU2 ./images/$FIRMU2
cp ./bin/targets/ar71xx/generic/$ORIGU3 ./images/$FIRMU3
cp ./bin/targets/ar71xx/generic/$ORIGU4 ./images/$FIRMU4
cp ./bin/targets/ar71xx/generic/$ORIGU5 ./images/$FIRMU5
cp ./bin/targets/ar71xx/generic/$ORIGU6 ./images/$FIRMU6
cp ./configfiles/WNDR3700/SpecialFlashingInstructions.pdf ./images/SpecialFlashingInstructions.pdf
cd ./images

zip -r $MOD2$END.zip $FIRM2 $FIRMU2 SpecialFlashingInstructions.pdf
zip -r $MOD3$END.zip $FIRM3 $FIRMU3 SpecialFlashingInstructions.pdf
zip -r $MOD4$END.zip $FIRM4 $FIRMU4 SpecialFlashingInstructions.pdf
zip -r $MOD5$END.zip $FIRM5 $FIRMU5 SpecialFlashingInstructions.pdf
zip -r $MOD6$END.zip $FIRM6 $FIRMU6 SpecialFlashingInstructions.pdf
rm -f $FIRM2
rm -f $FIRM3
rm -f $FIRM4
rm -f $FIRM5
rm -f $FIRM6
rm -f $FIRMU2
rm -f $FIRMU3
rm -f $FIRMU4
rm -f $FIRMU5
rm -f $FIRMU6
rm -f SpecialFlashingInstructions.pdf
cd ..

# mynet N600

MOD="mynet-n600"
EXTB=".bin"

ORIG=$BASEQ$MOD$ENDO$EXTB
ORIG1=$BASEQ$MOD$ENDU$EXTB
FIRM=$BASE$MOD$END"-factory"$EXTB
FIRM1=$BASE$MOD$END"-upgrade"$EXTB
cp ./bin/targets/ar71xx/generic/$ORIG ./images/$FIRM
cp ./bin/targets/ar71xx/generic/$ORIG1 ./images/$FIRM1
cp ./configfiles/Generic/readme.txt ./images/readme.txt
cp ./configfiles/MyNet/Flashing_a_WD_Mynet_Router.pdf ./images/Flashing_a_WD_Mynet_Router.pdf
cd ./images
zip $MOD$END.zip $FIRM $FIRM1 readme.txt Flashing_a_WD_Mynet_Router.pdf
rm -f $FIRM
rm -f $FIRM1
rm -f readme.txt
rm -f Flashing_a_WD_Mynet_Router.pdf
cd ..

# mynet N750

MOD="mynet-n750"
EXTB=".bin"

ORIG=$BASEQ$MOD$ENDO$EXTB
ORIG1=$BASEQ$MOD$ENDU$EXTB
FIRM=$BASE$MOD$END"-factory"$EXTB
FIRM1=$BASE$MOD$END"-upgrade"$EXTB
cp ./bin/targets/ar71xx/generic/$ORIG ./images/$FIRM
cp ./bin/targets/ar71xx/generic/$ORIG1 ./images/$FIRM1
cp ./configfiles/Generic/readme.txt ./images/readme.txt
cp ./configfiles/MyNet/Flashing_a_WD_Mynet_Router.pdf ./images/Flashing_a_WD_Mynet_Router.pdf
cd ./images
zip $MOD$END.zip $FIRM $FIRM1 readme.txt Flashing_a_WD_Mynet_Router.pdf
rm -f $FIRM
rm -f $FIRM1
rm -f readme.txt
rm -f Flashing_a_WD_Mynet_Router.pdf
cd ..

# WZR-HP-G300NH

MOD="wzr-hp-g300nh"
EXTB=".bin"

ORIG=$BASEQ$MOD$ENDO$EXTB
ORIG1=$BASEQ$MOD$ENDU$EXTB
FIRM=$BASE$MOD$END"-factory"$EXTB
FIRM1=$BASE$MOD$END"-update"$EXTB
cp ./bin/targets/ar71xx/generic/$ORIG ./images/$FIRM
cp ./bin/targets/ar71xx/generic/$ORIG1 ./images/$FIRM1
cp ./configfiles/Generic/readme.txt ./images/readme.txt
cd ./images
zip $MOD$END.zip $FIRM $FIRM1 readme.txt
rm -f $FIRM
rm -f $FIRM1
rm -f readme.txt
cd ..

# WZR-HP-AG300H

MOD="wzr-hp-ag300h"
EXTB=".bin"

ORIG=$BASEQ$MOD$ENDO$EXTB
ORIG1=$BASEQ$MOD$ENDU$EXTB
FIRM=$BASE$MOD$END"-factory"$EXTB
FIRM1=$BASE$MOD$END"-update"$EXTB
cp ./bin/targets/ar71xx/generic/$ORIG ./images/$FIRM
cp ./bin/targets/ar71xx/generic/$ORIG1 ./images/$FIRM1
cp ./configfiles/Generic/readme.txt ./images/readme.txt
cd ./images
zip $MOD$END.zip $FIRM $FIRM1 readme.txt
rm -f $FIRM
rm -f $FIRM1
rm -f readme.txt
cd ..

# DGL-5500

MOD="dgl-5500-a1"
EXTB=".bin"

ORIG=$BASEQ$MOD$ENDO$EXTB
FIRM=$BASE$MOD$END$EXTB
cp ./bin/targets/ar71xx/generic/$ORIG ./images/$FIRM
cd ./images
zip $MOD$END.zip $FIRM
rm -f $FIRM
cd ..

# Turris Omnia

cp ./configfiles/16meg/.config_omnia ./.config
configfix
make -j5 V=s

MOD="turris-omnia"
EXTB=".bin"

ORIG1="openwrt-mvebu-cortexa9-turris-omnia-sysupgrade.img.gz"
FIRM1=$BASE$MOD$END-upgrade.img.gz
ORIG2="omnia-medkit-openwrt-mvebu-cortexa9-turris-omnia-initramfs.tar.gz"
FIRM2="omnia-medkit-$END.tar.gz"
cp ./bin/targets/mvebu/cortexa9/$ORIG1 ./images/$FIRM1
cp ./bin/targets/mvebu/cortexa9/$ORIG2 ./images/$FIRM2
cp ./configfiles/Omnia/readme.txt ./images/readme.txt
cd ./images
zip $MOD$END.zip $FIRM1 $FIRM2 readme.txt
rm -f $FIRM1
rm -f $FIRM2
rm -f readme.txt
cd ..

# Orange Pi Zero Plus

cp ./configfiles/16meg/.config_opi0 ./.config
configfix
make -j5 V=s

MOD1="OrangePiZeroPlus"
EXTB1=".img"

ORIG1="openwrt-sunxi-cortexa53-sun50i-h5-orangepi-zero-plus-ext4-sdcard.img.gz"
ORIG2="openwrt-sunxi-cortexa53-sun50i-h5-orangepi-zero-plus-ext4-sdcard.img"
FIRM1=$BASE$MOD1$END-factory$EXTB1

cp ./bin/targets/sunxi/cortexa53/$ORIG1 ./images/$ORIG1
cd ./images
gunzip $ORIG1
mv $ORIG2 $FIRM1
zip -r $MOD1$END.zip $FIRM1
rm -f $FIRM1
cd ..

# RBM11G

cp ./configfiles/16meg/.config_rbm11 ./.config
configfix
make -j5 V=s

MOD="RBM11G"
EXTB=".bin"

ORIG=openwrt-ramips-mt7621-mikrotik_rbm11g-initramfs-kernel.bin
FIRM=$BASE$MOD$END-factory$EXTB
ORIG1=openwrt-ramips-mt7621-mikrotik_rbm11g-squashfs-sysupgrade.bin
FIRM1=$BASE$MOD$END-upgrade$EXTB
cp ./bin/targets/ramips/mt7621/$ORIG ./images/$FIRM
cp ./bin/targets/ramips/mt7621/$ORIG1 ./images/$FIRM1
cp ./configfiles/Generic/readme.txt ./images/readme.txt
cd ./images
zip $MOD$END.zip $FIRM $FIRM1 readme.txt
rm -f $FIRM
rm -f $FIRM1
rm -f readme.txt
cd ..

# RBM33G

cp ./configfiles/16meg/.config_rbm33 ./.config
configfix
make -j5 V=s

MOD="RBM33G"
EXTB=".bin"

ORIG=openwrt-ramips-mt7621-mikrotik_rbm33g-initramfs-kernel.bin
FIRM=$BASE$MOD$END-factory$EXTB
ORIG1=openwrt-ramips-mt7621-mikrotik_rbm33g-squashfs-sysupgrade.bin
FIRM1=$BASE$MOD$END-upgrade$EXTB
cp ./bin/targets/ramips/mt7621/$ORIG ./images/$FIRM
cp ./bin/targets/ramips/mt7621/$ORIG1 ./images/$FIRM1
cp ./configfiles/RBM33G/flash-rbm33.pdf ./images/flash-rbm33.pdf
cp ./configfiles/RBM33G/tftpd32.chm ./images/tftpd32.chm
cp ./configfiles/RBM33G/tftpd32.exe ./images/tftpd32.exe
cp ./configfiles/RBM33G/tftpd32.ini ./images/tftpd32.ini
cd ./images
zip $MOD$END-19074.zip $FIRM $FIRM1 flash-rbm33.pdf tftpd32.chm tftpd32.exe tftpd32.ini
rm -f $FIRM
rm -f $FIRM1
rm -f flash-rbm33.pdf
rm -f tftpd32.chm
rm -f tftpd32.exe
rm -f tftpd32.ini
cd ..

# Raspberry Pi

cp ./configfiles/16meg/.config_rpi ./.config
configfix
make -j5 V=s
cp ./configfiles/16meg/.config_rpi2 ./.config
configfix
make -j5 V=s
cp ./configfiles/16meg/.config_rpi3 ./.config
configfix
make -j5 V=s

MOD1="RaspberryPi"
EXTB1=".img"

ORIG1="openwrt-brcm2708-bcm2708-rpi-ext4-factory.img.gz"
ORIG2="openwrt-brcm2708-bcm2708-rpi-ext4-factory.img"
FIRM1=$BASE$MOD1$END$EXTB1

cp ./bin/targets/brcm2708/bcm2708/$ORIG1 ./images/$ORIG1
cd ./images
gunzip $ORIG1
mv $ORIG2 $FIRM1
zip -r $MOD1$END.zip $FIRM1
rm -f $FIRM1
cd ..

# Raspberry Pi2

MOD1="RaspberryPi2"
EXTB1=".img"

ORIG1="openwrt-brcm2708-bcm2709-rpi-2-ext4-factory.img.gz"
ORIG2="openwrt-brcm2708-bcm2709-rpi-2-ext4-factory.img"
FIRM1=$BASE$MOD1$END$EXTB1

cp ./bin/targets/brcm2708/bcm2709/$ORIG1 ./images/$ORIG1
cd ./images
gunzip $ORIG1
mv $ORIG2 $FIRM1
zip -r $MOD1$END.zip $FIRM1
rm -f $FIRM1
cd ..

# Raspberry Pi3

MOD1="RaspberryPi3"
EXTB1=".img"

ORIG1="openwrt-brcm2708-bcm2710-rpi-3-ext4-factory.img.gz"
ORIG2="openwrt-brcm2708-bcm2710-rpi-3-ext4-factory.img"
FIRM1=$BASE$MOD1$END$EXTB1

cp ./bin/targets/brcm2708/bcm2710/$ORIG1 ./images/$ORIG1
cd ./images
gunzip $ORIG1
mv $ORIG2 $FIRM1
zip -r $MOD1$END.zip $FIRM1
rm -f $FIRM1
cd ..

# U7621-06

cp ./configfiles/16meg/.config_u7621 ./.config
configfix
make -j5 V=s

MOD="U7621-06"
EXTB=".bin"

ORIG=openwrt-ramips-mt7621-u7621-06-256M-16M-squashfs-sysupgrade.bin
FIRM=$BASE$MOD$END-upgrade$EXTB
cp ./bin/targets/ramips/mt7621/$ORIG ./images/$FIRM
cd ./images
zip $MOD$END.zip $FIRM
rm -f $FIRM
cd ..

# U7628-01

cp ./configfiles/16meg/.config_u7628 ./.config
configfix
make -j5 V=s

MOD="U7628-01"
EXTB=".bin"

ORIG=openwrt-ramips-mt76x8-u7628-01-128M-16M-squashfs-sysupgrade.bin
FIRM=$BASE$MOD$END-upgrade$EXTB
cp ./bin/targets/ramips/mt76x8/$ORIG ./images/$FIRM
cd ./images
zip $MOD$END.zip $FIRM
rm -f $FIRM
cd ..

# WE3526

cp ./configfiles/16meg/.config_we3526 ./.config
configfix
make -j5 V=s

MOD="we3526"
EXTB=".bin"

ORIG=openwrt-ramips-mt7621-zbtlink_zbt-we3526-squashfs-sysupgrade.bin
FIRM=$BASE$MOD$END-upgrade$EXTB
cp ./bin/targets/ramips/mt7621/$ORIG ./images/$FIRM
cd ./images
zip $MOD$END.zip $FIRM
rm -f $FIRM
cd ..

# WE1026-5G

cp ./configfiles/16meg/.config_we1026 ./.config
configfix
make -j5 V=s

MOD="we1026-5G"
EXTB=".bin"

ORIG=openwrt-ramips-mt7620-we1026-5g-16m-squashfs-sysupgrade.bin
FIRM=$BASE$MOD$END-upgrade$EXTB
cp ./bin/targets/ramips/mt7620/$ORIG ./images/$FIRM
cd ./images
zip $MOD$END.zip $FIRM
rm -f $FIRM
cd ..

# WE1326

cp ./configfiles/16meg/.config_we1326 ./.config
configfix
make -j5 V=s

MOD="we1326"
EXTB=".bin"

ORIG=openwrt-ramips-mt7621-zbt-we1326-squashfs-sysupgrade.bin
FIRM=$BASE$MOD$END-upgrade$EXTB
cp ./bin/targets/ramips/mt7621/$ORIG ./images/$FIRM
cd ./images
zip $MOD$END.zip $FIRM
rm -f $FIRM
cd ..

cp ./configfiles/16meg/.config_we1326 ./.config
configfix
make -j5 V=s

# WE1326v5

MOD="we1326v5"
EXTB=".bin"

ORIG=openwrt-ramips-mt7621-zbt-we1326-squashfs-sysupgrade.bin
FIRM=$BASE$MOD$END-upgrade$EXTB
cp ./bin/targets/ramips/mt7621/$ORIG ./images/$FIRM
cd ./images
zip $MOD$END.zip $FIRM
rm -f $FIRM
cd ..

# x86

cp ./configfiles/16meg/.config_x86 ./.config
configfix
make -j5 V=s

MOD="x86-64bit"

ORIG="openwrt-x86-64-combined-ext4.img.gz"
ORIG1="openwrt-x86-64-combined-ext4.img"
FIRM=$BASE$MOD$END.img
ORIG2="openwrt-x86-64-combined-ext4.vdi"
FIRM2=$BASE$MOD$END.vdi
ORIG3="openwrt-x86-64-combined-ext4.vmdk"
FIRM3=$BASE$MOD$END.vmdk
cp ./bin/targets/x86/64/$ORIG ./images/$ORIG
cp ./bin/targets/x86/64/$ORIG2 ./images/$FIRM2
cp ./bin/targets/x86/64/$ORIG3 ./images/$FIRM3
cd ./images
gunzip $ORIG
mv $ORIG1 $FIRM
zip -r $MOD$END.zip $FIRM $FIRM2 $FIRM3
rm -f $FIRM
rm -f $FIRM2
rm -f $FIRM3
rm -f $ORIG
cd ..

# Xiaomi Mini

cp ./configfiles/16meg/.config_xiaomi ./.config
configfix
make -j5 V=s

MOD1="xiaomi-miwifi-mini"
EXTB=".bin"

ORIG4="openwrt-ramips-mt7620-miwifi-mini-squashfs-sysupgrade.bin"
FIRM4=$BASE$MOD1$END"-upgrade"$EXTB
cp ./bin/targets/ramips/mt7620/$ORIG4 ./images/$FIRM4
cp ./configfiles/Xiaomi/miwifi.bin ./images/miwifi.bin
cp ./configfiles/Xiaomi/putty.exe ./images/putty.exe
cp ./configfiles/Xiaomi/url.txt ./images/url.txt
cp ./configfiles/Xiaomi/xiaomi.pdf ./images/xiaomi.pdf
cd ./images
zip $MOD1$END.zip $FIRM4 miwifi.bin putty.exe url.txt xiaomi.pdf
rm -f $FIRM4
rm -f xiaomi.pdf
rm -f miwifi.bin
rm -f url.txt
rm -f putty.exe
cd ..

# Xiaomi Mini 3G

cp ./configfiles/16meg/.config_xiaomi3g ./.config
configfix
make -j5 V=s

MOD="Xiaomi-mifi3G"
EXTB=".tar"

ORIG=openwrt-ramips-mt7621-mir3g-squashfs-kernel1.bin
FIRM=kernel1.bin
ORIG1=openwrt-ramips-mt7621-mir3g-squashfs-rootfs0.bin
FIRM1=rootfs0.bin
ORIG2=openwrt-ramips-mt7621-mir3g-squashfs-sysupgrade.tar
FIRM2=$BASE$MOD$END-upgrade$EXTB
cp ./bin/targets/ramips/mt7621/$ORIG ./images/$FIRM
cp ./bin/targets/ramips/mt7621/$ORIG1 ./images/$FIRM1
cp ./bin/targets/ramips/mt7621/$ORIG2 ./images/$FIRM2
cp ./configfiles/xiaomi3g/xiaomi.pdf ./images/xiaomi.pdf
cp ./configfiles/xiaomi3g/putty.exe ./images/putty.exe 
cp ./configfiles/xiaomi3g/miwifi_r3g_firmware_c2175_2.25.122.bin ./images/miwifi_r3g_firmware_c2175_2.25.122.bin 
cd ./images
zip $MOD$END.zip $FIRM $FIRM1 $FIRM2 xiaomi.pdf putty.exe miwifi_r3g_firmware_c2175_2.25.122.bin
rm -f $FIRM
rm -f $FIRM1
rm -f $FIRM2
rm -f xiaomi.pdf
rm -f putty.exe 
rm -f miwifi_r3g_firmware_c2175_2.25.122.bin
cd ..

# Y1

cp ./configfiles/16meg/.config_y1 ./.config
configfix
make -j5 V=s

MOD="lenovo-y1"
EXTB=".bin"

ORIG=openwrt-ramips-mt7620-y1-squashfs-sysupgrade.bin
FIRM=$BASE$MOD$END"-upgrade"$EXTB
cp ./bin/targets/ramips/mt7620/$ORIG ./images/$FIRM
cd ./images
zip $MOD$END.zip $FIRM
rm -f $FIRM
cd ..

# Y1s

cp ./configfiles/16meg/.config_y1s ./.config
configfix
make -j5 V=s

MOD="lenovo-y1s"
EXTB=".bin"

ORIG=openwrt-ramips-mt7620-y1s-squashfs-sysupgrade.bin
FIRM=$BASE$MOD$END"-upgrade"$EXTB
cp ./bin/targets/ramips/mt7620/$ORIG ./images/$FIRM
cd ./images
zip $MOD$END.zip $FIRM
rm -f $FIRM
cd ..

# DHP-1565

cp ./configfiles/16meg/.config_1565 ./.config
configfix
make -j5 V=s

MOD="dhp-1565-a1"
EXTB=".bin"

ORIG=$BASEQ$MOD$ENDO$EXTB
ORIG1=$BASEQ$MOD$ENDU$EXTB
FIRM=$BASE$MOD$END"-factory"$EXTB
FIRM1=$BASE$MOD$END"-upgrade"$EXTB
cp ./bin/targets/ar71xx/generic/$ORIG ./images/$FIRM
cp ./bin/targets/ar71xx/generic/$ORIG1 ./images/$FIRM1
cp ./configfiles/Generic/readme.txt ./images/readme.txt
cd ./images
zip $MOD$END.zip $FIRM $FIRM1 readme.txt
rm -f $FIRM
rm -f $FIRM1
rm -f readme.txt
cd ..

# NanoPi Neo Plus 2

cp ./configfiles/16meg/.config_nanopi ./.config
configfix
make -j5 V=s

MOD1="NanoPi-Neo-Plus2"
EXTB1=".img"

ORIG1="openwrt-sunxi-cortexa53-sun50i-h5-nanopi-neo-plus2-ext4-sdcard.img.gz"
ORIG2="openwrt-sunxi-cortexa53-sun50i-h5-nanopi-neo-plus2-ext4-sdcard.img"
FIRM1=$BASE$MOD1$END$EXTB1

cp ./bin/targets/sunxi/cortexa53/$ORIG1 ./images/$ORIG1
cd ./images
gunzip $ORIG1
mv $ORIG2 $FIRM1
zip -r $MOD1$END.zip $FIRM1
rm -f $FIRM1
cd ..


# Buffalo WZR-600DHP

cp ./configfiles/16meg/.config_wzr600 ./.config
configfix
make -j5 V=s

MOD="wzr-600dhp"
EXTB="-factory.bin"
EXTB1="-update.bin"

ORIG="openwrt-ar71xx-generic-wzr-600dhp-squashfs-factory.bin"
ORIG1="openwrt-ar71xx-generic-wzr-600dhp-squashfs-sysupgrade.bin"
FIRM=$BASE$MOD$END$EXTB
FIRM1=$BASE$MOD$END$EXTB1
cp ./bin/targets/ar71xx/generic/$ORIG ./images/$FIRM
cp ./bin/targets/ar71xx/generic/$ORIG1 ./images/$FIRM1
cp ./configfiles/Generic/readme.txt ./images/readme.txt
cd ./images
zip -r $MOD$END.zip $FIRM $FIRM1 readme.txt
rm -f $FIRM
rm -f $FIRM1
rm -f readme.txt
cd ..

# WR703N-16

cp ./configfiles/16meg/.config_703 ./.config
configfix
make -j5 V=s

MOD="WR703N-16M"
EXTB=".bin"

ORIG=openwrt-ar71xx-tiny-tl-wr703n-v1-squashfs-sysupgrade.bin
FIRM=$BASE$MOD$END-upgrade$EXTB
cp ./bin/targets/ar71xx/tiny/$ORIG ./images/$FIRM
cd ./images
zip $MOD$END.zip $FIRM
rm -f $FIRM
cd ..

# Tp-Link C9v1

MOD="C9v1"
EXTB=".bin"

cp ./configfiles/16meg/.config_c9 ./.config
configfix
make -j5 V=s

ORIG="openwrt-bcm53xx-tplink-archer-c9-v1-squashfs.bin"
FIRM=$BASE$MOD$END$EXTB
cp ./bin/targets/bcm53xx/generic/$ORIG ./images/$FIRM
cd ./images
zip -r $MOD$END.zip $FIRM 
rm -f $FIRM
cd ..

# Youhua WR1200JS

MOD="wr1200js"
EXTB=".bin"

cp ./configfiles/16meg/.config_1200js ./.config
configfix
make -j5 V=s

ORIG="openwrt-ramips-mt7621-youhua_wr1200js-squashfs-sysupgrade.bin"
FIRM=$BASE$MOD$END-upgrade$EXTB
ORIG1="openwrt-ramips-mt7621-youhua_wr1200js-initramfs-kernel.bin"
FIRM1=$BASE$MOD$END-factory$EXTB
cp ./bin/targets/ramips/mt7621/$ORIG ./images/$FIRM
cp ./bin/targets/ramips/mt7621/$ORIG1 ./images/$FIRM1
cd ./images
zip -r $MOD$END.zip $FIRM $FIRM1
rm -f $FIRM
rm -f $FIRM1
cd ..

# WE826-Q

MOD="WE826-Q"
EXTB=".bin"

cp ./configfiles/16meg/.config_826q ./.config
configfix
make -j5 V=s

ORIG=openwrt-ar71xx-generic-ap147-010-squashfs-sysupgrade.bin
FIRM=$BASE$MOD$END$EXTB
cp ./bin/targets/ar71xx/generic/$ORIG ./images/$FIRM
cd ./images
zip -r $MOD$END.zip $FIRM 
rm -f $FIRM
cd ..

# Alfa Tube-E4G

MOD="Tube-E4G"
EXTB=".bin"

cp ./configfiles/16meg/.config_tube ./.config
configfix
make -j5 V=s

ORIG=openwrt-ramips-mt7620-alfa-network_tube-e4g-squashfs-sysupgrade.bin
FIRM=$BASE$MOD$END-upgrade$EXTB
cp ./bin/targets/ramips/mt7620/$ORIG ./images/$FIRM
cd ./images
zip $MOD$END.zip $FIRM
rm -f $FIRM
cd ..

# Archer A7v5

cp ./configfiles/16meg/.config_archera7v5 ./.config
configfix
make V=s

MOD="archer-a7-v5"
EXTB=".bin"

ORIG=openwrt-ath79-generic-tplink_archer-a7-v5-squashfs-factory.bin
ORIG1=openwrt-ath79-generic-tplink_archer-a7-v5-squashfs-sysupgrade.bin
FIRM=$BASE$MOD$END"-factory"$EXTB
FIRM1=$BASE$MOD$END"-upgrade"$EXTB
cp ./bin/targets/ath79/generic/$ORIG ./images/$FIRM
cp ./bin/targets/ath79/generic/$ORIG1 ./images/$FIRM1
cp ./configfiles/Generic/readme.txt ./images/readme.txt
cd ./images
zip $MOD$END-19074.zip $FIRM $FIRM1 readme.txt
rm -f $FIRM
rm -f $FIRM1
rm -f readme.txt
cd ..

# WG1608

echo "ZBT WG1608" > ./files/etc/custom
echo "ZBT WG1608" >> ./files/etc/custom
echo "ROOter" >> ./files/etc/custom
cp ./configfiles/16meg/.config_3526 ./.config
configfix
make -j5 V=s

MOD="WG1608"
EXTB=".bin"

ORIG=openwrt-ramips-mt7621-zbt-wg3526-16M-squashfs-sysupgrade.bin
FIRM=$BASE$MOD$END-upgrade$EXTB
cp ./bin/targets/ramips/mt7621/$ORIG ./images/$FIRM
cd ./images
zip $MOD$END.zip $FIRM
rm -f $FIRM
cd ..cp ./configfiles/16meg/.config_x750 ./.config
configfix
make V=s

MOD="Gl-X750"
EXTB=".bin"

ORIG=openwrt-ath79-generic-glinet_gl-x750-squashfs-sysupgrade.bin
FIRM=$BASE$MOD$END$EXTB
cp ./bin/targets/ath79/generic/$ORIG ./images/$FIRM
cd ./images
zip $MOD$END-19074.zip $FIRM
rm -f $FIRM
cd ..


# GL-X750

