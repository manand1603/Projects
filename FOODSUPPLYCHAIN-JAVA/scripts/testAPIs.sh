#!/bin/bash
#


jq --version > /dev/null 2>&1
if [ $? -ne 0 ]; then
	echo "Please Install 'jq' https://stedolan.github.io/jq/ to execute this script"
	echo
	exit 1
fi

starttime=$(date +%s)




### Create Channel request

curl -X POST --header 'Content-Type: application/json' --header 'Accept: */*' --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJTdW1hbnRoIiwicm9sZXMiOiJ1c2VyIiwiaWF0IjoxNTk1NTk5NTM3LCJleHAiOjE1OTU2MDA0Mzd9.5q70kjRlrVDIGLvcqv7ophchyVMd-8zLoS7mvQb6-Dk' 'http://localhost:8080/api/construct'



### Recreate Channel request

curl -X PUT --header 'Content-Type: application/json' --header 'Accept: */*' --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJTdW1hbnRoIiwicm9sZXMiOiJ1c2VyIiwiaWF0IjoxNTk1NTk5NTM3LCJleHAiOjE1OTU2MDA0Mzd9.5q70kjRlrVDIGLvcqv7ophchyVMd-8zLoS7mvQb6-Dk' 'http://localhost:8080/api/reconstruct'


### Install chaincode

curl -X POST --header 'Content-Type: application/json' --header 'Accept: */*' --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJTdW1hbnRoIiwicm9sZXMiOiJ1c2VyIiwiaWF0IjoxNTk1NTk5NTM3LCJleHAiOjE1OTU2MDA0Mzd9.5q70kjRlrVDIGLvcqv7ophchyVMd-8zLoS7mvQb6-Dk' -d '{
  "chaincodeName": "myChaincode"
}' 'http://localhost:8080/api/install'


### Instantiate chaincode

curl -X POST --header 'Content-Type: application/json' --header 'Accept: */*' --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJTdW1hbnRoIiwicm9sZXMiOiJ1c2VyIiwiaWF0IjoxNTk1NTk5NTM3LCJleHAiOjE1OTU2MDA0Mzd9.5q70kjRlrVDIGLvcqv7ophchyVMd-8zLoS7mvQb6-Dk' -d '{
  "args": [
    "a", "500", "b", "200"
  ],
  "chaincodeName": "myChaincode",
  "function": "init"
}' 'http://localhost:8080/api/instantiate'

### Invoke request

curl -X POST --header 'Content-Type: application/json' --header 'Accept: */*' --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJTdW1hbnRoIiwicm9sZXMiOiJ1c2VyIiwiaWF0IjoxNTk1NTk5NTM3LCJleHAiOjE1OTU2MDA0Mzd9.5q70kjRlrVDIGLvcqv7ophchyVMd-8zLoS7mvQb6-Dk' -d '{
  "args": [
    "move", "a", "b", "100"
  ],
  "chaincodeName": "myChaincode",
  "function": "invoke"
}' 'http://localhost:8080/api/invoke'


### Chaincode Query

curl -X GET --header 'Accept: */*' --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJTdW1hbnRoIiwicm9sZXMiOiJ1c2VyIiwiaWF0IjoxNTk1NTk5NTM3LCJleHAiOjE1OTU2MDA0Mzd9.5q70kjRlrVDIGLvcqv7ophchyVMd-8zLoS7mvQb6-Dk' 'http://localhost:8080/api/query?ChaincodeName=myChaincode&function=invoke&args=query%2Cb'


echo "Total execution time : $(($(date +%s)-starttime)) secs ..."
