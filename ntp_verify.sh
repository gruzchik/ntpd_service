#!/bin/bash

## check status of ntp
CHECKNTP=$(ps ax | grep ntpd | grep -v 'grep ntpd'| wc -l)
if [ ${CHECKNTP} -eq 0 ]; then
	echo "NOTICE: ntp is not running"
	echo "Restarting ntp service.."
	service ntp restart
	if [ $? -eq 0 ]; then
		echo "Done!"
	fi
fi

## check status of ntp config file
CHECKDIFF=$(diff -u /etc/ntp.conf /etc/ntp.conf.back | wc -l)
if [ ${CHECKDIFF} -gt 0 ]; then
	echo "NOTICE: /etc/ntp.conf was changed. Calculated diff:"
	CHANGES=$(diff -u /etc/ntp.conf /etc/ntp.conf.back | grep -v "^\ #")
	echo -e "$CHANGES"
	/bin/cp /etc/ntp.conf.back /etc/ntp.conf
	service ntp restart
fi
