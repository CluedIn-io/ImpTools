#!/bin/sh

code=`echo -n $username | md5sum | cut -d " " -f1 | awk '{print toupper($0)}'`
URL=http://app.k1.cluedin.me/auth/api/account/register?code=$code
echo $URL

curl -v --location -g --request POST $URL \
        --header 'Content-Type: application/x-www-form-urlencoded'\
        --header "Authorization: Bearer $TOKEN" \
        --data-urlencode username=$username \
        --data-urlencode password=$password \
        --data-urlencode applicationSubDomain=$org \
        --data-urlencode grant_type=password \
        --data-urlencode confirmpassword=$password \
        --data-urlencode email=$username

