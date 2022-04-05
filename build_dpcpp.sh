#!/bin/bash

# Build llvm with sycl & cuda support
set -x #echo on

SOURCE_DIR=$HOME/llvm
BUILD_DIR=$HOME/llvm-build
INSTALL_DIR=/usr/local/dpcpp-cuda

# Configure & build llvm
CUDA_LIB_PATH=$CUDA_ROOT/lib64/stubs \
python3 $SOURCE_DIR/buildbot/configure.py --cuda -t Release --cmake-gen Ninja \
-o $BUILD_DIR

cd $BUILD_DIR

# CUDA_LIB_PATH=$CUDA_ROOT/lib64/stubs \
# cmake -DCMAKE_INSTALL_PREFIX=$INSTALL_DIR .

ninja sycl-toolchain
ninja

cmake -DCMAKE_INSTALL_PREFIX=$INSTALL_DIR -P cmake_install.cmake
