#!/bin/bash
#
# Copyright IBM Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

jq --version > /dev/null 2>&1
if [ $? -ne 0 ]; then
	echo "Please Install 'jq' https://stedolan.github.io/jq/ to execute this script"
	echo
	exit 1
fi

starttime=$(date +%s)

# Print the usage message
function printHelp () {
  echo "Usage: "
  echo "  ./testAPIs.sh -l golang|node"
  echo "    -l <language> - chaincode language (defaults to \"golang\")"
}
# Language defaults to "golang"
LANGUAGE="golang"

# Parse commandline args
while getopts "h?l:" opt; do
  case "$opt" in
    h|\?)
      printHelp
      exit 0
    ;;
    l)  LANGUAGE=$OPTARG
    ;;
  esac
done

##set chaincode path
function setChaincodePath(){
	LANGUAGE=`echo "$LANGUAGE" | tr '[:upper:]' '[:lower:]'`
	case "$LANGUAGE" in
		"golang")
		CC_SRC_PATH="github.com/supplychain_cc/go"
		;;
		"node")
		CC_SRC_PATH="$PWD/artifacts/src/github.com/supplychain_cc/node"
		;;
		*) printf "\n ------ Language $LANGUAGE is not supported yet ------\n"$
		exit 1
	esac
}

setChaincodePath

echo "POST request Enroll on Manufacturer  ..."
echo
Manufacturer_TOKEN=$(curl -s -X POST \
  http://localhost:4000/users \
  -H "content-type: application/x-www-form-urlencoded" \
  -d 'username=admin&orgName=Manufacturer')
echo $Manufacturer_TOKEN
Manufacturer_TOKEN=$(echo $Manufacturer_TOKEN | jq ".token" | sed "s/\"//g")
echo
echo "Manufacturer token is $Manufacturer_TOKEN"
echo
echo "POST request Enroll on Middlemen ..."
echo
Middlemen_TOKEN=$(curl -s -X POST \
  http://localhost:4000/users \
  -H "content-type: application/x-www-form-urlencoded" \
  -d 'username=admin&orgName=Middlemen')
echo $Middlemen_TOKEN
Middlemen_TOKEN=$(echo $Middlemen_TOKEN | jq ".token" | sed "s/\"//g")
echo
echo "Middlemen token is $Middlemen_TOKEN"
echo
echo
Consumer_TOKEN=$(curl -s -X POST \
  http://localhost:4000/users \
  -H "content-type: application/x-www-form-urlencoded" \
  -d 'username=admin&orgName=Consumer')
echo $Consumer_TOKEN
Consumer_TOKEN=$(echo $Consumer_TOKEN | jq ".token" | sed "s/\"//g")
echo
echo "Consumer token is $Consumer_TOKEN"
echo
echo
echo "POST request Create channel  ..."
echo
curl -s -X POST \
  http://localhost:4000/channels \
  -H "authorization: Bearer $Manufacturer_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"channelName":"mychannel",
	"channelConfigPath":"../artifacts/channel/mychannel.tx"
}'
echo
echo
sleep 5
echo "POST request Join channel on Manufacturer"
echo
curl -s -X POST \
  http://localhost:4000/channels/mychannel/peers \
  -H "authorization: Bearer $Manufacturer_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"peers": ["peer0.manufacturer.supplychain.com"]
}'
echo
echo

echo "POST request Join channel on Middlemen peer0"
echo
curl -s -X POST \
  http://localhost:4000/channels/mychannel/peers \
  -H "authorization: Bearer $Middlemen_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"peers": ["peer0.middlemen.supplychain.com"]
}'
echo
echo
echo "POST request Join channel on Middlemen peer1"
echo
curl -s -X POST \
  http://localhost:4000/channels/mychannel/peers \
  -H "authorization: Bearer $Middlemen_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"peers": ["peer1.middlemen.supplychain.com"]
}'
echo
echo "POST request Join channel on Middlemen peer2"
echo
curl -s -X POST \
  http://localhost:4000/channels/mychannel/peers \
  -H "authorization: Bearer $Middlemen_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"peers": ["peer2.middlemen.supplychain.com"]
}'
echo
echo
echo "POST request Join channel on Consumer peer0"
echo
echo
curl -s -X POST \
  http://localhost:4000/channels/mychannel/peers \
  -H "authorization: Bearer $Consumer_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"peers": ["peer0.consumer.supplychain.com"]
}'
echo
echo
echo "POST request Update anchor peers on Manufacturer"
echo
curl -s -X POST \
  http://localhost:4000/channels/mychannel/anchorpeers \
  -H "authorization: Bearer $Manufacturer_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"configUpdatePath":"../artifacts/channel/ManufacturerMSPanchors.tx"
}'
echo
echo

echo "POST request Update anchor peers on Middlemen"
echo
curl -s -X POST \
  http://localhost:4000/channels/mychannel/anchorpeers \
  -H "authorization: Bearer $Middlemen_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"configUpdatePath":"../artifacts/channel/MiddlemenMSPanchors.tx"
}'
echo
echo

echo "POST request Update anchor peers on Consumer"
echo
curl -s -X POST \
  http://localhost:4000/channels/mychannel/anchorpeers \
  -H "authorization: Bearer $Consumer_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"configUpdatePath":"../artifacts/channel/ConsumerMSPanchors.tx"
}'
echo
echo

echo "POST Install chaincode on Manufacturer"
echo
curl -s -X POST \
  http://localhost:4000/chaincodes \
  -H "authorization: Bearer $Manufacturer_TOKEN" \
  -H "content-type: application/json" \
  -d "{
	\"peers\": [\"peer0.manufacturer.supplychain.com\"],
	\"chaincodeName\":\"mycc\",
	\"chaincodePath\":\"$CC_SRC_PATH\",
	\"chaincodeType\": \"$LANGUAGE\",
	\"chaincodeVersion\":\"v0\"
}"
echo
echo

echo "POST Install chaincode on Middlemen peer0"
echo
curl -s -X POST \
  http://localhost:4000/chaincodes \
  -H "authorization: Bearer $Middlemen_TOKEN" \
  -H "content-type: application/json" \
  -d "{
	\"peers\": [\"peer0.middlemen.supplychain.com\"],
	\"chaincodeName\":\"mycc\",
	\"chaincodePath\":\"$CC_SRC_PATH\",
	\"chaincodeType\": \"$LANGUAGE\",
	\"chaincodeVersion\":\"v0\"
}"
echo
echo

echo "POST Install chaincode on Middlemen peer1"
echo
curl -s -X POST \
  http://localhost:4000/chaincodes \
  -H "authorization: Bearer $Middlemen_TOKEN" \
  -H "content-type: application/json" \
  -d "{
	\"peers\": [\"peer1.middlemen.supplychain.com\"],
	\"chaincodeName\":\"mycc\",
	\"chaincodePath\":\"$CC_SRC_PATH\",
	\"chaincodeType\": \"$LANGUAGE\",
	\"chaincodeVersion\":\"v0\"
}"
echo
echo

echo "POST Install chaincode on Middlemen peer2"
echo
curl -s -X POST \
  http://localhost:4000/chaincodes \
  -H "authorization: Bearer $Middlemen_TOKEN" \
  -H "content-type: application/json" \
  -d "{
	\"peers\": [\"peer2.middlemen.supplychain.com\"],
	\"chaincodeName\":\"mycc\",
	\"chaincodePath\":\"$CC_SRC_PATH\",
	\"chaincodeType\": \"$LANGUAGE\",
	\"chaincodeVersion\":\"v0\"
}"
echo
echo

echo "POST Install chaincode on Consumer"
echo
curl -s -X POST \
  http://localhost:4000/chaincodes \
  -H "authorization: Bearer $Consumer_TOKEN" \
  -H "content-type: application/json" \
  -d "{
	\"peers\": [\"peer0.consumer.supplychain.com\"],
	\"chaincodeName\":\"mycc\",
	\"chaincodePath\":\"$CC_SRC_PATH\",
	\"chaincodeType\": \"$LANGUAGE\",
	\"chaincodeVersion\":\"v0\"
}"
echo
echo

echo "POST instantiate chaincode on Manufacturer"
echo
curl -s -X POST \
  http://localhost:4000/channels/mychannel/chaincodes \
  -H "authorization: Bearer $Manufacturer_TOKEN" \
  -H "content-type: application/json" \
  -d "{
	\"chaincodeName\":\"mycc\",
	\"chaincodeVersion\":\"v0\",
	\"chaincodeType\": \"$LANGUAGE\",
	\"args\":[\"a\",\"100\",\"b\",\"200\"]
}"
echo
echo

echo "POST invoke chaincode on peers of Manufacturer and Middlemen"
echo
VALUES=$(curl -s -X POST \
  http://localhost:4000/channels/mychannel/chaincodes/mycc \
  -H "authorization: Bearer $Manufacturer_TOKEN" \
  -H "content-type: application/json" \
  -d "{
  \"peers\": [\"peer0.manufacturer.supplychain.com\",\"peer0.middlemen.supplychain.com\"],
  \"fcn\":\"move\",
  \"args\":[\"a\",\"b\",\"10\"]
}")
echo $VALUES
# Assign previous invoke transaction id  to TRX_ID
MESSAGE=$(echo $VALUES | jq -r ".message")
TRX_ID=${MESSAGE#*ID: }
echo

echo "GET query chaincode on peer0 of Manufacturer"
echo
curl -s -X GET \
  "http://localhost:4000/channels/mychannel/chaincodes/mycc?peer=peer0.manufacturer.supplychain.com&fcn=query&args=%5B%22a%22%5D" \
  -H "authorization: Bearer $Manufacturer_TOKEN" \
  -H "content-type: application/json"
echo
echo

echo "GET query Block by blockNumber"
echo
BLOCK_INFO=$(curl -s -X GET \
  "http://localhost:4000/channels/mychannel/blocks/1?peer=peer0.manufacturer.supplychain.com" \
  -H "authorization: Bearer $Manufacturer_TOKEN" \
  -H "content-type: application/json")
echo $BLOCK_INFO
# Assign previous block hash to HASH
HASH=$(echo $BLOCK_INFO | jq -r ".header.previous_hash")
echo

echo "GET query Transaction by TransactionID"
echo
curl -s -X GET http://localhost:4000/channels/mychannel/transactions/$TRX_ID?peer=peer0.manufacturer.supplychain.com \
  -H "authorization: Bearer $Manufacturer_TOKEN" \
  -H "content-type: application/json"
echo
echo


echo "GET query Block by Hash - Hash is $HASH"
echo
curl -s -X GET \
  "http://localhost:4000/channels/mychannel/blocks?hash=$HASH&peer=peer0.manufacturer.supplychain.com" \
  -H "authorization: Bearer $Manufacturer_TOKEN" \
  -H "cache-control: no-cache" \
  -H "content-type: application/json" \
  -H "x-access-token: $Manufacturer_TOKEN"
echo
echo

echo "GET query ChainInfo"
echo
curl -s -X GET \
  "http://localhost:4000/channels/mychannel?peer=peer0.manufacturer.supplychain.com" \
  -H "authorization: Bearer $Manufacturer_TOKEN" \
  -H "content-type: application/json"
echo
echo

echo "GET query Installed chaincodes"
echo
curl -s -X GET \
  "http://localhost:4000/chaincodes?peer=peer0.manufacturer.supplychain.com" \
  -H "authorization: Bearer $Manufacturer_TOKEN" \
  -H "content-type: application/json"
echo
echo

echo "GET query Instantiated chaincodes"
echo
curl -s -X GET \
  "http://localhost:4000/channels/mychannel/chaincodes?peer=peer0.manufacturer.supplychain.com" \
  -H "authorization: Bearer $Manufacturer_TOKEN" \
  -H "content-type: application/json"
echo
echo

echo "GET query Channels"
echo
curl -s -X GET \
  "http://localhost:4000/channels?peer=peer0.manufacturer.supplychain.com" \
  -H "authorization: Bearer $Manufacturer_TOKEN" \
  -H "content-type: application/json"
echo
echo


echo "Total execution time : $(($(date +%s)-starttime)) secs ..."
