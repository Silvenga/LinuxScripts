#!/bin/bash
#
# Network speed testing script put together by `aFriend` from LowEndTalk.
# http://lowendtalk.com/discussion/comment/561833/#Comment_561833
#
function download_benchmark() {
	DOWNLOAD_SPEED=`wget -O /dev/null $2 2>&1 | awk '/\/dev\/null/ {speed=$3 $4} END {gsub(/\(|\)/,"",speed); print speed}'`
	echo "Got $DOWNLOAD_SPEED :  $1 ($2)"
}

echo "Running bandwidth benchmark..."
download_benchmark 'CDN77 Chicago, US          ' 'http://793343545.r.cdn77.net/design/swf/testfile100.bin'
download_benchmark 'Cachefly                   ' 'http://cachefly.cachefly.net/100mb.test'
download_benchmark 'OVH, Montreal, Canada      ' 'http://proof.ovh.ca/files/100Mio.dat'
download_benchmark 'Linode, Atlanta, GA, USA   ' 'http://speedtest.atlanta.linode.com/100MB-atlanta.bin'
download_benchmark 'Linode, Dallas, TX, USA    ' 'http://speedtest.dallas.linode.com/100MB-dallas.bin'
download_benchmark 'Softlayer, Seattle, WA, USA' 'http://speedtest.sea01.softlayer.com/downloads/test100.zip'
download_benchmark 'Softlayer, S Jose,CA, USA  ' 'http://speedtest.sjc01.softlayer.com/downloads/test100.zip'
download_benchmark 'Softlayer, Wash, DC, USA   ' 'http://speedtest.wdc01.softlayer.com/downloads/test100.zip'
download_benchmark 'Leaseweb, Manassas, VA, USA' 'http://mirror.us.leaseweb.net/speedtest/100mb.bin'
download_benchmark 'OVH, Paris, France         ' 'http://proof.ovh.net/files/100Mio.dat'
download_benchmark 'Linode, London, UK         ' 'http://speedtest.london.linode.com/100MB-london.bin'
download_benchmark 'SmartDC, Rotterdam, NL     ' 'http://mirror.i3d.net/100mb.bin'
download_benchmark 'Hetzner, Nuernberg, DE     ' 'http://hetzner.de/100MB.iso'
download_benchmark 'iiNet, Perth, WA, AUS      ' 'http://ftp.iinet.net.au/test100MB.dat'
download_benchmark 'Leaseweb, Haarlem, NL      ' 'http://mirror.nl.leaseweb.net/speedtest/100mb.bin'
#download_benchmark 'Linode, Tokyo, JP          ' 'http://speedtest.tokyo.linode.com/100MB-tokyo.bin'
#download_benchmark 'MammothVPS, Sydney, AUS    ' 'http://www.mammothvpscustomer.com/test100MB.dat'
#download_benchmark 'Softlayer, Singapore       ' 'http://speedtest.sng01.softlayer.com/downloads/test100.zip'

echo "Downloading and running speedtest.net CLI"
wget --quiet --no-check-certificate https://raw.github.com/sivel/speedtest-cli/master/speedtest_cli.py
python speedtest_cli.py
rm speedtest_cli.py

echo "Running traceroute..."
echo "Traceroute (cachefly.cachefly.net): ``traceroute cachefly.cachefly.net 2>&1``"

echo "Running ping benchmark..."
echo "Pings (cachefly.cachefly.net): ``ping -c 10 cachefly.cachefly.net 2>&1``"

