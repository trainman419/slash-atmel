/* map.c
 * a mapping program for my robot
 * NOTES:
 * sizeof(int) = 2;
 */
#include "polybot_library/globals.h"
#include "system.h"
#include "serial.h"
#include "compass.h"
#include <avr/io.h>

#define MIN_POWER 30
#define BACKUP_MAX 100
#define BACKUP_STEER 20
#define BACKUP_SPEED 100
#define BACKUP_SLOW 105

/* TODO:
 *
 * compensate drive power based on wheel velocity
 *
 * build a power cutoff and write the battery to power down when our battery
 *  gets too low
 */

/* sine table */
static int sine[64] = {0,6,13,19,25,31,38,44,50,56,62,68,74,80,86,92,98,104,
109,115,121,126,132,137,142,147,152,157,162,167,172,177,181,185,190,194,198,
202,206,209,213,216,220,223,226,229,231,234,237,239,241,243,245,247,248,250,
251,252,253,254,255,255,256,256
};

volatile u08 battery;
volatile s16 lspeed; /* left wheel speed (Hz) */
volatile s16 rspeed; /* right wheel speed (Hz) */

u08 IR(u08 addr)
{
   u16 dist = analog(addr);
   delay_ms(1);
   dist += analog(addr);
   delay_ms(1);
   dist += analog(addr);
   delay_ms(1);
   dist += analog(addr);
   dist /= 4;
   dist = (2112 / (dist + 28)) - 5;
   return dist;
}

/* first thread, if I need it */
void thread0() {
   u08 bytes[3];
   while(1) {
      /*bytes[0] = rx_byte();*/
      u08 steer;
      u08 speed;
      bytes[0] = 0;
      while (rx_byte() != 0); /* next input byte */

      bytes[1] = rx_byte();
      bytes[2] = rx_byte();
      speed = bytes[1]>30?30:bytes[1];
      speed = (s16)speed + 120;
      steer = (s16)bytes[2] + 120;
      set_servo_position(0,speed);   /* main drive */
      set_servo_position(1,steer); /* steering */

      led_on();
      clear_screen();
      print_int(bytes[0]);
      print_string(" ");
      print_int(bytes[1]);
      print_string(" ");
      print_int((s08)bytes[2]);
      led_off();
   }
}

/* extend the OS to run this on a schedule, maybe once per second */
void battery_thread() {
   /* assume the task switcher is enabled */
   while(1) {
      battery = analog(0);
      yeild(); /* done; yeild the processor so something else can use it */
   }
}

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
         rspeed = WHEELDIV/rcnt;
         rcnt = 0;
         r = digital(1);
      }

      /* as written now, this should take maybe 10uS to execute. */

      /* yeild the processor until we need to run again */
      yeild();
   }
}


/* run at 50Hz or less */
s16 target_speed;
   s08 power = 0; 
void speedman() {
   s16 speed = 0;
   while(1) {
      led_on();
      speed = (lspeed + rspeed)/2;

      if( speed < target_speed ) power++;
      if( speed > target_speed ) power--;

      set_servo_position(0, power+120);
      //led_off();
      yeild();
   }
}

int main(void)
{
   struct heading result;
   u08 ir=0;
   u08 i=0;
   u08 a=120;
   u08 b=120;
   u08 backup=0;
   u08 steer_inc=6;
   u16 sonar;

   lspeed = 0;
   rspeed = 0;
   target_speed = 0;

   initialize();
   servo_init();
   compass_init();
   serial_init();

   system_init();
   schedule(0);
   priority(100);
   system(wheelmon, 1, 0); /* once per mS, highest priority */
   system(speedman, 20, 1); /* every 20mS (50Hz) to manage speed */

   set_servo_position(0,120); /* power */
   set_servo_position(1,120); /* steering */
   delay_ms(40); /* wait for switch to stabilize? */
   while(!get_sw1()) {
      a = knob();
      //set_servo_position(0,a);
      target_speed = a - 120;
      clear_screen();
      print_string("Waiting ");
      print_int(lspeed);
      print_string(" ");
      print_int(rspeed);
      next_line();
      print_int(a);
      print_string(" ");
      print_int(num_pids);
      if( get_sw1() ) {
         print_string(" +");
      } else {
         print_string(" -");
      }
      yeild();
      delay_ms(40);
   }

   clear_screen();
   print_string("Waiting data");


   thread0();
}


