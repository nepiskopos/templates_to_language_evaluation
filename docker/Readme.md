# Docker setup and execution on Ubuntu 20.04


## (Optional) If you have a Nvidia GPU
### Install Nvidia driver and then use the following script to select Hybrid Profile (Intel graphics and Nvidia compute)
```
sudo ubuntu-drivers devices
sudo ubuntu-drivers autoinstall
sudo apt-get -y install nvidia-driver-440
```
### Install Nvidia container toolkit
```
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list
sudo apt-get update && sudo apt -y install nvidia-container-toolkit
```
### If you have both an Intel GPU and an Nvidia GPU
https://github.com/lperez31/prime-select-hybrid<br/>


## Install Docker
```
sudo apt-get update
sudo apt-get -y install apt-transport-https ca-certificates curl gnupg-agent software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
apt-cache policy docker-ce
sudo apt -y install docker-ce docker-ce-cli containerd.io
```


## Create a group for docker users
```sudo groupadd docker```

## Add your user to the docker group
```sudo usermod -aG docker $USER```

## Apply the new group membership
```
newgrp docker
su - ${USER}
exit # IT IS NEEDED, AT LEAST AFTERWARDS
```

## Confirm your user was added to the docker group
```id -nG```

## Enable docker service 
```sudo systemctl enable docker.service```

## (Optional) if docker service can not be activated, reboot
```reboot```

## Test docker installation
```docker run hello-world```


## Build a custom image from our Dockerfile
```docker build -t bishop/dbms -f ./docker/Dockerfile ./```

## Execute a docker container using the custom image
### (Default) without access to host's GPU(s)
```docker run --name dbms -it bishop/dbms```
### (Optional) with access to host's Nvidia GPU(s) (Nvidia container toolkit must be installed)
```docker run --name dbms --gpus all -it bishop/dbms```
