echo Stopping existing container...
docker stop openvpn-custom
docker stop ubuntu-custom
echo ...Done.
echo Removing existing container...
docker rm -f ubuntu-custom
docker rm -f openvpn-custom
echo ...Done.
docker run --name openvpn-custom -it openvpn-custom:latest 
# docker run --name ubuntu-custom -it ubuntu-base:latest 