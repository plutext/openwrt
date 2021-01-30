#!/bin/sh

ROOTER=/usr/lib/rooter

log() {
	logger -t "Band Mask" "$@"
}

#
# remove for band locking
#
exit 0

rm -f /tmp/bmask
CURRMODEM=$(uci get modem.general.miscnum)
uVid=$(uci get modem.modem$CURRMODEM.uVid)
uPid=$(uci get modem.modem$CURRMODEM.uPid)
model=$(uci get modem.modem$CURRMODEM.model)
L1=$(uci get modem.modem$CURRMODEM.L1)

if [ ! $L1 ]; then
	exit 0
fi

CA3=""
case $uVid in
	"2c7c" )
		case $uPid in
			"0125" ) # EC25-A
				CA=""
				M2='0101100000011'
			;;
			"0306" ) # EP06-A
				M2='010110100001100000000000110011000000000010000000000000000000000001'
				CA="ep06a-bands"
			;;
			"0512" ) # EM12-G
				M2='111110111001110011111000110111010000011110000000000000000000000001'
				CA="em12-2xbands"
				CA3="em12-3xbands"
			;;
			"0620" ) # EM20-G
				EM20=$(echo $model | grep "EM20")
				if [ ! -z $EM20 ]; then
					M2='111110110001110011110000110111000000011111100101000000000000000001'
					CA="em20-2xbands"
					CA3="em20-3xbands"
					CA4="em20-4xbands"
				else
					exit 0
				fi
			;;
		esac
	;;
	"1199" )
		case $uPid in

			"68c0"|"9041"|"901f" ) # MC7354 EM/MC7355
				M2='0101100000001000100000001'
				CA=""
			;;
			"9070"|"9071"|"9078"|"9079"|"907a"|"907b" ) # EM/MC7455
				M2='11111011000110000001000011000000000000001'
				CA="mc7455-bands"
			;;
			"9090"|"9091"|"90b1" ) # EM7565
				M2='111110111001100001110000010111010000000011100101000000000000000001'
				CA="em7565-2xbands"
				CA3="em7565-3xbands"
			;;
		esac
	;;
	"8087" )
		M2='111110110011100011111000010111000000011110000000000000000000000001'
		CA="l850-2xbands"
		CA3="l850-3xbands"
	;;
	* )
		exit 0
	;;
esac

length=${#L1}
jx="${L1:2:length-2}"
length=${#jx}
str=""
i=$((length-1))
while [ $i -ge 0 ]
do
    dgt="0x"${jx:$i:1}
	DecNum=`printf "%d" $dgt`
	Binary=
	Number=$DecNum
	while [ $DecNum -ne 0 ]
	do
		Bit=$(expr $DecNum % 2)
		Binary=$Bit$Binary
		DecNum=$(expr $DecNum / 2)
	done
	if [ -z $Binary ]; then
		Binary="0000"
	fi
	len=${#Binary}
	while [ $len -lt 4 ]
	do
		Binary="0"$Binary
		len=${#Binary}
	done
	revstr=""
	length=${#Binary}
	ii=$((length-1))
	while [ $ii -ge 0 ]
	do
		revstr=$revstr${Binary:$ii:1}
		ii=$((ii-1))
	done
	str=$str$revstr
    i=$((i-1))
done

revstr=$str"000000000000000000000"
echo $revstr > /tmp/bmask
echo $M2 >> /tmp/bmask
if [ $CA ]; then
	echo $CA >> /tmp/bmask
	if [ $CA3 ]; then
		echo $CA3 >> /tmp/bmask
		if [ $CA4 ]; then
			echo $CA4 >> /tmp/bmask
		fi
	fi
fi

