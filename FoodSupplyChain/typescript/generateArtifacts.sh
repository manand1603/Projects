#!/bin/bash
#
#
#

cd /Users/swetha/HyperLedger_Fabric/FoodSupplyChain/artifacts/channel

../bin/cryptogen generate --config=./cryptogen.yaml

export FABRIC_CFG_PATH=$PWD

../bin/configtxgen -profile ThreeOrgsOrdererGenesis -outputBlock ./genesis.block

cd /Users/swetha/HyperLedger_Fabric/FoodSupplyChain/artifacts/channel

export CHANNEL_NAME=mychannel

../bin/configtxgen -profile ThreeOrgsChannel -outputCreateChannelTx ./mychannel.tx -channelID $CHANNEL_NAME

../bin/configtxgen -profile ThreeOrgsChannel -outputAnchorPeersUpdate ./ManufacturerMSPanchors.tx -channelID $CHANNEL_NAME -asOrg ManufacturerMSP

../bin/configtxgen -profile ThreeOrgsChannel -outputAnchorPeersUpdate ./MiddlemenMSPanchors.tx -channelID $CHANNEL_NAME -asOrg MiddlemenMSP

../bin/configtxgen -profile ThreeOrgsChannel -outputAnchorPeersUpdate ./ConsumerMSPanchors.tx -channelID $CHANNEL_NAME -asOrg ConsumerMSP
