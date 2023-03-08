FROM ubuntu:bionic

RUN apt-get update
RUN apt-get upgrade -y

RUN apt-get install gcc wget git gnupg2 lsb-release software-properties-common -y

RUN wget https://repo.anaconda.com/archive/Anaconda3-2020.11-Linux-x86_64.sh
RUN bash Anaconda3-2020.11-Linux-x86_64.sh
RUN source ~/.profile

RUN git clone https://github.com/opendilab/InterFuser.git
RUN cd InterFuser
RUN conda create -n interfuser python=3.7
RUN conda activate interfuser
RUN pip3 install -r requirements.txt
RUN cd interfuser
RUN python setup.py develop

WORKDIR /InterFuser
RUN cd --
RUN cd InterFuser
RUN chmod +x setup_carla.sh
RUN ./setup_carla.sh
RUN easy_install carla/PythonAPI/carla/dist/carla-0.9.10-py3.7-linux-x86_64.egg
