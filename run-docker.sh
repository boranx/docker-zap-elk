#!/usr/bin/env bash

CONTAINER_ID=$(docker run -u zap -p 2375:2375 -d owasp/zap2docker-weekly zap.sh -daemon -port 2375 -host 127.0.0.1 -config api.disablekey=true -config scanner.attackOnStart=true -config view.mode=attack -config connection.dnsTtlSuccessfulQueries=-1 -config api.addrs.addr.name=.* -config api.addrs.addr.regex=true)

# the target URL for ZAP to scan
TARGET_URL=$1

docker exec $CONTAINER_ID zap-cli -p 2375 status -t 120 && docker exec $CONTAINER_ID zap-cli -p 2375 open-url $TARGET_URL

docker exec $CONTAINER_ID zap-cli -p 2375 spider $TARGET_URL

docker exec $CONTAINER_ID zap-cli -p 2375 active-scan --recursive $TARGET_URL

docker exec $CONTAINER_ID zap-cli -p 2375 alerts -l Informational

docker exec $CONTAINER_ID zap-cli -p 2375 alerts -f json -l Informational >> output.json

docker exec $CONTAINER_ID zap-cli -p 2375 report -o output.html -f html

docker exec $CONTAINER_ID zap-cli -p 2375 report -o output.xml -f xml

docker cp $CONTAINER_ID:zap/output.html ./

docker cp $CONTAINER_ID:zap/output.xml ./

echo "ELK stack"
git clone https://github.com/deviantony/docker-elk
cp output.json docker-elk/ && cd docker-elk && docker-compose stop && docker-compose rm -f || /bin/true && docker-compose up -d
until curl localhost:9200; do echo "Waiting for Elastic Search"; sleep 2; done

echo "parse output.json - add indices"
cat output.json | jq -c '.[] | {"index": {"_index": "bookmarks", "_type": "bookmark", "_id": .id}}, .' | curl -H 'Content-Type: application/json' -XPOST localhost:9200/_bulk --data-binary @-

docker stop $CONTAINER_ID

docker rm -f $CONTAINER_ID
