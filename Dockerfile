FROM nvidia/cuda:11.3.0-devel-ubuntu20.04

ARG DEBIAN_FRONTEND=noninteractive

ENV CUDA_ROOT=/usr/local/cuda
ENV SYCL_ROOT_DIR=/usr/local/dpcpp-cuda

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
RUN apt-get install -y flex

RUN add-apt-repository -y ppa:ubuntu-toolchain-r/test
RUN apt-get update

# These CL headers interfere with SYCL...
RUN rm -rf /usr/local/cuda/include/CL

RUN python3 -m pip install cmake

# Set environment variables
ENV LD_LIBRARY_PATH=/usr/local/cuda/lib64/:/usr/local/dpcpp-cuda/lib:/usr/local/ompi/lib/:${LD_LIBRARY_PATH}
ENV PATH=/usr/local/dpcpp-cuda/bin:/usr/local/ompi/bin/:${PATH}

# Get dpcpp source & build it
RUN mkdir /usr/local/dpcpp-cuda $HOME/llvm-build $HOME/llvm
RUN git clone -b sycl-nightly/20220401 https://github.com/intel/llvm.git $HOME/llvm

# Get sources for OpenMPI stack & build it
RUN mkdir /usr/local/ompi $HOME/hwloc $HOME/ucx $HOME/ompi
RUN git clone https://github.com/open-mpi/ompi.git $HOME/ompi
RUN git clone https://github.com/openucx/ucx.git $HOME/ucx
RUN git clone https://github.com/open-mpi/hwloc.git $HOME/hwloc

# Add build scripts & set permissions
ADD build_mpi.sh /
ADD build_dpcpp.sh /
RUN chmod +x /build_mpi.sh
RUN chmod +x /build_dpcpp.sh

# Note previously had $CUDA_ROOT/lib64/stubs in LD_LIBRARY_PATH but this is verboten!
# Rather hacky fix is to symlink libcuda.so.1 from the right place...
# https://github.com/Kaggle/docker-python/issues/361#issuecomment-448093930
RUN ln -s /usr/lib/x86_64-linux-gnu/libcuda.so.1 /usr/local/cuda/lib64/stubs/libcuda.so.1
RUN ln -s /usr/local/cuda/lib64/stubs/libnvidia-ml.so /usr/local/cuda/lib64/stubs/libnvidia-ml.so.1

RUN /build_dpcpp.sh
RUN /build_mpi.sh

# Set C/C++ compilers
ENV CXX=/usr/local/dpcpp-cuda/bin/clang++
ENV CC=/usr/local/dpcpp-cuda/bin/clang

# Clean up source code
RUN rm -rf /root/
