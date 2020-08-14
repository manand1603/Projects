cd ../artifacts/
./byfn.sh -m generate
docker-compose -f docker-compose.yaml pull
./byfn.sh -m up
