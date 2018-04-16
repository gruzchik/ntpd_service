#!/bin/bash
SCRIPT_PWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# check if ntp was installed
if [ ! -x "$(command -v ntpd)" ]; then
	apt-get install -y ntp
fi

## rewrite ntpd.conf and restart service

n="false" #marker for ntp record

grep -r '^pool' /etc/ntp.conf | while read line; do
	if [ ${n} == "false" ]; then
		#echo "line=${line}"
		sed -i "s/${line}/pool ua.pool.ntp.org/g" /etc/ntp.conf
		n="true" # add to one record using marker, other records wil be removed
		continue
	fi
	if [ ${n} == "true" ]; then
		echo "lineclear=${line}"
		sed -i "s/${line}//g" /etc/ntp.conf
	fi
done

systemctl restart ntp.service

## end rewrite ntpd.conf and restart service

# make backup default configuration file
/bin/cp /etc/ntp.conf /etc/ntp.conf.back

TESTCRON=$(crontab -l -uroot | grep ntp_verify.sh)
if [[ -z ${TESTCRON} ]] || [[ ${TESTCRON} = "no crontab for root" ]] ; then
	NEWCRON="*/1 * * * * ${SCRIPT_PWD}/ntp_verify.sh"
	(crontab -uroot -l; echo "${NEWCRON}") | crontab -u root -
fi
