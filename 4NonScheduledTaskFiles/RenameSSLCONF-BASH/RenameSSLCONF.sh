#!/usr/bin/bash

Today=$(date +%Y-%m-%d)

cd /etc/httpd/conf.d   || exit 1

if [[ -f "ssl.conf" ]];
then 
    echo "ssl.conf found.  Renaming..."
    mv "ssl.conf" "ssl.conf.$Today";
    echo "ssl.conf has been rename to ssl.conf.$Today"
else 
    echo "ssl.conf not found"
fi

sudo systemctl restart httpd.service
