! _/_/_/ Simple Benchmark Program  Ver 2.1 _/_/_/
! Copyright Y.Hirokawa

program main
! === Declaration of Variables ===
  use mpi
  implicit none
  integer              :: n, i, nsize, Iseed, Ndim, Ntime
  integer              :: buf(2)
  integer, allocatable :: iarray(:)
  double precision     :: dn, a1, btmp 
  double precision, allocatable :: a(:), b(:), atmp(:)
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
  write(*,*) "[INFO] myrank=",myrank,"Ndim=",Ndim," Ntime=",Ntime, "Iseed=",Iseed
!
  ista = (NDIM/nprocs)*myrank + 1
  iend = ista + NDIM/nprocs   - 1
  if(myrank == nprocs-1  .and.  iend /= NDIM) iend = NDIM
!
! === Set Pseudo Random Number ===
  call random_seed(size=nsize)
  allocate(iarray(nsize))
  iarray(:) = Iseed
  call random_seed(put=iarray) 
  deallocate(iarray)
!
!!!DBG  write(*,*) "[DBG] myrank,ista,iend=", myrank, ista, iend
!
! === Memory Allocation ===
  allocate(a(1:Ndim), b(ista:iend), atmp(1:Ndim))
!
! === Initialize Variables ===
  a(:)    = 0.0d0
  atmp(:) = 0.0d0
  call random_number(b)
!
! === Broadcast the Coefficient ===
  if(myrank == 0) btmp = b(1)
  call MPI_Bcast(btmp, 1, MPI_DOUBLE_PRECISION, 0, MPI_COMM_WORLD, ierr)
!
! === Calculation ===
  a1 = 0.0d0
!$ACC DATA COPYIN(b,a1), COPY(atmp)
  do n = 1, Ntime
!   ### Calculate the coeciffient in each MPI process ###
    dn = dble(n) + a1
    a1 = dn*btmp + 2.0d0
!$OMP PARALLEL DO PRIVATE(i,ista,iend)
!$ACC KERNELS
    do i = ista, iend 
       atmp(i) = dn*b(i) + 2.0d0 
    enddo
!$ACC END KERNELS
!$OMP BARRIER
  enddo
!$ACC END DATA
!
! === Collet Data ===
  call MPI_Reduce(atmp, a, NDIM, MPI_DOUBLE_PRECISION, &
 &                MPI_SUM, 0, MPI_COMM_WORLD, ierr)
!
! === Output Sample ===
  call MPI_Barrier(MPI_COMM_WORLD, ierr)
  if(myrank == 0) then
     write(*,*) "a(NDIM)=",a(NDIM)
     write(*,*) "Successfully Done."
  endif
!
! === MPI_Finalization ===
  call MPI_Finalize(ierr)
!
  deallocate(a, b, atmp)
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
