#!/bin/bash

# This script builds the OpenMPI stack (hwloc, ucx, ompi)

set -x #echo on

export LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu:/usr/local/cuda/lib64:/usr/local/cuda/lib64/stubs:$LD_LIBRARY_PATH

export LIBRARY_PATH=/usr/lib/x86_64-linux-gnu:/usr/local/cuda/lib64:/usr/local/cuda/lib64/stubs:$LIBRARY_PATH

export CPATH=/usr/local/cuda/include

SOURCES_DIR=$HOME
INSTALL_DIR=/usr/local/ompi

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
