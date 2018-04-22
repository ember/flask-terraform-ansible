#!/bin/bash

if [[ "$OSTYPE" == "darwin"* ]];
then
    DATE=gdate
else
    DATE=date
fi

ENDPOINT=$1

if [ $# -ne 1  ];
then
    echo "usage: ${0} <http endpoint>"
    exit 192
fi

birthday_today=$($DATE +"%Y-%m-%d")
birthday_today_minus_5=$($DATE --date="5 days ago" +"%Y-%m-%d")
random_date=$($DATE -d "$((RANDOM%20+2000))-$((RANDOM%12+1))-$((RANDOM%28+1))" +"%Y-%m-%d" )
random_incorrect_date=$($DATE -d "$((RANDOM%20+2000))-$((RANDOM%12+1))-$((RANDOM%28+1))" +"%Y-%m %d" )

function create_resources()
{
    curl -H "Content-type: application/json" ${ENDPOINT}/John -d '{"dateOfBirth":"'"${birthday_today}"'"}' -XPUT
    curl -H "Content-type: application/json" ${ENDPOINT}/Mary -d '{"dateOfBirth":"'"${birthday_today_minus_5}"'"}' -XPUT
    curl -H "Content-type: application/json" ${ENDPOINT}/Anna -d '{"dateOfBirth":"'"${random_date}"'"}' -XPUT
    curl -H "Content-type: application/json" ${ENDPOINT}/Harry -d '{"dateOfBirth":"'"${random_incorrect_date}"'"}' -XPUT
}

function get_resources()
{
    curl ${ENDPOINT}/John 
    curl ${ENDPOINT}/Mary 
    curl ${ENDPOINT}/Anna 
    curl ${ENDPOINT}/Harry 
}

create_resources
get_resources

