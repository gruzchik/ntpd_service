#!/bin/bash
#set -x
SCRIPT_PWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ ! -x "$(command -v ntpd)" ]; then
	apt-get install -y ntp
else
	echo "ntpd is exists"
fi

n="false"

cp /etc/ntp.conf /etc/ntp_back$(date '+%d.%m.%Y_%T').conf

grep -r '^pool' /etc/ntp.conf | while read line; do
	if [ ${n} == "false" ]; then
		echo "line=${line}"
		#sed -i's/${line}/"pool ua.pool.ntp.org"/' /etc/ntp.conf
		sed -i "s/${line}/pool ua.pool.ntp.org/g" /etc/ntp.conf
		n="true"
		continue
	fi
	if [ ${n} == "true" ]; then
		echo "lineclear=${line}"
		sed -i "s/${line}//g" /etc/ntp.conf
	fi
done

systemctl restart ntp.service

#echo ${SCRIPT_PWD}
TESTCRON=$(crontab -l -uroot | grep ntp_verify.sh)
if [[ -z ${TESTCRON} ]]; then
	echo "*/5 * * * * ${SCRIPT_PWD}/ntp_verify.sh" >> /var/spool/cron/crontabs/root
fi
