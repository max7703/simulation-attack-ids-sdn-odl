#!/bin/bash

cd /var/log/snort

logfile=$(ls -1rt | tail -n1)

tcpdump -n -tttt -r $logfile > /ftpthreat/log.txt

cat /ftpthreat/log.txt | tail -30 > /ftpthreat/log30.txt

iptoban=$(grep -o "[0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+" /ftpthreat/log30.txt | sort | uniq | tail -2 | grep -v "192.168.16.4")

nbtry=$(grep -o "[0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+" /ftpthreat/log30.txt | sort | grep -v "192.168.16.4" | wc -l)

if [ "$nbtry" -gt 3 ]
then
	echo $iptoban " sera ban pour 1min"
        python3 /ftpthreat/putflow.py 192.168.16.5 /ftpthreat/fl1402.json 1402
else
	echo "aucune ip à bannir"
fi
