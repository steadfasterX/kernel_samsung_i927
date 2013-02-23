#!/system/bin/sh
#
# 2 in 1 Engine Flush Script created by -=zeppelinrox=-
# The 2 Modes are: -=Fast Engine Flush=- and -=Engine Flush-O-Matic=-
#
# V6U9RC12T3
#
# When using scripting tricks, ideas, or code snippets from here, please give proper credit.
# There are many things may look simple, but actually took a lot of time, trial, and error to get perfected.
#
# This script can be used freely and can even be modified for PERSONAL USE ONLY.
# It can be freely incorporated into ROMs - provided that proper credit is given WITH a link back to the XDA SuperCharger thread.
# If you want to share it or make a thread about it, just provide a link to the main thread.
#      - This ensures that users will always be getting the latest versions.
# Prohibited: Any modification (excluding personal use), repackaging, redistribution, or mirrors of my work are NOT PERMITTED.
# Thanks, zeppelinrox.
#
# See http://goo.gl/krtf9 - Linux Memory Consumption - Nice article which also discusses the "drop system cache" function!
# See http://goo.gl/hFdNO - Memory and SuperCharging Overview, or... "Why 'Free RAM' Is NOT Wasted RAM!"
#
# Credit imoseyon for making the drop caches command more well known :)
# See http://www.droidforums.net/forum/liberty-rom-d2/122733-tutorial-sysctl-you-guide-better-preformance-battery-life.html
# Credit dorimanx (Cool XDA dev!) for the neat idea to show before and after stats :D
#
# Note: To enable "Engine Flush-O-Matic" mode, change the "flushOmaticHours" variable to the number of hours you want.
#       Valid values are from 1 to 24 (hours).
#       If 0, or if the value is invalid or missing, "Engine Flush-O-Matic" mode is disabled.
#       Example: If you want it to run every 4 hours, make the line read "flushOmaticHours=4".
#
# Usage: 1. Type in Terminal: "su" and enter, "flush" and enter. ("flush" is indentical to !FastEngineFlush.sh but easier to type :p)
#        2. Script Manager: launch it once like any other script OR with a widget (DO NOT PUT IT ON A SCHEDULE!)
#
# Important! Whether you run this with Terminal or Script Manager or widget, the script relaunches and kills itself after the first run.
#            So let it run ONCE, close the app, and "Engine Flush-O-Matic" continues in the background!
#
# To verify that it's running, just run the script again!
# OR you can type in Terminal:
# 1. "pstree | grep -i flus" - for usage option 1 (with Terminal)
# 2. "pstree | grep sleep" - for usage option 2 (with Script Manager)
# 3. "cat /proc/*/cmdline | grep -i flush" - Sure-Fire method ;^]
#     The output should be 3 items:
#         a. "sbin/FastEngineFlush.sh" OR "/system/xbin/flush" (depending on which script you ran)
#         b. "Engine_Flush-O-Matic_is_In_Effect!" (sleep message)
#         c. "flush" (created by your query so this doesn't mean anything)
# 4. "busybox ps | grep -i flus" would give similar results as 3.
#
clear
#
# For debugging, delete the # at the beginning of the following 2 lines, and check /data/Log_FastEngineFlush.log file to see what may have fubarred.
# set -x
# exec > /data/Log_FastEngineFlush.log 2>&1
#
mount -o remount,rw /data 2>/dev/null
busybox mount -o remount,rw /data 2>/dev/null
line=================================================
cd "${0%/*}" 2>/dev/null

flushmode="    -=Fast Engine Flush=- by -=zeppelinrox=-"

if [ "`busybox ps -w`" ]; then w=" -w"; fi 2>/dev/null
id=$(id); id=${id#*=}; id=${id%%[\( ]*}
if [ "`busybox ps$w | grep "/${0##*/}" | wc -l`" -lt 3 ] && [ -f "/data/FOMtemp" ]; then
	rm /data/FOMtemp
	$intervalsecs | grep "Engine_Flush-O-Matic_is_In_Effect!"
elif [ "`busybox ps$w | grep "/${0##*/}" | wc -l`" -gt 2 ] || [ "`busybox ps | grep Matic_is_In_Effect | wc -l`" -gt 1 ]; then
	echo " -=Engine Flush-O-Matic=- is already in memory!"
fi 2>/dev/null
while :; do
	ram=$((`free | awk '{ print $2 }' | sed -n 2p`/1024))
	ramused=$((`free | awk '{ print $3 }' | sed -n 2p`/1024))
	ramkbytesfree=`free | awk '{ print $4 }' | sed -n 2p`
	ramkbytescached=`cat /proc/meminfo | grep Cached | awk '{print $2}' | sed -n 1p`
	ramfree=$(($ramkbytesfree/1024));ramcached=$(($ramkbytescached/1024));ramreportedfree=$(($ramfree + $ramcached))
	sleep 1
	echo $line
	echo " True Free $ramfree MB = \"Free\" $ramreportedfree - Cached Apps $ramcached"
	echo $line
	sleep 1
	busybox sync;
	sleep 3
	busybox sysctl -w vm.drop_caches=1 1>/dev/null
	ramused=$((`free | awk '{ print $3 }' | sed -n 2p`/1024))
	ramkbytesfree=`free | awk '{ print $4 }' | sed -n 2p`
	ramkbytescached=`cat /proc/meminfo | grep Cached | awk '{print $2}' | sed -n 1p`
	ramfree=$(($ramkbytesfree/1024));ramcached=$(($ramkbytescached/1024));ramreportedfree=$(($ramfree + $ramcached))
	sleep 1
	echo $line
	echo " True Free $ramfree MB = \"Free\" $ramreportedfree - Cached Apps $ramcached"
	echo $line
		echo "       =================================="
		echo "        ) Fast Engine Flush Completed! ("
		echo "       =================================="

	echo ""
	sleep 1
	if [ "`busybox ps$w | grep "{.*}.*${0##*/}" | wc -l`" -gt 1 ]; then echo "cookie!" > /data/FOMtemp; $0 & exit
	elif [ "`busybox --help | grep nohup`" ]; then echo "cookie!" > /data/FOMtemp; (busybox nohup $0 > /dev/null &); break
	elif [ "`busybox --help | grep start-stop-daemon`" ]; then echo "cookie!" > /data/FOMtemp; busybox start-stop-daemon -S -b -x $0; break
fi
done
exit 0
