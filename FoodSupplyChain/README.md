## Food Supply Chain

A sample Node.js app to demonstrate **__fabric-client__** & **__fabric-ca-client__** Node.js SDK APIs

### Prerequisites and setup:

* [Docker](https://www.docker.com/products/overview) - v1.12 or higher
* [Docker Compose](https://docs.docker.com/compose/overview/) - v1.8 or higher
* [Git client](https://git-scm.com/downloads) - needed for clone commands
* **Node.js** v8.4.0 or higher
* [Download Docker images](http://hyperledger-fabric.readthedocs.io/en/latest/samples.html#binaries)

```
cd FoodSupplyChain/
```

Once you have completed the above setup, you will have provisioned a local network with the following docker container configuration:

* 3 CAs
* A SOLO orderer
* 5 peers (1peer (Org-Manufacturer) 3 peers (Org Middlemen), 1 peer (Org Consumer))

#### Artifacts
* Crypto material has been generated using the **cryptogen** tool from Hyperledger Fabric and mounted to all peers, the orderering node and CA containers. More details regarding the cryptogen tool are available [here](http://hyperledger-fabric.readthedocs.io/en/latest/build_network.html#crypto-generator).
* An Orderer genesis block (genesis.block) and channel configuration transaction (mychannel.tx) has been pre generated using the **configtxgen** tool from Hyperledger Fabric and placed within the artifacts folder. More details regarding the configtxgen tool are available [here](http://hyperledger-fabric.readthedocs.io/en/latest/build_network.html#configuration-transaction-generator).

## Running the sample program

There are two options available for running the food-supply-chain sample
For each of these options, you may choose to run with chaincode written in golang or in node.js.

### Option 1:

##### Terminal Window 1

* Launch the network using docker-compose

```
docker-compose -f artifacts/docker-compose.yaml up
```
##### Terminal Window 2

* Install the fabric-client and fabric-ca-client node modules

```
npm install
```

* Start the node app on PORT 4000

```
PORT=4000 node app
```

##### Terminal Window 3

* Execute the REST APIs from the section [Sample REST APIs Requests](https://github.com/hyperledger/fabric-samples/tree/master/food-supply-chain#sample-rest-apis-requests)


### Option 2:

##### Terminal Window 1

```
cd FoodSupplyChain

./runApp.sh

```

* This launches the required network on your local machine
* Installs the fabric-client and fabric-ca-client node modules
* And, starts the node app on PORT 4000

##### Terminal Window 2


In order for the following shell script to properly parse the JSON, you must install ``jq``:

instructions [https://stedolan.github.io/jq/](https://stedolan.github.io/jq/)

With the application started in terminal 1, next, test the APIs by executing the script - **testAPIs.sh**:
```
cd fabric-samples/food-supply-chain

## To use golang chaincode execute the following command

./testAPIs.sh -l golang

## OR use node.js chaincode

./testAPIs.sh -l node
```


## Sample REST APIs Requests

### Login Request

* Register and enroll new users in Organization - **Org1**:

`curl -s -X POST http://localhost:4000/users -H "content-type: application/x-www-form-urlencoded" -d 'username=admin&orgName=Manufacturer'`

**OUTPUT:**

```
{
  "success": true,
  "secret": "RaxhMgevgJcm",
  "message": "admin enrolled Successfully",
  "token": "<put JSON Web Token here>"
}
```

The response contains the success/failure status, an **enrollment Secret** and a **JSON Web Token (JWT)** that is a required string in the Request Headers for subsequent requests.

### Create Channel request

```
curl -s -X POST \
  http://localhost:4000/channels \
  -H "authorization: Bearer  <put JSON Web Token here> \
  -H "content-type: application/json" \
  -d '{
	"channelName":"mychannel",
	"channelConfigPath":"../artifacts/channel/mychannel.tx"
}'

sleep 5
  "POST request Join channel on Manufacturer"
 
curl -s -X POST \
  http://localhost:4000/channels/mychannel/peers \
  -H "authorization: Bearer  <put JSON Web Token here> \
  -H "content-type: application/json" \
  -d '{
	"peers": ["peer0.manufacturer.supplychain.com"]
}'
 
 

  "POST request Join channel on Middlemen peers"
 
curl -s -X POST \
  http://localhost:4000/channels/mychannel/peers \
  -H "authorization: Bearer  <put JSON Web Token here> \
  -H "content-type: application/json" \
  -d '{
	"peers": ["peer0.middlemen.supplychain.com","peer1.middlemen.supplychain.com","peer2.middlemen.supplychain.com"]
}'
 
 

 
  "POST request Join channel on Consumer peer0"
 
 
curl -s -X POST \
  http://localhost:4000/channels/mychannel/peers \
  -H "authorization: Bearer  <put JSON Web Token here> \
  -H "content-type: application/json" \
  -d '{
	"peers": ["peer0.consumer.supplychain.com"]
}'
 
 
  "POST request Update anchor peers on Manufacturer"
 
curl -s -X POST \
  http://localhost:4000/channels/mychannel/anchorpeers \
  -H "authorization: Bearer  <put JSON Web Token here> \
  -H "content-type: application/json" \
  -d '{
	"configUpdatePath":"../artifacts/channel/ManufacturerMSPanchors.tx"
}'
 
 

  "POST request Update anchor peers on Middlemen"
 
curl -s -X POST \
  http://localhost:4000/channels/mychannel/anchorpeers \
  -H "authorization: Bearer  <put JSON Web Token here> \
  -H "content-type: application/json" \
  -d '{
	"configUpdatePath":"../artifacts/channel/MiddlemenMSPanchors.tx"
}'
 
 

  "POST request Update anchor peers on Consumer"
 
curl -s -X POST \
  http://localhost:4000/channels/mychannel/anchorpeers \
  -H "authorization: Bearer  <put JSON Web Token here> \
  -H "content-type: application/json" \
  -d '{
	"configUpdatePath":"../artifacts/channel/ConsumerMSPanchors.tx"
}'
 
 

  "POST Install chaincode on Manufacturer"
 
curl -s -X POST \
  http://localhost:4000/chaincodes \
  -H "authorization: Bearer  <put JSON Web Token here> \
  -H "content-type: application/json" \
  -d "{
	\"peers\": [\"peer0.manufacturer.supplychain.com\"],
	\"chaincodeName\":\"mycc\",
	\"chaincodePath\":\"$CC_SRC_PATH\",
	\"chaincodeType\": \"$LANGUAGE\",
	\"chaincodeVersion\":\"v0\"
}"
 
 

  "POST Install chaincode on Middlemen peers"
 
curl -s -X POST \
  http://localhost:4000/chaincodes \
  -H "authorization: Bearer  <put JSON Web Token here> \
  -H "content-type: application/json" \
  -d "{
	\"peers\": [\"peer0.middlemen.supplychain.com\",\"peer1.middlemen.supplychain.com\"
    ,\"peer2.middlemen.supplychain.com\"],
	\"chaincodeName\":\"mycc\",
	\"chaincodePath\":\"$CC_SRC_PATH\",
	\"chaincodeType\": \"$LANGUAGE\",
	\"chaincodeVersion\":\"v0\"
}"
 
 


  "POST Install chaincode on Consumer"
 
curl -s -X POST \
  http://localhost:4000/chaincodes \
  -H "authorization: Bearer  <put JSON Web Token here> \
  -H "content-type: application/json" \
  -d "{
	\"peers\": [\"peer0.consumer.supplychain.com\"],
	\"chaincodeName\":\"mycc\",
	\"chaincodePath\":\"$CC_SRC_PATH\",
	\"chaincodeType\": \"$LANGUAGE\",
	\"chaincodeVersion\":\"v0\"
}"
 
 

  "POST instantiate chaincode on Manufacturer"
 
curl -s -X POST \
  http://localhost:4000/channels/mychannel/chaincodes \
  -H "authorization: Bearer  <put JSON Web Token here> \
  -H "content-type: application/json" \
  -d "{
	\"chaincodeName\":\"mycc\",
	\"chaincodeVersion\":\"v0\",
	\"chaincodeType\": \"$LANGUAGE\",
	\"args\":[\"a\",\"100\",\"b\",\"200\"]
}"
 
 

#   "POST invoke chaincode on peers of Manufacturer and Middlemen"
#  
# VALUES=$(curl -s -X POST \
#   http://localhost:4000/channels/mychannel/chaincodes/mycc \
#   -H "authorization: Bearer  <put JSON Web Token here> \
#   -H "content-type: application/json" \
#   -d "{
#   \"peers\": [\"peer0.manufacturer.supplychain.com\",\"peer0.middlemen.supplychain.com\"],
#   \"fcn\":\"move\",
#   \"args\":[\"a\",\"b\",\"10\"]
# }")
  "POST invoke chaincode on peers of Manufacturer and Middlemen"
 
VALUES=$(curl -s -X POST \
  http://localhost:4000/channels/mychannel/chaincodes/mycc \
  -H "authorization: Bearer  <put JSON Web Token here> \
  -H "content-type: application/json" \
  -d "{
  \"peers\": [\"peer0.manufacturer.supplychain.com\",\"peer0.middlemen.supplychain.com\"],
 \"fcn\":\"createProduct\",
	\"args\": [\"Sumanth\", \"Honey\",\"100\",\"250\",\"Kumar\"]
}")

#   $VALUES
# Assign previous invoke transaction id  to TRX_ID
# MESSAGE=$(  $VALUES | jq -r ".message")
# TRX_ID=${MESSAGE#*ID: }
#  

#   "GET query chaincode on peer0 of Manufacturer"
#  
# curl -s -X GET \
#   "http://localhost:4000/channels/mychannel/chaincodes/mycc?peer=peer0.manufacturer.supplychain.com&fcn=query&args=%5B%22a%22%5D" \
#   -H "authorization: Bearer  <put JSON Web Token here> \
#   -H "content-type: application/json"
#  
#  

#   "GET query Block by blockNumber"
#  
# BLOCK_INFO=$(curl -s -X GET \
#   "http://localhost:4000/channels/mychannel/blocks/1?peer=peer0.manufacturer.supplychain.com" \
#   -H "authorization: Bearer  <put JSON Web Token here> \
#   -H "content-type: application/json")
#   $BLOCK_INFO
# # Assign previous block hash to HASH
# HASH=$(  $BLOCK_INFO | jq -r ".header.previous_hash")
#  

#   "GET query Transaction by TransactionID"
#  
# curl -s -X GET http://localhost:4000/channels/mychannel/transactions/$TRX_ID?peer=peer0.manufacturer.supplychain.com \
#   -H "authorization: Bearer  <put JSON Web Token here> \
#   -H "content-type: application/json"
#  
#  


#   "GET query Block by Hash - Hash is $HASH"
#  
# curl -s -X GET \
#   "http://localhost:4000/channels/mychannel/blocks?hash=$HASH&peer=peer0.manufacturer.supplychain.com" \
#   -H "authorization: Bearer  <put JSON Web Token here> \
#   -H "cache-control: no-cache" \
#   -H "content-type: application/json" \
#   -H "x-access-token:  <put JSON Web Token here>
#  
#  

#   "GET query ChainInfo"
#  
# curl -s -X GET \
#   "http://localhost:4000/channels/mychannel?peer=peer0.manufacturer.supplychain.com" \
#   -H "authorization: Bearer  <put JSON Web Token here> \
#   -H "content-type: application/json"
#  
#  

  "GET query Installed chaincodes"
 
curl -s -X GET \
  "http://localhost:4000/chaincodes?peer=peer0.manufacturer.supplychain.com" \
  -H "authorization: Bearer  <put JSON Web Token here> \
  -H "content-type: application/json"
 
 

  "GET query Instantiated chaincodes"
 
curl -s -X GET \
  "http://localhost:4000/channels/mychannel/chaincodes?peer=peer0.manufacturer.supplychain.com" \
  -H "authorization: Bearer  <put JSON Web Token here> \
  -H "content-type: application/json"
 
 

  "GET query Channels"
 
curl -s -X GET \
  "http://localhost:4000/channels?peer=peer0.manufacturer.supplychain.com" \
  -H "authorization: Bearer  <put JSON Web Token here> \
  -H "content-type: application/json"
 
 
### Clean the network

The network will still be running at this point. Before starting the network manually again, here are the commands which cleans the containers and artifacts.

```
docker rm -f $(docker ps -aq)
docker rmi -f $(docker images | grep dev | awk '{print $3}')
rm -rf fabric-client-kv-org[1-2]
```

### Network configuration considerations

You have the ability to change configuration parameters by either directly editing the network-config.yaml file or provide an additional file for an alternative target network. The app uses an optional environment variable "TARGET_NETWORK" to control the configuration files to use. For example, if you deployed the target network on Amazon Web Services EC2, you can add a file "network-config-aws.yaml", and set the "TARGET_NETWORK" environment to 'aws'. The app will pick up the settings inside the "network-config-aws.yaml" file.

#### IP Address** and PORT information

If you choose to customize your docker-compose yaml file by hardcoding IP Addresses and PORT information for your peers and orderer, then you MUST also add the identical values into the network-config.yaml file. The url and eventUrl settings will need to be adjusted to match your docker-compose yaml file.

```
peer0.manufacturer.supplychain.com:
  url: grpcs://x.x.x.x:7051
  eventUrl: grpcs://x.x.x.x:7053

```

#### Discover IP Address

To retrieve the IP Address for one of your network entities, issue the following command:

```
# this will return the IP Address for peer0
docker inspect peer0 | grep IPAddress
```

<a rel="license" href="http://creativecommons.org/licenses/by/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by/4.0/88x31.png" /></a><br />This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by/4.0/">Creative Commons Attribution 4.0 International License</a>.
