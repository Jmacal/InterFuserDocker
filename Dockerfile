# Base Image Ubuntu 18.04 Bionic Beaver
FROM ubuntu:bionic

# Update
RUN apt-get update
RUN apt-get upgrade -y

# Install Dockerfile Utilities
RUN apt-get install gcc wget git gnupg2 lsb-release software-properties-common -y

# Install Anaconda3
RUN wget https://repo.anaconda.com/archive/Anaconda3-2020.11-Linux-x86_64.sh
RUN bash Anaconda3-2020.11-Linux-x86_64.sh
RUN source ~/.profile

# Clone InterFuser Repository
RUN git clone https://github.com/opendilab/InterFuser.git
RUN cd InterFuser
RUN conda create -n interfuser python=3.7
RUN conda activate interfuser
RUN pip3 install -r requirements.txt
RUN cd interfuser
RUN python setup.py develop

# Install CARLA
WORKDIR /InterFuser
RUN cd --
RUN cd InterFuser
RUN chmod +x setup_carla.sh
RUN ./setup_carla.sh
RUN easy_install carla/PythonAPI/carla/dist/carla-0.9.10-py3.7-linux-x86_64.egg

RUN cd carla
RUN CUDA_VISIBLE_DEVICES=0 ./CarlaUE4.sh --world-port=20000 -opengl