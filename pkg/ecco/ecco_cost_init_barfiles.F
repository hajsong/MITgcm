#include "ECCO_OPTIONS.h"
#include "AD_CONFIG.h"
#ifdef ALLOW_CTRL
# include "CTRL_OPTIONS.h"
#endif

      subroutine ecco_cost_init_barfiles( myThid )

c     ==================================================================
c     SUBROUTINE ecco_cost_init_barfiles
c     ==================================================================
c
c--   Initialise adjoint of monthly mean files calculated
c--   in cost_averagesfields (and their ad...).
c
c     started: heimbach@mit.edu 20-Mar-2002
c
c     ==================================================================
c     SUBROUTINE ecco_cost_cost_init_barfiles
c     ==================================================================

      IMPLICIT NONE

c     == global variables ==

#include "EEPARAMS.h"
#include "SIZE.h"
#include "PARAMS.h"

#ifdef ALLOW_ECCO
# include "ECCO_SIZE.h"
# include "ECCO.h"
#endif
#ifdef ALLOW_CTRL
# include "CTRL_SIZE.h"
# include "CTRL.h"
# include "CTRL_DUMMY.h"
#endif

c     == routine arguments ==

      integer myThid

c     == local variables ==

      integer bi,bj
      integer i,j,k
      integer itlo,ithi
      integer jtlo,jthi
      integer jmin,jmax
      integer imin,imax

      integer ilt, irec

#ifdef ALLOW_GENCOST_CONTRIBUTION
      CHARACTER*(128) fname_gencostbar
      CHARACTER*(128) adfname_gencostbar
#endif /* ALLOW_GENCOST_CONTRIBUTION */

      _RL tmpfld2d (1-OLx:sNx+OLx,1-OLy:sNy+OLy,   nSx,nSy)
      _RL tmpfld3d (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)

c     == external functions ==

      integer  ilnblnk
      external ilnblnk

c     == end of interface ==

      jtlo = myByLo(myThid)
      jthi = myByHi(myThid)
      itlo = myBxLo(myThid)
      ithi = myBxHi(myThid)
      jmin = 1
      jmax = sNy
      imin = 1
      imax = sNx

      do bj = jtlo,jthi
        do bi = itlo,ithi
          do j = jmin,jmax
            do i =  imin,imax
              tmpfld2d(i,j,bi,bj) = 0. _d 0
            enddo
          enddo
        enddo
      enddo
      do bj = jtlo,jthi
        do bi = itlo,ithi
          do k = 1,Nr
            do j = jmin,jmax
              do i =  imin,imax
                tmpfld3d(i,j,k,bi,bj) = 0. _d 0
              enddo
            enddo
          enddo
        enddo
      enddo

#ifdef ALLOW_GENCOST_CONTRIBUTION
c--   Save gencost_barfile on file.
      do k=1,NGENCOST
      if ( .NOT.gencost_barskip(k) ) then
      ilt=ilnblnk( gencost_barfile(k) )
      write(fname_gencostbar,'(2a,i10.10)')
     &     gencost_barfile(k)(1:ilt), '.', eccoiter

#ifdef ALLOW_AUTODIFF
      if ( useAUTODIFF ) then
      write(adfname_gencostbar,'(3a,i10.10)')
     &     yadprefix, gencost_barfile(k)(1:ilt), '.', eccoiter
      do irec = 1,gencost_nrec(k)
#ifdef ALLOW_ADJOINT_RUN
        if (.NOT.gencost_is3d(k))
     &  call active_write_xy( adfname_gencostbar, tmpfld2d, irec,
     &       eccoiter, myThid, gencost_dummy(k) )
        if (gencost_is3d(k))
     &  call active_write_xyz( adfname_gencostbar, tmpfld3d, irec,
     &       eccoiter, myThid, gencost_dummy(k) )
#endif
      enddo
      endif
#endif

      endif
      enddo
#endif /* ALLOW_GENCOST_CONTRIBUTION */

      return
      end
