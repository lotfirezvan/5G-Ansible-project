# OAI 5G Deployment Script
# This script installs Docker and deploys OAI 5G Core with gnbsim
#!/bin/bash

                #Prerequisite Setup    

    #Install Docker
sudo apt update
sudo apt upgrade -y
sudo apt install -y --reinstall ca-certificates curl

#Add Docker’s official GPG key
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF

#Install the Docker packages
sudo apt update
sudo apt install --reinstall docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Docker Running
#sudo systemctl status docker
sudo systemctl enable docker
sudo systemctl start docker


#Test the Docker installation
#sudo docker run hello-world

#Add your user to the docker group to run docker without sudo
sudo usermod -aG docker $USER
#Restart Linux to apply the group changes (or you can log out and log back in, but a restart is often simpler)
#echo "Please restart your computer to apply the group changes for Docker. After restarting, you can run Docker commands without using 'sudo'."

    #Install Python 3.6.9
#sudo apt update
sudo apt install -y --reinstall make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev
curl https://pyenv.run | bash
pyenv install -f 3.6.9
pyenv global 3.6.9
python3 --version

    #Pull base images
echo "Login to Docker Hub to pull base images. If you do not have an account, please create one at https://hub.docker.com/ and then login using the command below. If you do not want to login, please comment out the next line and ensure you have pulled the necessary base images (ubuntu:jammy and mysql:8.0) before proceeding with the rest of the script."
#docker login -u atom230 #To access more pulling limits, please login (otherwise comment out this line)
# optional: docker login if needed
sudo docker pull ubuntu:jammy
sudo docker pull mysql:8.0
#sudo docker images #To verify that the images have been pulled successfully, you can run the command above to list all Docker images on your system. You should see "ubuntu:jammy" and "mysql:8.0" in the list.

    #Network Configuration
sudo sysctl net.ipv4.conf.all.forwarding=1
sudo iptables -P FORWARD ACCEPT
# The default docker network (ie "bridge") is on "172.17.0.0/16" range.
# Make sure it does not conflict with your existing network. If it does, you can change the default docker network by following instructions here: https://docs.docker.com/network/bridge/#configure-the-default-bridge-network


                #Pull container images and set up OAI
sudo docker pull oaisoftwarealliance/oai-amf:v2.2.0
sudo docker pull oaisoftwarealliance/oai-nrf:v2.2.0
sudo docker pull oaisoftwarealliance/oai-upf:v2.2.0
sudo docker pull oaisoftwarealliance/oai-smf:v2.2.0

sudo docker pull oaisoftwarealliance/trf-gen-cn5g:focal
sudo docker pull oaisoftwarealliance/oai-gnb:v2.2.0
sudo docker pull oaisoftwarealliance/oai-nr-ue:v2.2.0

git clone https://gitlab.eurecom.fr/oai/cn5g/oai-cn5g-fed.git
cd oai-cn5g-fed
git checkout -f v2.2.0
./scripts/syncComponents.sh

                #DEPLOY_SA5G_MINI_WITH_GNBSIM
#prereq - store logs in a file::
mkdir -p /tmp/oai/mini-gnbsim
chmod 777 /tmp/oai/mini-gnbsim

#5.Deploying OAI 5G Core Network
cd docker-compose
python3 ./core-network.py --type start-mini --scenario 2
#python3 ./core-network.py --type start-mini --scenario 2--capture /tmp/oai/mini-gnbsim/mini-gnbsim.pcap #PCAP capture option (optional)
#--type start-basic : starts the basic core network with AUSF, UDM, UDR

#6. Getting a gnbsim docker image
docker pull rohankharade/gnbsim
docker image tag rohankharade/gnbsim:latest gnbsim:latest

#7. Executing the gnbsim Scenario
docker-compose -f docker-compose-gnbsim.yaml up -d gnbsim
#docker-compose -f docker-compose-gnbsim.yaml ps -a #Wait a bit for all gnbsim container to be healthy.
#docker ps -a #make sure all services status are healthy
#docker logs gnbsim 2>&1 | grep "UE address:"    #You can see also if the UE got allocated an IP address.

#7.3 Iperf test
#docker exec -it oai-ext-dn iperf3 -s #Start iperf3 server on the external DN
docker exec -it oai-ext-dn iperf3 -s -D #Or other option to start iperf3 server in daemon mode on the external DN
docker exec -it gnbsim iperf3 -c 192.168.70.135 -B 12.1.1.2 #Start iperf3 client on the UE, connecting to the external DN server. You should see successful iperf3 test results if everything is set up correctly.

#8.Analysing the Scenario Results
docker logs oai-amf > /tmp/oai/mini-gnbsim/amf.log 2>&1
docker logs oai-smf > /tmp/oai/mini-gnbsim/smf.log 2>&1
docker logs oai-upf > /tmp/oai/mini-gnbsim/upf.log 2>&1
docker logs oai-ext-dn > /tmp/oai/mini-gnbsim/ext-dn.log 2>&1
docker logs gnbsim > /tmp/oai/mini-gnbsim/gnbsim.log 2>&1


        #Undeploy containers when done
docker-compose down   
docker-compose -f docker-compose-gnbsim.yaml down -t 0
python3 ./core-network.py --type stop-mini --scenario 2
