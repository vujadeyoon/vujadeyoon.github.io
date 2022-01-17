---
layout: post
title: Docker with NVIDIA Container Toolkit for Deep Learning
date: 2022-01-16 00:00:00
description: The Dockerfile and docker commands for the deep learning that can be used in practice
comments: true
tags: aws deep-learning docker
categories: software
---

## Table of contents
  1.  [Notice](#notice)
  2.  [Summarized environments about the docker with the Nvidia Container Toolkit](#envs)
  3.  [Summarized main features of the provided Dockerfile](#features_dockerfile)
  4.  [How to install the docker](#installation_docker)
  5.  [How to install the Nvidia Container Toolkit](#installation_nct)
  6.  [Preparations to build a Dockerfile](#docker_preparations)
  7.  [How to build a Dockerfile](#docker_build)
  8.  [How to run a docker container](#docker_container)
  9.  [How to copy files and folders between the host and the docker container](#docker_copy)
  10. [How to save and load a docker image](#save_load)
  11. [Basic docker command](#docker_command)
  12. [Reference](#ref)

<hr>

## 1. Notice <a name="notice"></a>
- A guide for Docker with the Nvidia Container Toolkit (i.e. Nvidia-Docker 2.0)
- This is an updated post of the [Docker with the Nvidia Container Toolkit [1]](https://github.com/vujadeyoon/Docker-Nvidia-Container-Toolkit)
  to cover how to build a Dockerfile for deep learning.
  Thus, if you are not familar with the docker commands, I highly recommend you should read the
  [Docker with the Nvidia Container Toolkit [1]](https://github.com/vujadeyoon/Docker-Nvidia-Container-Toolkit)
- I recommend that you should ignore the commented instructions with an octothorpe, #.
- I recommend that you should fill in the appropriate letters between the parentheses, <>.

<hr>

## 2. Summarized environments about the docker with the Nvidia Container Toolkit  <a name="envs"></a>
- Operating System (OS): Ubuntu MATE 20.04.2 LTS (Focal)
- Graphics Processing Unit (GPU): NVIDIA TITAN Xp, 1ea
- GPU driver: Nvidia-460.91.03
- CUDA toolkit: CUDA-11.1
- cuDNN: cuDNN v8.2.1
- Docker: Docker version 20.10.7, build 20.10.7-0ubuntu5~20.04.2
- Docker image: nvidia/cuda:10.2-cudnn7-devel-ubuntu18.04  

<hr>

## 3. Summarized main features of the provided Dockerfile  <a name="features_dockerfile"></a>
You can check the whole Dockerfile in the [7-2. Dockerfile](#dockerfile).
- TensorRT: 7.0.0.11
- Torch2TRT: 0.1.0
- FFmpeg: N-105288-g45e45a6060
- nv-codec-headers: 10.0.26.2

<hr>

## 4. How to install the docker <a name="installation_docker"></a>
1. Docker installation
```bash
1 $ curl https://get.docker.com | sh
2 $ sudo systemctl start docker && sudo systemctl enable docker
```

2. Check the docker version.
```bash
1 $ sudo docker --version
```
```bash
    Docker version 20.10.7, build 20.10.7-0ubuntu5~20.04.2
```
<hr>

## 5. How to install the Nvidia Container Toolkit <a name="installation_nct"></a>
1. Set up the repository and the Gnu Privacy Guard (GPG) key.
```bash
1 $ distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
2 $ curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
3 $ curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list
4 $ sudo apt-get update
```

2. Install the Nvidia-Docker 2.0 for the Nvidia Container Toolkit.
```bash
1 $ sudo apt-get install -y nvidia-docker2
2 $ sudo systemctl restart docker
```

3. Test the Nviida-Docker 2.0.
```bash
1 $ sudo docker run --rm --gpus all nvidia/cuda:10.2-base nvidia-smi
```
```bash
    Tue Dec 22 08:40:19 2020
    +-----------------------------------------------------------------------------+
    | NVIDIA-SMI 440.100      Driver Version: 440.100      CUDA Version: 10.2     |
    |-------------------------------+----------------------+----------------------+
    | GPU  Name        Persistence-M| Bus-Id        Disp.A | Volatile Uncorr. ECC |
    | Fan  Temp  Perf  Pwr:Usage/Cap|         Memory-Usage | GPU-Util  Compute M. |
    |===============================+======================+======================|
    |   0  TITAN Xp            Off  | 00000000:01:00.0  On |                  N/A |
    | 23%   30C    P8    10W / 250W |    518MiB / 12192MiB |      0%      Default |
    +-------------------------------+----------------------+----------------------+
    
    +-----------------------------------------------------------------------------+
    | Processes:                                                       GPU Memory |
    |  GPU       PID   Type   Process name                             Usage      |
    |=============================================================================|
    +-----------------------------------------------------------------------------+
```

<hr>

## 6. preparations to build a Dockerfile <a name="docker_preparations"></a>
1. Directory structure
```bash
.
├── Bash
│   └── bash_docker_utility.sh
├── Dockerfile
├── docker_utility
│   ├── awscliv2.zip
│   ├── eksctl
│   ├── ffmpeg.tar.gz
│   ├── goofys
│   ├── kubectl
│   ├── nv-codec-headers-10.0.26.2.tar.gz
│   ├── TensorRT-7.0.0.11.Ubuntu-18.04.x86_64-gnu.cuda-10.2.cudnn7.6.tar.gz
│   └── torch2trt.tar.gz
├── LICENSE
└── README.md
```

2. The version of the required utilities for the docker

    - If you want to refer to the official site for each utility, please click the hyperlink in the below table.

    |No.  |Utility                                                                                                      |Version              |SHA-1                                    |Git commit |
    |:---:|:-----------------------------------------------------------------------------------------------------------:|:-------------------:|:---------------------------------------:|:---------:|
    |1    |[awscliv2.zip](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)                |2                    |80153150f54149ca2ce5da1248130487fd791e92 |-          |
    |2    |[eksctl](https://github.com/weaveworks/eksctl)                                                               |0.79.0               |b8c03f8706d4be4c7cc8a94aa316582809326964 |-          |
    |3    |[ffmpeg.tar.gz](https://git.ffmpeg.org/ffmpeg.git)                                                           |N-105288-g45e45a6060 |dd3c209e500afac258db3a2fa1077d06b9650663 |45e45a60   |
    |4    |[goofys](https://github.com/kahing/goofys)                                                                   |0.24.0               |438a43f737772bf117753c3b40f524ca39814c12 |-          |
    |5    |[kubectl](https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html)                             |1.17.11              |0790bcc0d98c8f19320359b4537359ea058cfadb |-          |
    |6    |[nv-codec-headers-10.0.26.2.tar.gz](https://github.com/FFmpeg/nv-codec-headers)                              |10.0.26.2            |1006a328ba4387ae46e4b1e4b208bd064223370d |-          |
    |7    |[TensorRT-7.0.0.11.Ubuntu-18.04.x86_64-gnu.cuda-10.2.cudnn7.6.tar.gz](https://developer.nvidia.com/tensorrt) |7.0.0.11             |1f17eb8c0b2f1ea0c7bf935cd209a6d6f0d23f93 |-          |
    |8    |[torch2trt.tar.gz](https://github.com/NVIDIA-AI-IOT/torch2trt)                                               |0.1.0                |f9fa0032a7b3e5a1b434fdab4a4d5a859f01d553 |75637700   |                                       |
    
    <br />
    - How to get the SHA-1 in the Ubuntu
      ```bash
      1 $ sha1sum NAME_FILE 
      ```
      ```bash
          CHARACTER_SHA1_40 NAME_FILE
      ```

3. Preparations for the utilities <br />
   There are two options to prepare the utilities: i) [6-4. bash_docker_utility.sh](#bash_docker_utility); ii) [Google Request](https://docs.google.com/forms/d/e/1FAIpQLSc2mI35D6ArGfCReffYCUNj9TH4uRYcjsH60S4AOTEQpEWu4A/viewform?usp=sf_link).
   I recommend that you should select the option, [6-4. bash_docker_utility.sh](#bash_docker_utility) because of downloading the latest version of the utilities.
   However, If you have any difficulties, please fill out the [Google Request form](https://docs.google.com/forms/d/e/1FAIpQLSc2mI35D6ArGfCReffYCUNj9TH4uRYcjsH60S4AOTEQpEWu4A/viewform?usp=sf_link).
   After reviewing the completed request, I will give you via email that you provided a compressed file, docker_utility.zip _<span style="color:#b409b2">(SHA-1: 4f77bf2bd59e8af8c7b31bc4d5137b6f6ac6484a)</span>_
   including all utilities. Thus, you should fill in the correct email address. 
   After receiving the email, you may be able to get the compressed file using the [gdown](https://github.com/wkentaro/gdown)
   that is a python3 package for downloading a item from the Google Drive. <br />
   Unlike the compressed file, docker_utility.zip, the [6-4. bash_docker_utility.sh](#bash_docker_utility) does not have codes to download the [TensorRT](https://developer.nvidia.com/tensorrt).
   Thus, you should download the [TensorRT from the official site](https://developer.nvidia.com/tensorrt) when using the [6-4. bash_docker_utility.sh](#bash_docker_utility).
    - Using the [6-4. bash_docker_utility.sh](#bash_docker_utility)
    ```bash
    1 $ bash ./Bash/bash_docker_utility.sh
    ```
    - Using the Google Drive after reviewing the [Google Request](https://docs.google.com/forms/d/e/1FAIpQLSc2mI35D6ArGfCReffYCUNj9TH4uRYcjsH60S4AOTEQpEWu4A/viewform?usp=sf_link)
    ```bash
    1 $ gdown <URL_TO_BE_RPOVIDED_AFTER_REVIEWING_THE_GOOLGE_REQUEST>
    ```

<details>
 <summary>&nbsp; 4. bash_docker_utility.sh <a name="bash_docker_utility"></a></summary>
 {% highlight bash linenos %}
 #!/bin/bash
 #
 #
 # Dveloper: vujadeyoon
 # Email: vujadeyoon@gmail.com
 # Github: https://github.com/vujadeyoon
 # Personal website: https://vujadeyoon.github.io
 #
 # Title: bash_docker_utility.sh
 # Description: Preparation for the required utilities.
 #
 #
 path_curr=$(pwd)
 path_parent=$(dirname ${path_curr})
 #
 #
 path_docker_utility=${path_curr}/docker_utility
 #
 #
 # Make a directory, docker_utility.
 mkdir -p ${path_docker_utility}
 #
 #
 # AWSCLI version 2
 curl --silent https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o ${path_docker_utility}/awscliv2.zip
 #
 #
 # eksctl
 curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C ${path_docker_utility}/
 #
 #
 # FFmpeg
 git clone https://git.ffmpeg.org/ffmpeg.git ${path_docker_utility}/ffmpeg
 cd ${path_docker_utility}/ffmpeg && git checkout 45e45a606077ccd0aab7eaffb8697e633b876fb2
 cd ${path_docker_utility} && tar -czvf ffmpeg.tar.gz ffmpeg
 rm -rf ${path_docker_utility}/ffmpeg
 #
 #
 # goofys
 wget --quiet https://github.com/kahing/goofys/releases/download/v0.24.0/goofys -P ${path_docker_utility}
 #
 #
 # kubectl
 curl --silent --location -o ${path_docker_utility}/kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/1.17.11/2020-09-18/bin/linux/amd64/kubectl
 chmod +x ${path_docker_utility}/kubectl
 #
 #
 # nv-codec-headers
 wget --quiet https://github.com/FFmpeg/nv-codec-headers/releases/download/n10.0.26.2/nv-codec-headers-10.0.26.2.tar.gz -P ${path_docker_utility}
 #
 #
 # TensorRT
 # You should download the TensorRT from the official site, https://developer.nvidia.com/tensorrt.
 #
 #
 # Torch2TRT
 git clone https://github.com/NVIDIA-AI-IOT/torch2trt ${path_docker_utility}/torch2trt
 cd ${path_docker_utility}/torch2trt && git checkout 756377002708121d43a3e66ba72f56af65696402
 cd ${path_docker_utility} && tar -czvf torch2trt.tar.gz torch2trt
 rm -rf ${path_docker_utility}/torch2trt
 #
 #
 cd ${path_curr} || return
 {% endhighlight %}
</details>


<hr>

## 7. How to build a Dockerfile <a name="docker_build"></a>
1. Build a Dockerfile shown in the [7-2. Dockerfile](#dockerfile).
```bash
1 $ sudo docker build -t <REPOSITORY>:<TAG> .
```
<details>
 <summary>&nbsp; 2. Dockerfile <a name="dockerfile"></a></summary>
 {% highlight bash linenos %}
 # Dveloper: vujadeyoon
 # Email: vujadeyoon@gmail.com
 # Github: https://github.com/vujadeyoon
 # Personal website: https://vujadeyoon.github.io
 #
 # Title: Dockerfile
 # Description: A Dockerfile for the NVIDIA Container Toolkit for Deep Learning
 #
 #
 FROM nvidia/cuda:10.2-cudnn7-devel-ubuntu18.04
 
 
 LABEL maintainer="vujadeyoon"
 LABEL email="vujadeyoon@gmial.com"
 LABEL version="1.0"
 LABEL description="Docker with NVIDIA Container Toolkit for Deep Learning"
 
 
 ENV DEBIAN_FRONTEND=noninteractive
 
 
 # 1. Install the essential ubuntu packages.
 RUN apt-get update &&  \
     apt-get upgrade -y &&  \
     apt-get install -y --no-install-recommends \
         build-essential \
         apt-utils \
         cmake \
         git \
         curl \
         vim \
         ssh \
         sudo \
         tar \
         libcurl3-dev \
         libfreetype6-dev \
         pkg-config \
         ca-certificates \
         libjpeg-dev \
         libpng-dev && \
     apt-get clean && \
     rm -rf /var/lib/apt/lists/*
 
 
 # 2. Install the useful ubuntu packages.
 RUN apt-get update &&  \
     apt-get install -y \
         ffmpeg \
         libgtk2.0-dev \
         python3-matplotlib \
         wget \
         tmux \
         zsh \
         locales \
         ncdu \
         htop \
         zip \
         unzip \
         rsync && \
     apt-get clean && \
     rm -rf /var/lib/apt/lists/*
 
 
 # 3. Set the locale
 RUN locale-gen en_US.UTF-8
 ENV LANG en_US.UTF-8
 ENV LANGUAGE en_US:en
 ENV LC_ALL en_US.UTF-8
 
 
 # 4. Install python.
 RUN apt-get update && \
     apt-get install software-properties-common -y && \
     add-apt-repository ppa:deadsnakes/ppa -y && \
     apt-get install -y \
          python-pip \
          python3-pip && \
     apt-get clean && \
     rm -rf /var/lib/apt/lists/*
 
 
 ## 5. Set python3.7 as default
 #RUN apt-get update && \
 #    apt-get install -y \
 #        python3.7 \
 #        python3.7-dev && \
 #    apt-get clean && \
 #    rm -rf /var/lib/apt/lists/* && \
 #    rm /usr/bin/python3 && \
 #    ln -s /usr/bin/python3.7 /usr/bin/python3
 
 
 # 6. Install more python packages
 RUN pip install --upgrade pip && \
     pip3 install --upgrade pip
 
 
 # 7. Python3 packages for mathematical functions and plotting
 RUN pip3 install \
     opencv-python==4.5.1.48 \
     opencv-contrib-python==4.5.1.48 \
     ffmpeg-python \
     Pillow==7.2.0 \
     imageio \
     kornia==0.2.2 \
     matplotlib==3.3.1 \
     scikit-image \
     scikit-learn \
     pandas \
     openpyxl \
     plotly \
     seaborn \
     shapely
 
 
 # 8. Python3 packages for monitoring and debugging
 RUN pip3 install \
     jupyter \
     wandb \
     gpustat \
     getgpu \
     tqdm \
     ipdb \
     icecream
 
 
 # 9. Other python3 packages
 RUN pip3 install \
     scipy \
     Cython \
     prettyprinter \
     colorlog \
     randomcolor \
     future==0.18.2 \
     imutils \
     psutil \
     PyYAML \
     pycrypto
 
 
 # 10. Install python3 packages for the deep learning research.
 RUN pip3 install \
     PyWavelets \
     pycuda==2020.1 \
     torch==1.4.0 \
     torchvision==0.5.0 \
     torchsummary==1.5.1
 
 
 # 11. Install python3 packages related to the server.
 RUN pip3 install \
     flask==1.1.2 \
     Flask-RESTful==0.3.8 \
     gevent==21.1.2 \
     boto3==1.17.9 \
     kubernetes==12.0.1
 
 
 # 12. Make required directories.
 RUN mkdir -p /home/Vujadeyoon/
 RUN mkdir -p /home/Vujadeyoon/vdisk/
 
 
 # 13. Install a python3 package, TensorRT 7.0.0.11.
 #     i) Preparations.
 RUN mkdir -p /home/Vujadeyoon/pip3_packages/
 COPY ./docker_utility/TensorRT-7.0.0.11.Ubuntu-18.04.x86_64-gnu.cuda-10.2.cudnn7.6.tar.gz /home/Vujadeyoon/pip3_packages/
 WORKDIR /home/Vujadeyoon/pip3_packages/
 #     ii) Uncompress the downloaded tar.gz file.
 RUN tar -xzvf TensorRT-7.0.0.11.Ubuntu-18.04.x86_64-gnu.cuda-10.2.cudnn7.6.tar.gz
 RUN mkdir -p ./TensorRT-7.0.0.11/_arxiv/
 RUN mv ./TensorRT-7.0.0.11.Ubuntu-18.04.x86_64-gnu.cuda-10.2.cudnn7.6.tar.gz TensorRT-7.0.0.11/_arxiv/
 #     iii) Register an environmental variable.
 ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:/home/Vujadeyoon/pip3_packages/TensorRT-7.0.0.11/lib
 #     iv) Copy plugins of the TensorRT to the CUDA toolkit directory.
 RUN mkdir -p /usr/local/cuda-originals/cuda-10.2/
 RUN cp -r /usr/local/cuda-10.2/targets/ /usr/local/cuda-originals/cuda-10.2/
 RUN cp -r /home/Vujadeyoon/pip3_packages/TensorRT-7.0.0.11/include/* /usr/local/cuda-10.2/targets/x86_64-linux/include/
 RUN cp -r /home/Vujadeyoon/pip3_packages/TensorRT-7.0.0.11/targets/x86_64-linux-gnu/lib/* /usr/local/cuda-10.2/targets/x86_64-linux/lib/
 #     v) Install python3 packages related to the TensorRT.
 WORKDIR /home/Vujadeyoon/pip3_packages/TensorRT-7.0.0.11/
 RUN pip3 install \
     ./python/tensorrt-7.0.0.11-cp36-none-linux_x86_64.whl \
     ./uff/uff-0.6.5-py2.py3-none-any.whl \
     ./graphsurgeon/graphsurgeon-0.4.1-py2.py3-none-any.whl
 #     vi) Go to the base directory.
 WORKDIR /home/Vujadeyoon/
 
 
 # 14. Install a python3 package, Torch2TRT.
 #     i) Preparations.
 RUN mkdir -p /home/Vujadeyoon/pip3_packages/
 COPY ./docker_utility/torch2trt.tar.gz /home/Vujadeyoon/pip3_packages/
 WORKDIR /home/Vujadeyoon/pip3_packages/
 #     ii) Uncompress the downloaded tar.gz file.
 RUN tar -xzvf /home/Vujadeyoon/pip3_packages/torch2trt.tar.gz
 RUN mkdir -p ./torch2trt/_arxiv/
 RUN mv ./torch2trt.tar.gz torch2trt/_arxiv/
 #     iii) Install the python3 package, Torch2TRT.
 WORKDIR /home/Vujadeyoon/pip3_packages/torch2trt/
 RUN python3 setup.py install --plugins
 #     iv) Go to the base directory.
 WORKDIR /home/Vujadeyoon/
 
 
 # 15. Install the AWS CLI version 2 on Linux.
 RUN mkdir -p /home/Vujadeyoon/AWS/
 COPY ./docker_utility/awscliv2.zip /home/Vujadeyoon/AWS/
 RUN unzip /home/Vujadeyoon/AWS/awscliv2.zip -d /home/Vujadeyoon/AWS/
 RUN /home/Vujadeyoon/AWS/aws/install
 RUN rm -rf /home/Vujadeyoon/AWS/
 
 
 # 16. Enroll the AWS credentials and config for development.
 # RUN mkdir /root/.aws
 # RUN echo '[default]' >> /root/.aws/credentials
 # RUN echo 'aws_access_key_id = <SECRET>' >> /root/.aws/credentials
 # RUN echo 'aws_secret_access_key = <SECRET>' >> /root/.aws/credentials
 # RUN echo '[default]' >> /root/.aws/config
 # RUN echo 'region = ap-northeast-2' >> /root/.aws/config
 # RUN echo 'output = json' >> /root/.aws/config
 
 
 # 17. Install the Goofys
 COPY ./docker_utility/goofys /usr/local/bin/
 RUN chmod +x /usr/local/bin/goofys
 
 
 # 18. Install the EKSCTL.
 COPY ./docker_utility/eksctl /usr/local/bin/
 RUN chmod +x /usr/local/bin/eksctl
 RUN eksctl completion bash >> /root/.bash_completion
 
 
 # 19. Install the KUBECTL.
 COPY ./docker_utility/kubectl /usr/local/bin/
 RUN chmod +x /usr/local/bin/kubectl
 RUN kubectl completion bash >> /root/.bash_completion
 
 
 # 20. FFmpeg-GPU
 RUN apt-get update &&  \
     apt-get install -y \
         yasm \
         libtool \
         libc6 \
         libc6-dev \
         libnuma1 \
         libnuma-dev \
         libmp3lame-dev \
         psmisc \
         libass-dev \
         libgl1-mesa-glx && \
     apt-get clean && \
     rm -rf /var/lib/apt/lists/*
 RUN mkdir -p /home/Vujadeyoon/FFmpeg_GPU/
 COPY ./docker_utility/nv-codec-headers-10.0.26.2.tar.gz /home/Vujadeyoon/FFmpeg_GPU/
 COPY ./docker_utility/ffmpeg.tar.gz /home/Vujadeyoon/FFmpeg_GPU/
 WORKDIR /home/Vujadeyoon/FFmpeg_GPU/
 RUN tar -xzvf nv-codec-headers-10.0.26.2.tar.gz
 RUN tar -xzvf ffmpeg.tar.gz
 WORKDIR /home/Vujadeyoon/FFmpeg_GPU/nv-codec-headers-10.0.26.2/
 RUN make install
 # RUN git clone https://git.videolan.org/git/ffmpeg/nv-codec-headers.git
 # RUN cd nv-codec-headers && make install && cd /data
 WORKDIR /home/Vujadeyoon/FFmpeg_GPU/ffmpeg/
 RUN ./configure --enable-cuda-sdk --enable-cuvid --enable-nvenc --enable-nonfree --enable-libnpp  --enable-libass --enable-libmp3lame --extra-cflags=-I/usr/local/cuda/include --extra-ldflags=-L/usr/local/cuda/lib64 && make -j 8 && make install
 
 
 # 21. Update and clean the Ubuntu packages.
 RUN apt-get update &&  \
     apt-get clean && \
     rm -rf /var/lib/apt/lists/*
 
 
 # 22. Go to the base directory.
 WORKDIR /home/Vujadeyoon/
 
 
 # 23. Run the command.
 CMD [ "/bin/bash" ]
 {% endhighlight %}
</details>

<hr>

## 8. How to run a docker container <a name="docker_container"></a>
1. Run a docker container corresponding to the docker image, \<REPOSITORY\>:\<TAG\> with some useful options.
```bash
1 $ sudo docker run -it --rm --privileged --runtime nvidia -p <PORT_HOST>:<PORT_CONTAINER> -v <PATH_HOST>:<PATH_CONTAINER> <REPOSITORY>:<TAG> "/bin/bash"
```
<hr>

## 9. How to copy files and folders between the host and a docker container <a name="docker_copy"></a>
You can get the \<CONTAINER_ID\> using the below command. If you are not familar with the command, please refer to the [11. Basic docker command](#docker_command).
The items can be both folders or files.
```bash
1 $ sudo docker ps --all
```
```bash
  CONTAINER ID   IMAGE          COMMAND                  CREATED        STATUS                      PORTS     NAMES
```

1. Copy itmes from the host to the docker container.
```bash
1 $ docker cp <PATH_HOST> <CONTAINER_ID>:<PATH_CONTAINER>
```

2. Copy itmes from the docker container to the host.
```bash
1 $ docker cp <CONTAINER_ID>:<PATH_CONTAINER> <PATH_HOST>
```

<hr>

## 10. How to save and load a docker image <a name="save_load"></a>
1. Save a docker image.
```bash
1 $ sudo docker save <REPOSITORY:TAG> -o <NAME_TAR>.tar
```

2. Load a pre-built docker image.
```bash
1 $ sudo docker load -i <NAME_TAR>.tar
```

<hr>

## 11. Basic docker command <a name="docker_command"></a>
1. Exit the docker container.
```bash
1 $ ctrl + d
```

2. List docker images.
```bash
1 $ sudo docker images
```

3. List all docker containers.
```bash
1 $ sudo docker ps --all
```

4. Stop a docker container.
```bash
1 $ sudo docker stop <CONTAINER_ID>
```

5. Start the stopped docker container.
```bash
1 $ sudo docker start <CONTAINER_ID>
```

6. Attach a working docker container.
```bash
1 $ sudo docker attach <CONTAINER_ID>
```

7. Remove docker containers.
   1. Remove docker containers corresponding to the container ID list. 
    ```bash
    1 $ sudo docker rm <CONTAINER_ID_1>, <CONTAINER_ID_2> ,..., <CONTAINER_ID_N> 
    ```
   2. Remove all docker containers.
    ```bash
    1 $ sudo docker rm `sudo docker ps -a -q`
    ```

7. Remove a docker images.
   1. Remove docker images corresponding to the docker image list. 
    ```bash
    1 $ sudo docker rmi <IMAGE_1>, <IMAGE_2> ,..., <IMAGE_N>
    ```
   2. Remove docker images with the corresponding docker containers from the given docker image list.
    ```bash
    1 $ sudo docker rmi -f <IMAGE_1>, <IMAGE_2> ,..., <IMAGE_N>
    ```

<hr>

## 12. Reference <a name="ref"></a>
1. <a href="https://github.com/vujadeyoon/Docker-Nvidia-Container-Toolkit" title="Docker-Nvidia-Container-Toolkit"> Docker-Nvidia-Container-Toolkit</a>
2. <a href="https://www.docker.com" title="Docker"> Docker</a>
3. <a href="https://github.com/NVIDIA/nvidia-docker" title="Nvidia-Docker"> Github for the Nvidia-Docker</a>
4. <a href="https://docs.nvidia.com/datacenter/cloud-native" title="Nvidia-Docker"> Document for the Nvidia-Docker</a>

<hr>
