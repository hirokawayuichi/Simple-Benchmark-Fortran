#!/usr/bin/bash
export OMP_NUM_THREADS=16

echo "Sequential"          | tee ./runlog_sequential.txt
time ./sequential.exe 2>&1 | tee -a ./runlog_sequential.txt

echo "_____________________________________________________________"
echo ""
echo "OpenMP: ${OMP_NUM_THREADS} Threads" | tee ./runlog_openmp.txt
time ./openmp.exe 2>&1                    | tee -a ./runlog_openmp.txt

echo "_____________________________________________________________"
echo ""
echo "OpenACC"          | tee ./runlog_openacc.txt
time ./openacc.exe 2>&1 | tee -a ./runlog_openacc.txt
