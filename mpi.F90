! _/_/_/ Simple Benchmark Program  Ver 2.0 _/_/_/
! Copyright Y.Hirokawa

program main
! === Declaration of Variables ===
  use mpi
  implicit none
  integer              :: n, i, nsize, Iseed, Ndim, Ntime
  integer              :: buf(2)
  integer, allocatable :: iarray(:)
  double precision     :: dn
  double precision, allocatable :: a(:), b(:), c(:)
  integer :: ista, iend
  integer :: ierr, nprocs, myrank
  namelist /MAIN_PARM/ Ndim,  &
                       Ntime
!
! === MPI Initialization ===
  call MPI_Init(ierr)
  call MPI_Comm_Size(MPI_COMM_WORLD, nprocs, ierr)
  call MPI_Comm_Rank(MPI_COMM_WORLD, myrank, ierr)
!
! === Read Input Data (Only Root Rank) and Broadcast ===
  if(myrank == 0) then
    write(*,*) "[INFO] Reading input.dat..."
    open(1,err=9,file='input.dat',status='old')
    read(1,NML=MAIN_PARM)
    close(1)
    buf(1) = Ndim
    buf(2) = Ntime
  endif
  call MPI_Bcast(buf, 2, MPI_INTEGER, 0, MPI_COMM_WORLD, ierr)
!
  Ndim  = buf(1)
  Ntime = buf(2)
  Iseed = myrank + 1
  write(*,*) "[INFO] Myrank=",myrank," Ndim=",Ndim," Ntime=",Ntime, "Iseed=",Iseed
!
  ista = (NDIM/nprocs)*myrank + 1
  iend = ista + NDIM/nprocs   - 1
  if(iend > NDIM) iend = NDIM
!
! === Set Pseudo Random Number ===
  call random_seed(size=nsize)
  allocate(iarray(nsize))
  iarray(:) = Iseed
  call random_seed(put=iarray) 
  deallocate(iarray)
!
!!!DBG  write(*,*) "myrank,ista,iend=", myrank, ista, iend
!
! === Memory Allocation ===
  allocate(a(1:Ndim), b(ista:iend), c(1:Ndim))
!
! === Initialize Variables ===
  a(:) = 0.0d0
  call random_number(b)
!
! === Calculation ===
!$ACC DATA COPYIN(b), COPYOUT(a)
  do n = 1, Ntime
    dn = dble(n) + a(1)
!$OMP PARALLEL DO PRIVATE(i,ista,iend)
!$ACC KERNELS
    do i = ista, iend 
       a(i) = dn*b(i) + 2.0d0 
    enddo
!$ACC END KERNELS
!$OMP BARRIER
  enddo
!$ACC END DATA
!
! === Collet Data ===
  call MPI_Reduce(c, a, NDIM, MPI_DOUBLE_PRECISION, &
 &                MPI_SUM, 0, MPI_COMM_WORLD, ierr)
!
!
! === MPI_Finalization ===
  call MPI_Barrier(MPI_COMM_WORLD, ierr)
  if(myrank == 0) then
     write(*,*) "Successfully Done."
  endif
  call MPI_Finalize(ierr)
!
  deallocate(a, b, c)
  stop

9 continue
  write(*,*) '---------------------------------------------------'
  write(*,*) 'FATAL ERROR:                                       '
  write(*,*) '  opening or reading "input.dat" failed.           '
  write(*,*) 'ADVICE:                                            '
  write(*,*) '  1.check "input.dat" existance and accesibility.'
  write(*,*) '  2.check "input.dat" contains valid data.       '
  write(*,*) '    In addition, "input.dat" shoud contain         '
  write(*,*) '    extra line break before end-of-file.           '
  write(*,*) '---------------------------------------------------'
  close(1)
  stop
end program main
