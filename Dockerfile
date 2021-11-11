FROM nvidia/cuda:11.3.0-devel-ubuntu20.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update
RUN apt-get install -y git
RUN apt-get install -y curl
RUN apt-get install -y ninja-build
RUN apt-get install -y g++
RUN apt-get install -y python3
RUN apt-get install -y python3-pip
RUN apt-get install -y software-properties-common
RUN apt-get install -y libtinfo6
RUN apt-get install -y libtinfo-dev
RUN apt-get install -y libncurses6
RUN apt-get install -y libncurses-dev
RUN apt-get install -y libtool


RUN add-apt-repository -y ppa:ubuntu-toolchain-r/test
RUN apt-get update
RUN rm -rf /usr/local/cuda/include/CL

RUN python3 -m pip install cmake

RUN mkdir /usr/local/dpcpp-cuda && cd /usr/local/dpcpp-cuda && curl -L https://github.com/joeatodd/SYCL-For-CUDA-Examples/releases/download/nov_2021/dpcpp.tar.gz | tar --strip-components=1 -zx


RUN mkdir /usr/local/ompi && cd /usr/local/ompi && curl -L https://github.com/joeatodd/SYCL-For-CUDA-Examples/releases/download/nov_2021/ompi.tar.gz | tar --strip-components=1 -zx

ENV PATH=/usr/local/dpcpp-cuda/bin:/usr/local/dpcpp-cuda/include:/usr/local/dpcpp-cuda/lib:/usr/local/ompi/bin/:${PATH}

ENV LD_LIBRARY_PATH=/usr/local/dpcpp-cuda/lib:/usr/local/ompi/lib/:${LD_LIBRARY_PATH}

ENV SYCL_ROOT_DIR=/usr/local/dpcpp-cuda

ENV CUDA_ROOT_DIR=/usr/local/cuda

ENV CXX=/usr/local/dpcpp-cuda/bin/clang++

ENV CC=/usr/local/dpcpp-cuda/bin/clang

RUN mkdir /home/examples/ && cd /home/examples/ && git clone https://github.com/joeatodd/SYCL-For-CUDA-Examples.git -b updates-2021

