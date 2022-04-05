DPCPP CUDA Examples Docker Image
=================================

This docker image uses a pre-built DPCPP CUDA compiler to set up an environment that can be used to run the SYCL for CUDA examples in https://github.com/codeplaysoftware/SYCL-For-CUDA-Examples/.

The docker image is based on nvidia/cuda:latest, and requires nvidia-docker to run the CUDA applications.

To run the image:

```
sudo docker run --gpus all -it ruyman/dpcpp_cuda_examples
```

# Notes on construction of this image

The Dockerfile executes the scripts `build_mpi.sh` and `build_dpcpp.sh` to build the OpenMPI stack & DPC++ compiler respectively (CUDA-aware MPI requires building OpenMPI from source).

The image is build with a straight-forward `docker build .`
