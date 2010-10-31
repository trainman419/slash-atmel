/* wheelmon.c
   The wheel monitoring process and associated globals.

   Author: Austin Hendrix
 */

#include "polybot_library/globals.h"
#include "system.h"

volatile s16 lspeed; /* left wheel speed (Hz) */
volatile s16 rspeed; /* right wheel speed (Hz) */
volatile u16 lcount; /* left wheel count, revolutions */
volatile u16 rcount; /* right wheel count, revolutions */

/* extend the OS to run this on a strict schedule: DONE! */
#define WHEELDIV 2000
void wheelmon() {
   u16 lcnt = 0;
   u16 rcnt = 0;
   u08 l, r;
   l = digital(0);
   r = digital(1);
   while(1) {
      /* read wheel sensors and update computed wheel speed */
      /* don't know if this is left or right. I'll just guess. */
      /* TODO: check this and make sure it's right */
      if( digital(0) == l ) {
         lcnt++;
         if( lspeed > WHEELDIV/lcnt ) lspeed = WHEELDIV/lcnt;
         if( lcnt > WHEELDIV+1) {
            lcnt = WHEELDIV+1;
            lspeed = 0;
         }
      } else {
         if(l) lcount++;
         lspeed = WHEELDIV/lcnt;
         lcnt = 0;
         l = digital(0);
      }

      if( digital(1) == r ) {
         rcnt++;
         if( rspeed > WHEELDIV/rcnt ) rspeed = WHEELDIV/rcnt;
         if( rcnt > WHEELDIV+1 ) {
            rcnt = WHEELDIV+1;
            rspeed = 0;
         }
      } else {
         if(r) rcount++;
         rspeed = WHEELDIV/rcnt;
         rcnt = 0;
         r = digital(1);
      }

      /* as written now, this should take maybe 10uS to execute. */

      /* yeild the processor until we need to run again */
      yeild();
   }
}
