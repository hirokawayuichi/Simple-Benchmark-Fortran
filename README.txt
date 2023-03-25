_/_/_/ Simple Benchmark Program _/_/_/

Copyright Y.Hirokawa

Prerequesties:
 - Fortran compiler supporting OpenMP
 - CUDA, NVIDIA HPC SDK for NVIDIA GPU
 - MPI Library 

Usage:
1. Confirm or change the setting of Makefile and input.dat
   [Note] NDIM is the size of array. Ntime is the number of iteration loops. 

2. Build executable
   Default: make
   For MPI: make all

3. Run executable (Use run.nqs or run_all.nqs for batch system)
   Default: bash ./go.bash
   For MPI: bash ./go_all.bash

