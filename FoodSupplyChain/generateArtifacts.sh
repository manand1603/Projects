#!/bin/bash
#
#
#

cd /Users/swetha/HyperLedger_Fabric/FoodSupplyChain/artifacts/channel

../bin/cryptogen generate --config=./cryptogen.yaml

export FABRIC_CFG_PATH=$PWD

../bin/configtxgen -profile ThreeOrgsOrdererGenesis -outputBlock ./genesis.block