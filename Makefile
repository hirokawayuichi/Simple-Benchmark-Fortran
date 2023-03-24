FC        = nvfortran
RM        = del
RM        = rm -fr
FFLAG1    = 
FFLAG2    = -mp=multicore
FFLAG3    = -acc=gpu

FC_MPI    = mpif90
FFLAG_MPI =

SRC1 = serial.f90
OBJ1 = $(SRC1:%.f90=%.o)
OBJ2 = $(SRC1:%.f90=%.o)
OBJ3 = $(SRC1:%.f90=%.o)
EXE1 = sequential.exe
EXE2 = openmp.exe
EXE3 = openacc.exe

SRC4 = mpi.F90
OBJ4 = $(SRC4:%.F90=%.o)
EXE4 = mpi.exe

.SUFFIXES: 
.SUFFIXES: .f90 .o
.SUFFIXES: .F90 .o

default: $(EXE1) $(EXE2) $(EXE3)
all: default $(EXE4)

$(EXE1): $(SRC1)
	$(RM) *.o
	$(FC) $(FFLAG1) -o $@ $^

$(EXE2): $(SRC1)
	$(RM) *.o
	$(FC) $(FFLAG2) -o $@ $^

$(EXE3): $(SRC1)
	$(RM) *.o
	$(FC) $(FFLAG3) -o $@ $^

$(EXE4): $(SRC4)
	$(RM) *.o
	$(FC_MPI) $(MPIFLAG) -o $@ $^

$(OBJ1): $(SRC1)
$(OBJ2): $(SRC1)
$(OBJ3): $(SRC1)
$(OBJ4): $(SRC4)

.f90.o: 
	$(FC) $(FFLAG) -c $<

.F90.o:
	$(FC_MPI) $(FFLAG_MPI) -c $<

clean:
	$(RM) $(EXE1) $(EXE2) $(EXE3) $(EXE4) *.mod *.L *.o *.o_mpi *.optrpt

distclean:
	$(RM) $(EXE1) $(EXE2) $(EXE3) $(EXE4) *.mod *.L *.o *.o_mpi *.optrpt *.txt
