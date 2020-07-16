FROM nvidia/cuda:10.2-devel-ubuntu18.04

RUN apt-get update
RUN apt-get install -y git
RUN apt-get install -y curl
RUN apt-get install -y ninja-build
RUN apt-get install -y g++
RUN apt-get install -y python3
RUN apt-get install -y python3-pip
RUN apt-get install -y software-properties-common

RUN add-apt-repository -y ppa:ubuntu-toolchain-r/test
RUN apt-get update

RUN python3 -m pip install cmake

RUN mkdir /usr/local/dpcpp-cuda && cd /usr/local/dpcpp-cuda && curl -L https://github.com/codeplaysoftware/SYCL-For-CUDA-Examples/releases/download/initial-build/sycl4cuda.tgz | tar --strip-components=1 -zx

ENV PATH=/usr/local/dpcpp-cuda/bin:/usr/local/dpcpp-cuda/include:/usr/local/dpcpp-cuda/lib:${PATH}

ENV LD_LIBRARY_PATH=/usr/local/dpcpp-cuda/lib:${LD_LIBRARY_PATH}

ENV SYCL_ROOT_DIR=/usr/local/dpcpp-cuda

ENV CUDA_ROOT_DIR=/usr/local/cuda

ENV CXX=/usr/local/dpcpp-cuda/bin/clang++

ENV CC=/usr/local/dpcpp-cuda/bin/clang

RUN mkdir /home/examples/ && cd /home/examples/ && git clone https://github.com/codeplaysoftware/SYCL-For-CUDA-Examples.git

