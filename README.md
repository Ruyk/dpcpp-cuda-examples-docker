DPCPP for CUDA Image
=================================

This docker image provides the DPC++ compiler with CUDA backend support, and a CUDA-aware OpenMPI stack.

The docker image is based on nvidia/cuda:latest, and requires nvidia-docker2.

To run the image:

```
sudo docker run --gpus all -it joeatodd/dpcpp_for_cuda
```

# Notes on construction of this image

The Dockerfile executes the scripts `build_mpi.sh` and `build_dpcpp.sh` to build the OpenMPI stack & DPC++ compiler respectively (CUDA-aware MPI requires building OpenMPI from source).

The image is build with a straight-forward `docker build .`
