! _/_/_/ Simple Benchmark Program  Ver 2.1 _/_/_/
! Copyright Y.Hirokawa

program main
! === Declaration of Variables ===
  implicit none
  integer              :: n, i, nsize, Iseed, Ndim, Ntime
  integer, allocatable :: iarray(:) 
  double precision     :: dn
  double precision, allocatable :: a(:), b(:)
  namelist /MAIN_PARM/ Ndim,  &
                       Ntime
!
! === Read Input Data ===
  write(*,*) "[INFO] Reading input.dat..."
  open(1,err=9,file='input.dat',status='old')
  read(1,NML=MAIN_PARM)
  close(1)
  write(*,*) "[INFO] Ndim=",Ndim," Ntime=",Ntime, "Iseed=",Iseed
!
! === Set Pseudo Random Number ===
  Iseed = 1
  call random_seed(size=nsize)
  allocate(iarray(nsize))
  iarray(:) = Iseed
  call random_seed(put=iarray)
  deallocate(iarray)
!
! === Memory Allocation ===
  allocate(a(Ndim), b(Ndim))
!
! === Initialize Variables ===
  a(:) = 0.0d0
  call random_number(b)
!
! === Calculation ===
!$ACC DATA COPYIN(b), COPYOUT(a)
  do n = 1, Ntime
    dn = dble(n) + a(1)
!$OMP PARALLEL DO PRIVATE(i)
!$ACC KERNELS
    do i = 1, Ndim
       a(i) = dn*b(i) + 2.0d0 
    enddo
!$ACC END KERNELS
!$OMP BARRIER
  enddo
!$ACC END DATA
!
! === Output Sample ===
  write(*,*) "a(NDIM)=",a(NDIM)
!
! === Free Allocated Memory ===
  deallocate(a, b)
!
  write(*,*) "Successfully Done."
!  
  stop

! === Message for Exception ===
9 continue 
  write(*,*) '---------------------------------------------------'
  write(*,*) 'FATAL ERROR:                                       '
  write(*,*) '  Opening or reading "input.dat" failed.           '
  write(*,*) 'ADVICE:                                            '
  write(*,*) '  1.check "input.dat" existance and accesibility.'
  write(*,*) '  2.check "input.dat" contains valid data.       '
  write(*,*) '    In addition, "input.dat" shoud contain         '
  write(*,*) '    extra line break before end-of-file.           '
  write(*,*) '---------------------------------------------------'
  close(1)
  stop
end program main
