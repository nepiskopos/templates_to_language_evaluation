# Docker setup and execution on Ubuntu 20.04


## (Optional) If you have a Nvidia GPU
### Install Nvidia driver and then use the following script to select Hybrid Profile (Intel graphics and Nvidia compute)
```console
sudo ubuntu-drivers devices
sudo ubuntu-drivers autoinstall
sudo apt-get -y install nvidia-driver-440
```

### Install Nvidia container toolkit
```console
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list
sudo apt-get update && sudo apt -y install nvidia-container-toolkit
```

### If you have both an Intel GPU and an Nvidia GPU
[follow this guide for GPU selection](https://github.com/lperez31/prime-select-hybrid)

## Install Docker
```console
sudo apt-get -y install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
sudo apt-get -y install docker-ce
```

## Create a group for docker users
```console
sudo groupadd docker
```

## Add your user to the docker group
```console
sudo usermod -aG docker $USER
```

## Apply the new group membership
```console
newgrp docker
su - ${USER}
exit # IT IS NEEDED, AT LEAST AFTERWARDS
```

## Confirm your user was added to the docker group
```console
id -nG
```

## Start docker service and enable automatic start on boot
```console
sudo systemctl enable docker.service
sudo systemctl start docker.service
```

## (Optional) if docker service can not be activated, reboot
```console
reboot
```

## Test docker installation
```console
docker run hello-world
```


## Build a custom image from our Dockerfile
```console
docker build -t dbsi:latest -f ./templates_to_language_evaluation/docker/Dockerfile ./templates_to_language_evaluation/
```

## Build a docker container using the custom image we built before
### (Default) without access to host's GPU(s)
```console
docker run --name dbs -it -v ./templates_to_language_evaluation/:/root/shared/ dbsc
```
### (Optional) with access to host's Nvidia GPU(s) (Nvidia container toolkit must be installed)
```console
docker run --name dbs --gpus all -it -v ./templates_to_language_evaluation/:/root/shared/ dbsc
```
