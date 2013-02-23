#!/system/bin/sh
#
# Detailing Script (SQLite VACUUM & REINDEX to optimize databases) created by -=zeppelinrox=-
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
# This will optimize (defrag, reindex, debloat) ALL sqlite3 databases found on your device.
# Resulting in faster database access and less ram usage for smoother performance.
#
# Props: avgjoemomma (from XDA) for the added reindex bit :)
#
# Note: You can change the "detailinterval" variable to any valid value that you want.
#       Valid values are from 1 to 9 (boots).
#       If 0, it won't run on boot.
#       If the value is invalid or missing, it defaults to running every 3rd boot.
#       Example: If you want it to run every 4th boot, make the line read "detailinterval=4".
#
clear
#
# For debugging, delete the # at the beginning of the following 2 lines, and check /data/Log_Detailing.log file to see what may have fubarred.
# set -x
# exec > /data/Log_Detailing.log 2>&1
#
mount -o remount,rw /data 2>/dev/null
busybox mount -o remount,rw /data 2>/dev/null
line=================================================
cd "${0%/*}" 2>/dev/null
echo ""
echo $line
echo "    -=Detailing=- script by -=zeppelinrox=-"
echo $line
echo ""
sleep 2
counterfile=/data/V6_SuperCharger/!Detailing_Counter
counter1=`cat $counterfile | head -n 1` 2>/dev/null
# To set the next line manually, see comments at the top for instuctions!
detailinterval=1
if [ ! "$detailinterval" ] || [ "`echo $detailinterval | grep "[^0-9]"`" ] || [ "$detailinterval" -gt 9 ]; then detailinterval=3; fi
if [ "`busybox ps | grep 99Super | wc -l`" -gt 1 ]; then
	if [ "$detailinterval" -eq 0 ]; then exit 69; fi
	if [ ! "$counter1" ] || [ "$counter1" -ge "$detailinterval" ]; then counter2=1
		echo "$counter2" > $counterfile
		echo " SQLite databases are optimized at $detailinterval boot intervals!" >> $counterfile
		echo "" >> $counterfile
		echo " Detailing ran on the most recent boot..." >> $counterfile
		echo " It was executed on `date`" >> $counterfile
	else counter2=$(($counter1+1))
		sed -i '1s/'$counter1'/'$counter2'/' $counterfile
		echo "" >> $counterfile
		echo " Detailing last ran $counter2 reboots ago..." >> $counterfile
		echo " It exited peacefully on `date`" >> $counterfile
		exit 69
	fi
else
	echo 1 > $counterfile
	echo " SQLite databases are optimized at $detailinterval boot intervals!" >> $counterfile
	echo "" >> $counterfile
	echo " Detailing was run manually so the counter has been reset..." >> $counterfile
	echo " It was executed on `date`" >> $counterfile
fi 2>/dev/null
id=$(id); id=${id#*=}; id=${id%%[\( ]*}
if [ "$id" != "0" ] && [ "$id" != "root" ]; then
	sleep 1
	echo " You are NOT running this script as root..."
	echo ""
	sleep 3
	echo $line
	echo "                      ...No SuperUser For You!!"
	echo $line
	echo ""
	sleep 3
	echo "     ...Please Run as Root and try again..."
	echo ""
	echo $line
	echo ""
	sleep 3
	exit 69
elif [ ! "`which sqlite3`" ]; then
	sleep 1
	echo " Doh... sqlite3 binary was NOT found..."
	echo ""
	sleep 3
	echo $line
	echo "                      ...No Vacuuming For You!!"
	echo $line
	echo ""
	sleep 3
	echo " Load the XDA SuperCharger thread..."
	echo ""
	sleep 3
	echo "   ...and install The SuperCharger Starter Kit!"
	echo ""
	echo $line
	echo ""
	sleep 3
	su -c "LD_LIBRARY_PATH=/vendor/lib:/system/lib am start -a android.intent.action.VIEW -n com.android.browser/.BrowserActivity -d file:///storage/sdcard0/!SuperCharger.html"
	echo ""
	echo $line
	echo ""
	sleep 3
	exit 69
fi 2>/dev/null
echo " Commencing SQLite VACUUM & REINDEX!"
echo ""
sleep 1
echo " Please IGNORE any errors that say..."
echo "        ======"
echo ""
sleep 1
echo " \"malformed database\" OR \"collation sequence\"!"
echo "  ==================      =================="
echo ""
sleep 1
echo "   ...as they won't effect SQLite Optimization!"
echo ""
sleep 1
echo $line
echo " This may take awhile... please wait..."
echo $line
echo ""
sleep 1
LOG_FILE=/data/Ran_Detailing.log
START=`busybox date +%s`
BEGAN=`date`
TOTAL=`busybox find /*d* -iname "*.db" | wc -l`
INCREMENT=3
PROGRESS=0
PROGRESS_BAR=""
echo " Start Detailing: $BEGAN" > $LOG_FILE
echo "" >> $LOG_FILE
sync
for i in `busybox find /*d* -iname "*.db"`; do
	PROGRESS=$(($PROGRESS+1))
	PERCENT=$(( $PROGRESS * 100 / $TOTAL ))
	if [ "$PERCENT" -eq "$INCREMENT" ]; then
		INCREMENT=$(( $INCREMENT + 3 ))
		PROGRESS_BAR="$PROGRESS_BAR="
	fi
	clear
	echo ""
	echo -n "                                        >"
	echo -e "\r       $PROGRESS_BAR>"
	echo "        -=Detailing=- by -=zeppelinrox=-"
	echo -n "                                        >"
	echo -e "\r       $PROGRESS_BAR>"
	echo ""
	echo "        Processing DBs - $PERCENT% ($PROGRESS of $TOTAL)"
	echo ""
	echo "  VACUUMING: $i" | tee -a $LOG_FILE
	sqlite3 $i 'VACUUM;';
	echo " REINDEXING: $i" | tee -a $LOG_FILE
	sqlite3 $i 'REINDEX;';
done
sync
STOP=`busybox date +%s`
ENDED=`date`
RUNTIME=`busybox expr $STOP - $START`
HOURS=`busybox expr $RUNTIME / 3600`
REMAINDER=`busybox expr $RUNTIME % 3600`
MINS=`busybox expr $REMAINDER / 60`
SECS=`busybox expr $REMAINDER % 60`
RUNTIME=`busybox printf "%02d:%02d:%02d\n" "$HOURS" "$MINS" "$SECS"`
echo ""
echo $line
echo "" | tee -a $LOG_FILE
sleep 1
echo " Done Optimizing $TOTAL Databases for ALL Apps..." | tee -a $LOG_FILE
echo "" | tee -a $LOG_FILE
sleep 1
echo "                 ...Say Hello To Optimized DBs!"
echo ""
echo $line
echo ""
sleep 1
echo "      Start Time: $BEGAN" | tee -a $LOG_FILE
echo "       Stop Time: $ENDED" | tee -a $LOG_FILE
echo "" | tee -a $LOG_FILE
echo " Completion Time: $RUNTIME" | tee -a $LOG_FILE
echo ""
sleep 1
echo " See $LOG_FILE for more details!"
echo ""
sleep 1
echo "           =========================="
echo "            ) Detailing Completed! ("
echo "           =========================="
echo ""
if [ -d "/system/etc/init.d" ]; then
	sleep 1
	echo " If desired, you can change Detailing options..."
	echo ""
	sleep 1
	echo "   *99SuperCharger would run Detailing.sh..."
	echo ""
	sleep 1
	echo "           ...so boot time would be unaffected!"
	echo ""
	sleep 1
	echo " AND you can specify how often it runs..."
	echo ""
	sleep 1
	echo "  ...so if you input 4, it runs every 4th boot!"
	echo ""
	sleep 1
	echo $line
	echo -n " Current Status: Detailing "
	if [ "$detailinterval" -eq 0 ]; then echo "DOES NOT Run On Boot!"
	else echo "Runs Every $detailinterval Boots!"
	fi
	echo $line
	echo ""
	sleep 1
	echo " You can also configure this in Driver Options!"
	echo ""
	sleep 1
	echo $line
	echo "   Also READ THE COMMENTS inside this script!"
	echo $line
	echo ""
	sleep 1
	echo " Change Options? You have 20 seconds to decide!"
	echo ""
	sleep 1
	echo -n " Enter Y for Yes, any key for No: "
	stty -icanon min 0 time 200
	read changeoptions
	stty sane
	if [ ! "$changeoptions" ]; then echo ""; fi
	echo ""
	echo $line
	case $changeoptions in
		y|Y)mount -o remount,rw /system 2>/dev/null
			busybox mount -o remount,rw /system 2>/dev/null
			busybox mount -o remount,rw $(busybox mount | grep system | awk '{print $1,$3}' | sed -n 1p) 2>/dev/null
			echo ""
			sleep 1
			if [ "$bootdetailing" ] && [ "`ls /system/etc/init.d/*SuperCharger*`" ]; then
				sed -i '/!Detailing/d' /system/etc/init.d/*SuperCharger*
				sed -i '/sleep 90;/ ased -i '"'s/# exec >/exec >/'"' /data/V6_SuperCharger/!Detailing.sh 2>/dev/null;sh /data/V6_SuperCharger/!Detailing.sh & sleep 2;sed -i '"'s/exec >/# exec >/'"' /data/V6_SuperCharger/!Detailing.sh 2>/dev/null; sleep 480;' /system/etc/init.d/*SuperCharger*
			fi 2>/dev/null
			echo " Run Detailing on boot?"
			echo ""
			sleep 1
			echo -n " Enter Y for Yes, any key for No: "
			read bootdetailing
			echo ""
			case $bootdetailing in
			  y|Y)detailing=1
				  if [ ! "`ls /system/etc/init.d/*SuperCharger*`" ]; then
					echo $line
					echo " An Option from 2 - 13 still needs to be run!"
				  fi 2>/dev/null
				  while :; do
					echo $line
					echo ""
					sleep 1
					echo -n " How often? 1=every boot to 9=every 9th boot: "
					read detailinterval
					echo ""
					echo $line
					case $detailinterval in
					  [1-9])echo "       Detailing Set To Run Every $detailinterval Boots!"
							break;;
						  *)echo "      Invalid entry... Please try again :p";;
					esac
				  done;;
				*)detailing=0; detailinterval=0
				  sed -i '/!Detailing.sh/s/^/# /' /system/etc/init.d/*SuperCharger* 2>/dev/null
				  echo "           Declined Detailing On Boot!";;
			esac
			sed -i 's/^detailinterval=.*/detailinterval='$detailinterval'/' $0
			if [ "$0" != "/data/V6_SuperCharger/!Detailing.sh" ]; then sed -i 's/^detailinterval=.*/detailinterval='$detailinterval'/' /data/V6_SuperCharger/!Detailing.sh; fi 2>/dev/null
			if [ "$0" != "/system/xbin/vac" ]; then sed -i 's/^detailinterval=.*/detailinterval='$detailinterval'/' /system/xbin/vac; fi 2>/dev/null
			if [ -f "/data/V6_SuperCharger/SuperChargerOptions" ]; then
				awk 'BEGIN{OFS=FS=","}{$10='$detailing',$11='$detailinterval';print}' /data/V6_SuperCharger/SuperChargerOptions > /data/V6_SuperCharger/SuperChargerOptions.tmp
				mv /data/V6_SuperCharger/SuperChargerOptions.tmp /data/V6_SuperCharger/SuperChargerOptions
			fi
			mount -o remount,ro /system 2>/dev/null
			busybox mount -o remount,ro /system 2>/dev/null
			busybox mount -o remount,ro $(busybox mount | grep system | awk '{print $1,$3}' | sed -n 1p) 2>/dev/null;;
		  *)echo "               No Change For You!";;
	esac
fi
echo $line
echo ""
sleep 1
exit 0
