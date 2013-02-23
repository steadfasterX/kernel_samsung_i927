#!/sbin/busybox sh
#/system/bin/sh
#
# Fix Alignment Script (ZipAlign AND Fix Permissions) created by -=zeppelinrox=-
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
# Combines my "ZepAlign" / Wheel Alignment Script (ZipAlign) with my Fix Emissions Script (Fix Permissions).
#
  ###############################
 # Wheel Alignment Information #
###############################
# ZipAligns all data and system apks (apps) that have not yet been ZipAligned.
# ZipAlign optimizes all your apps, resulting in less RAM comsumption and a faster device! ;^]
#
# Props: Automatic ZipAlign by Wes Garner (original script)
#        oknowton for the change from MD5 to zipalign -c 4
#
# Tweaks & Enhancements by zeppelinrox...
#      - Added support for /vendor/app (for ICS)
#      - Added support for /mnt/asec
#      - Added support for more data directories ie. dbdata, datadata, etc.
#      - Added debugging
#      - Tweaked interface a bit ;^]
#
  #############################
 # Fix Emissions Information #
#############################
# Sets permissions for android data directories and apks.
# This should fix app force closes (FCs).
# It's quite fast - setting permissions for 300 apps in approximately 1 minute.
#
# Props: Originally and MOSTLY (erm... something like 90% of it lol) by Jared Rummler (JRummy16).
# However, I actually meshed together 3 different Fix Permissions scripts ;^]
#
# Tweaks & Enhancements by zeppelinrox...
#      - Removed the usage of the "pm list packages" command - it didn't work on boot.
#      - Added support for /vendor/app (for ICS)
#      - No longer excludes framework-res.apk or com.htc.resources.apk
#      - Added support for more data directories ie. dbdata, datadata, etc.
#      - Added debugging
#      - Tweaked interface a bit ;^]
#
clear
#
# For debugging, delete the # at the beginning of the following 2 lines, and check /data/Log_FixAlign.log file to see what may have fubarred.
# set -x
# exec > /data/Log_FixAlign.log 2>&1
#
mount -o remount,rw /data 2>/dev/null
busybox mount -o remount,rw /data 2>/dev/null
line=================================================
cd "${0%/*}" 2>/dev/null
#echo ""
#echo $line
#echo "   -=Fix Alignment=- script by -=zeppelinrox=-"
#echo $line
#echo ""
sleep 2
zipalign="yes"
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
elif [ ! "`which zipalign`" ]; then
	zipalign=
	sleep 1
	echo " Doh... zipalign binary was NOT found..."
	echo ""
	sleep 3
	echo $line
	echo "                    ...No ZepAligning For You!!"
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
	su -c "LD_LIBRARY_PATH=/vendor/lib:/system/lib am start -a android.intent.action.VIEW -n com.android.browser/.BrowserActivity -d file://$storage/!SuperCharger.html"
	echo ""
	echo $line
	echo ""
	sleep 3
	echo $line
	echo "    So... for now... can ONLY Fix Emissions!"
	echo $line
	echo ""
	sleep 3
fi 2>/dev/null
mount -o remount,rw /system 2>/dev/null
busybox mount -o remount,rw /system 2>/dev/null
busybox mount -o remount,rw $(busybox mount | grep system | awk '{print $1,$3}' | sed -n 1p) 2>/dev/null
rm /data/fixaligntemp* 2>/dev/null
#LOG_FILE=/data/Ran_FixAlign.log
#LOG_FILE2=/data/Ran_ZepAlign.log
START=`busybox date +%s`
BEGAN=`date`
TOTAL=`cat /d*/system/packages.xml | grep -E "^<package.*serId" | wc -l`
INCREMENT=3
PROGRESS=0
PROGRESS_BAR=""
#echo " Start Fix Alignment: $BEGAN" > $LOG_FILE
#if [ "$zipalign" ]; then echo " Start Wheel Alignment ( \"ZepAlign\" ): $BEGAN" > $LOG_FILE2; echo "" >> $LOG_FILE2; fi
sync
grep -E "^<package.*serId" /d*/system/packages.xml | while read pkgline; do
	if [ ! -f "/data/fixaligntemp" ]; then ALIGNED=0; ALREADY=0; FAILED=0; SKIPPED=0; fi
	PKGNAME=`echo $pkgline | sed 's%.* name="\(.*\)".*%\1%' | cut -d '"' -f1`
	CODEPATH=`echo $pkgline | sed 's%.* codePath="\(.*\)".*%\1%' |  cut -d '"' -f1`
	DATAPATH=/d*/d*/$PKGNAME
	PKGUID=`echo $pkgline | sed 's%.*serId="\(.*\)".*%\1%' | cut -d '"' -f1`
	PROGRESS=$(($PROGRESS+1))
	PERCENT=$(( $PROGRESS * 100 / $TOTAL ))
	if [ "$PERCENT" -eq "$INCREMENT" ]; then
		INCREMENT=$(( $INCREMENT + 3 ))
		PROGRESS_BAR="$PROGRESS_BAR="
	fi
	clear
#	echo ""
#	echo -n "                                        >"
#	echo -e "\r       $PROGRESS_BAR>"
#	echo "       \"Fix Alignment\" by -=zeppelinrox=-"
#	echo -n "                                        >"
#	echo -e "\r       $PROGRESS_BAR>"
#	echo ""
#	echo "       Processing Apps - $PERCENT% ($PROGRESS of $TOTAL)"
#	echo "" | tee -a $LOG_FILE
#	echo " Fix Aligning $PKGNAME..." | tee -a $LOG_FILE
#	echo ""
	if [ -e "$CODEPATH" ]; then
		if [ "$zipalign" ]; then
			if [ "$(busybox basename $CODEPATH )" = "framework-res.apk" ] || [ "$(busybox basename $CODEPATH )" = "SystemUI.apk" ] || [ "$(busybox basename $CODEPATH )" = "com.htc.resources.apk" ]; then
#				echo " NOT ZipAligning (Problematic) $CODEPATH..." | tee -a $LOG_FILE $LOG_FILE2
				SKIPPED=$(($SKIPPED+1))
				skippedapp="$skippedapp$(busybox basename $CODEPATH ),"
			else
				zipalign -c 4 $CODEPATH
				ZIPCHECK=$?
				if [ "$ZIPCHECK" -eq 1 ]; then
#					echo " ZipAligning $CODEPATH..." | tee -a $LOG_FILE $LOG_FILE2
					zipalign -f 4 $CODEPATH /cache/$(busybox basename $CODEPATH )
					rc="$?"
					if [ "$rc" -eq 0 ]; then
						if [ -e "/cache/$(busybox basename $CODEPATH )" ]; then
#							busybox cp -f -p /cache/$(busybox basename $CODEPATH ) $CODEPATH | tee -a $LOG_FILE $LOG_FILE2
							ALIGNED=$(($ALIGNED+1))
						else
#							echo " ZipAligning $CODEPATH... Failed (No Output File!)" | tee -a $LOG_FILE $LOG_FILE2
							FAILED=$(($FAILED+1))
							failedapp="$failedapp$(busybox basename $CODEPATH ),"
						fi
					else #echo "ZipAligning $CODEPATH... Failed (rc: $rc!)" | tee -a $LOG_FILE $LOG_FILE2
						FAILED=$(($FAILED+1))
						failedapp="$failedapp$(busybox basename $CODEPATH ),"
					fi
					if [ -e "/cache/$(busybox basename $CODEPATH )" ]; then busybox rm /cache/$(busybox basename $CODEPATH ); fi
				else
					#echo " ZipAlign already completed on $CODEPATH " | tee -a $LOG_FILE $LOG_FILE2
					ALREADY=$(($ALREADY+1))
				fi
				echo "$ALIGNED $ALREADY $FAILED $SKIPPED" > /data/fixaligntemp
				echo "$failedapp" > /data/fixaligntemp2
				echo "$skippedapp" > /data/fixaligntemp3
			fi
		fi
		APPDIR=`busybox dirname $CODEPATH`
		if [ "$APPDIR" = "/system/app" ] || [ "$APPDIR" = "/vendor/app" ] || [ "$APPDIR" = "/system/framework" ]; then
			busybox chown 0 $CODEPATH
			busybox chown :0 $CODEPATH
			busybox chmod 644 $CODEPATH
		elif [ "$APPDIR" = "/data/app" ]; then
			busybox chown 1000 $CODEPATH
			busybox chown :1000 $CODEPATH
			busybox chmod 644 $CODEPATH
		elif [ "$APPDIR" = "/data/app-private" ]; then
			busybox chown 1000 $CODEPATH
			busybox chown :$PKGUID $CODEPATH
			busybox chmod 640 $CODEPATH
		fi
		if [ -d "$DATAPATH" ]; then
			busybox chmod 755 $DATAPATH
			busybox chown $PKGUID $DATAPATH
			busybox chown :$PKGUID $DATAPATH
			DIRS=`busybox find $DATAPATH -mindepth 1 -type d`
			for file in $DIRS; do
				PERM=755
				NEWUID=$PKGUID
				NEWGID=$PKGUID
				FNAME=`busybox basename $file`
				case $FNAME in
							lib)busybox chmod 755 $file
								NEWUID=1000
								NEWGID=1000
								PERM=755;;
				   shared_prefs)busybox chmod 771 $file
								PERM=660;;
					  databases)busybox chmod 771 $file
								PERM=660;;
						  cache)busybox chmod 771 $file
								PERM=600;;
						  files)busybox chmod 771 $file
								PERM=775;;
							  *)busybox chmod 771 $file
								PERM=771;;
				esac
				busybox chown $NEWUID $file
				busybox chown :$NEWGID $file
				busybox find $file -type f -maxdepth 2 ! -perm $PERM -exec busybox chmod $PERM {} ';'
				busybox find $file -type f -maxdepth 1 ! -user $NEWUID -exec busybox chown $NEWUID {} ';'
				busybox find $file -type f -maxdepth 1 ! -group $NEWGID -exec busybox chown :$NEWGID {} ';'
			done
		fi
		#echo " Fixed Permissions..." | tee -a $LOG_FILE
	fi 2>/dev/null
done
sync
#echo "" | tee -a $LOG_FILE
#echo $line
mount -o remount,ro /system 2>/dev/null
busybox mount -o remount,ro /system 2>/dev/null
busybox mount -o remount,ro $(busybox mount | grep system | awk '{print $1,$3}' | sed -n 1p) 2>/dev/null
STOP=`busybox date +%s`
ENDED=`date`
RUNTIME=`busybox expr $STOP - $START`
HOURS=`busybox expr $RUNTIME / 3600`
REMAINDER=`busybox expr $RUNTIME % 3600`
MINS=`busybox expr $REMAINDER / 60`
SECS=`busybox expr $REMAINDER % 60`
RUNTIME=`busybox printf "%02d:%02d:%02d\n" "$HOURS" "$MINS" "$SECS"`
if [ "$zipalign" ]; then
#	ALIGNED=`awk '{print $1}' /data/fixaligntemp`
#	ALREADY=`awk '{print $2}' /data/fixaligntemp`
#	FAILED=`awk '{print $3}' /data/fixaligntemp`
#	SKIPPED=`awk '{print $4}' /data/fixaligntemp`
#	failedapp=`cat /data/fixaligntemp2`
#	skippedapp=`cat /data/fixaligntemp3`
#	echo "" | tee -a $LOG_FILE2
#	sleep 1
	rm /data/fixaligntemp*
#	echo " Done \"ZepAligning\" ALL data and system APKs..." | tee -a $LOG_FILE $LOG_FILE2
#	echo "" | tee -a $LOG_FILE $LOG_FILE2
#	sleep 1
#	echo " $ALIGNED   Apps were zipaligned..." | tee -a $LOG_FILE $LOG_FILE2
#	echo " $ALREADY Apps were already zipaligned..." | tee -a $LOG_FILE $LOG_FILE2
#	echo " $FAILED   Apps were NOT zipaligned due to error..." | tee -a $LOG_FILE $LOG_FILE2
#	if [ "$failedapp" ]; then echo "     ($failedapp)" | tee -a $LOG_FILE; fi
#	echo " $SKIPPED   (Problematic) Apps were skipped..." | tee -a $LOG_FILE $LOG_FILE2
#	echo "     ($skippedapp)" | tee -a $LOG_FILE $LOG_FILE2
#	echo "" | tee -a $LOG_FILE $LOG_FILE2
#	echo " $TOTAL Apps were processed!" | tee -a $LOG_FILE $LOG_FILE2
#	echo "" | tee -a $LOG_FILE
# 	sleep 1
#	echo "                ...Say Hello To Optimized Apps!"
#	echo ""
#	echo $line
fi
#echo ""
#sleep 1
#echo " FIXED Permissions For ALL $TOTAL Apps..." | tee -a $LOG_FILE
#echo "" | tee -a $LOG_FILE
#sleep 1
#echo "          ...Say Buh Bye To Force Close Errors!"
#echo ""
#echo $line
#echo ""
#sleep 1
#echo "      Start Time: $BEGAN" | tee -a $LOG_FILE
#echo "       Stop Time: $ENDED" | tee -a $LOG_FILE
#echo "" | tee -a $LOG_FILE
echo " Completion Time: $RUNTIME" | tee -a $LOG_FILE
#echo ""
#sleep 1
#echo " See $LOG_FILE for more details!"
#echo ""
#sleep 1
#if [ "$zipalign" ]; then echo " And see $LOG_FILE2 for even more!"; fi
#echo ""
#sleep 1
echo "=============================="
echo "Fix Alignment Completed! "
echo "=============================="
#echo ""
sleep 1
exit 0
