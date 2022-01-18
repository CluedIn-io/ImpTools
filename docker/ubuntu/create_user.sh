#!/bin/bash

# basic checks
if [ -z ${TOKEN+x} ]; then echo "error: TOKEN undefined"; exit 0; else echo "TOKEN set"; fi
if [ -z ${username+x} ]; then echo "error: username undefined"; exit 0; else echo "username set"; fi
if [ -z ${password+x} ]; then password=`date | md5sum | head -c 16`; else echo "password set"; fi
if [ -z ${org+x} ]; then echo "error: org undefined"; exit 0; else echo "org set"; fi

code=`echo -n $username | md5sum | cut -d " " -f1 | awk '{print toupper($0)}'`
URL=http://app.u1.cluedin.me:8888/auth/api/account/register?code=$code
echo $URL

curl -v -k --location -g --request POST $URL \
        --header 'Content-Type: application/x-www-form-urlencoded'\
        --header "Authorization: Bearer $TOKEN" \
        --data-urlencode username=$username \
        --data-urlencode password=$password \
        --data-urlencode applicationSubDomain=$org \
        --data-urlencode grant_type=password \
        --data-urlencode confirmpassword=$password \
        --data-urlencode email=$username

URLHost=`echo $URL | sed -e 's|^[^/]*//||' -e 's|/.*$||'`
LoginHost=`echo $URLHost | sed -e "s|app|${org}|"`
URLSchema=`echo $URL | cut -d: -f 1`
SignInURL=$URLSchema://$LoginHost/signin

echo
echo $SignInURL
echo $username
echo $password
