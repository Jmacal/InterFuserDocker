# Base Image Ubuntu 18.04 Bionic Beaver
FROM ubuntu:bionic

# User Details
ENV USER="jrsm20"
ENV NAME="James MacAleese"
ENV EMAIL="jamesmacaleese@gmail.com"
# Create User
RUN adduser ${USER}
RUN adduser ${USER} sudo

# Update
RUN apt-get update
RUN apt-get upgrade -y

# Install Dockerfile Utilities
RUN apt-get install gcc wget git gnupg2 lsb-release software-properties-common -y

# Install Anaconda3
RUN apt-get install libgl1-mesa-glx libegl1-mesa libxrandr2 libxrandr2 libxss1 libxcursor1 libxcomposite1 libasound2 libxi6 libxtst6 -y
RUN wget https://repo.anaconda.com/archive/Anaconda3-2020.11-Linux-x86_64.sh
RUN chmod +x ./Anaconda3-2020.11-Linux-x86_64.sh
USER ${USER}
RUN ./Anaconda3-2020.11-Linux-x86_64.sh -b
ENV PATH="/home/${USER}/anaconda3/bin:$PATH"

# Configure git
RUN git config --global user.name ${NAME}
RUN git config --global user.email ${EMAIL}

# Clone InterFuser Repository
USER root
RUN git clone https://github.com/wqueree/InterFuser.git
RUN chown -R ${USER} InterFuser

# Install InterFuser
USER ${USER}
WORKDIR /InterFuser
RUN git checkout develop
RUN git pull
RUN conda env create -f docker/environment.yml
WORKDIR /InterFuser/interfuser
SHELL ["conda", "run", "-n", "interfuser", "/bin/bash", "-c"]
RUN python setup.py develop

# Install CARLA
WORKDIR /InterFuser
RUN chmod +x setup_carla.sh
RUN ./setup_carla.sh
RUN ls carla/PythonAPI/carla/dist
RUN easy_install carla/PythonAPI/carla/dist/carla-0.9.10-py3.7-linux-x86_64.egg
COPY interfuser.pth.tar /InterFuser/leaderboard/team_code/interfuser.pth.tar
USER root
RUN apt-get install libpng16-16 libjpeg8 libtiff5 libglib2.0-0 libsm6 libomp5 -y

# Display Configuration
# RUN apt-get install module-init-tools xserver-xorg mesa-utils libvulkan1 -y
# RUN wget http://download.nvidia.com/XFree86/Linux-x86_64/450.57/NVIDIA-Linux-x86_64-450.57.run
# RUN /bin/bash NVIDIA-Linux-x86_64-450.57.run --accept-license --no-questions --ui=none
# RUN nvidia-xconfig --preserve-busid -a --virtual=1280x1024
ENV XDG_RUNTIME_DIR /run/user/$(id -u)
ENV SDL_VIDEODRIVER offscreen

# Install Development Utilities
RUN apt-get install neofetch net-tools vim screen strace -y

# Post Installation Pull
USER ${USER}
RUN git pull

# Finalise
WORKDIR /
RUN conda init bash
RUN pip install -U setuptools
USER root
RUN conda init bash
