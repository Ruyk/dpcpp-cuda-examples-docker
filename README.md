DPCPP CUDA Examples Docker Image
=================================

This docker image uses a pre-built DPCPP CUDA compiler to set up an environment that can be used to run the SYCL for CUDA examples in https://github.com/codeplaysoftware/SYCL-For-CUDA-Examples/.

The docker image is based on nvidia/cuda:latest, and requires nvidia-docker to run the CUDA applications.

To run the image:

```
sudo docker run --gpus all -it ruyman/dpcpp_cuda_examples
```

# Notes on construction of this image

The DPC++ compiler & the OpenMPI stack are pre-built for this image & then stored with a release of the SYCL-For-CUDA-Examples repo.

The DPC++ build was lifted from an A100 machine where it was installed with the following bash script:

```
#!/bin/bash

# Build llvm with sycl & cuda support
set -x #echo on

SOURCE_DIR=$HOME/sources/llvm
BUILD_DIR=$HOME/soft/llvm-build
INSTALL_DIR=$HOME/soft/llvm

# Configure & build llvm
mkdir $BUILD_DIR
python3 $SOURCE_DIR/buildbot/configure.py --cuda -t Release --cmake-gen Ninja -o $BUILD_DIR
cd $BUILD_DIR

## Now we need to hack the CMakeCache a bit to enable OpenMP
## NB: This may not be necessary for the examples in SYCL-For-CUDA-Examples
sed -i 's/LLVM_ENABLE_PROJECTS:STRING=.*/&;openmp;clang-tools-extra/' CMakeCache.txt
sed -i '/LLVM_ENABLE_PROJECTS:STRING=/a OPENMP_ENABLE_LIBOMPTARGET:BOOL=OFF\nOPENMP_ENABLE_LIBOMPTARGET_PROFILING:BOOL=OFF' CMakeCache.txt

## Now we can update the cmake configuration and build!
cmake -DCMAKE_INSTALL_PREFIX=$INSTALL_DIR -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DLLVM_INSTALL_UTILS:BOOL=YES .
# ninja sycl-toolchain
ninja install
```

CUDA-aware MPI requires building OpenMPI from source. OpenMPI must be built in the same path it occupies in the docker container, as this is hardcoded into the mpicxx (etc) wrappers. So, it was built in the container like so:

```
#!/bin/bash

# This script builds the OpenMPI stack (hwloc, ucx, ompi)

set -x #echo on

SOURCES_DIR=/home/examples/sources/
INSTALL_DIR=/usr/local/ompi
rm -r $INSTALL_DIR
mkdir $INSTALL_DIR

# Configure & build hwloc
HWLOC_SOURCE_DIR=$SOURCES_DIR/hwloc
cd $HWLOC_SOURCE_DIR
./autogen.sh
./configure --prefix=$INSTALL_DIR --with-cuda=/usr/local/cuda
make install
cd ..

# Configure & build ucx
# Note, for now checking out specific commit. A recent commit in the ucx repository breaks the CUDA-aware MPI support.
UCX_SOURCE_DIR=$SOURCES_DIR/ucx
cd $UCX_SOURCE_DIR
git checkout 87702e1e59c8db0e1c72a4da5eaeca6d9e623fa0
autoreconf -i
./configure --prefix=$INSTALL_DIR \
--with-cuda=/usr/local/cuda --enable-mt
make install
cd ..

# Configure & build openmpi
OMPI_SOURCE_DIR=$SOURCES_DIR/ompi
cd $OMPI_SOURCE_DIR
git checkout v4.1.x
./autogen.pl
CXX=clang++ CC=clang $SOURCES_DIR/ompi/configure \
--prefix=$INSTALL_DIR --with-cuda=/usr/local/cuda \
--with-hwloc=$INSTALL_DIR --with-ucx=$INSTALL_DIR

make install
cd ..
```

