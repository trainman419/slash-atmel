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

#include "wheelmon.h"
#include "speedman.h"

#define MIN_POWER 30
#define BACKUP_MAX 100
#define BACKUP_STEER 20
#define BACKUP_SPEED 100
#define BACKUP_SLOW 105

/* TODO:
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

/* byte sine table: angle 0-255, sin/cos range -64 to 64 */
static int bsin[64] = {
 0,  2,  3,  5,  6,  8,  9, 11, 12, 14, 16, 17, 19, 20, 22, 23, 
24, 26, 27, 29, 30, 32, 33, 34, 36, 37, 38, 39, 41, 42, 43, 44,
45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 56, 57, 58, 59,
59, 60, 60, 61, 61, 62, 62, 62, 63, 63, 63, 64, 64, 64, 64, 64
};

volatile u08 battery;

inline s16 abs(s16 a) {
   if( a < 0 ) return -a;
   return a;
}

// 16-bit signed square root
s16 sqrt(s16 x) {
   s16 y = 128; // half of maximum square root
   s16 inc = 64;
   s16 new = 128;
   // binary search for square root
   while( inc > 0 ) {
      if( y*y > x ) new = y - inc;
      else new = y + inc;

      if( abs(new*new - x) < abs(y*y - x) ) {
         y = new;
      }

      inc /= 2;
   }

   return y;
}

// arctangent, range 0-255
u08 atan2(s16 x, s16 y) {
   s16 a = x*x + y*y;
   s16 i;
   s16 inc;
   s16 asin;
   s16 acos;
   s16 tmp;

   a = sqrt(a);

   // binary searches for asin and acos
   tmp = abs((64*y)/a);
   for(i=32, inc=16; inc > 0; inc >>= 1 ) {
      if( bsin[i] > tmp) {
         if( abs(bsin[i] - tmp) > abs(bsin[i-inc] - tmp) ) i -= inc;
      } else {
         if( abs(bsin[i] - tmp) > abs(bsin[i+inc] - tmp) ) i += inc;
      }
   }
   asin = i;
   
   tmp = abs((64*x)/a);
   for(i=32, inc=16; inc > 0; inc >>= 1 ) {
      if( bsin[i] > tmp) {
         if( abs(bsin[i] - tmp) > abs(bsin[i-inc] - tmp) ) i -= inc;
      } else {
         if( abs(bsin[i] - tmp) > abs(bsin[i+inc] - tmp) ) i += inc;
      }
   }
   acos = 64 - i;

   // reconcile cos/sin
   if( acos != asin ) {
      if( bsin[acos] == bsin[asin] ) {
         // sines same; cosine is likely more accurate
         asin = acos;
      } else if( bsin[64 - acos] == bsin[64 - asin] ) {
         // cosines same; sine is likely more accurate
         acos = asin;
      } else {
         // ummm... disagreement?
         // pick sine for now
         acos = asin;
      }
   }

   // result in asin from here on

   // resolve to a particular quadrant
   if( y >= 0 ) {
      if( x < 0  ) {
         // Q II
         asin = 128 - asin;
      }
   } else {
      if( x <= 0 ) {
         // Q III
         asin = asin + 128;
      } else {
         // Q IV
         asin = 256 - asin;
      }
   }
   return asin;
}

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

inline void tx_packet(struct heading h) {
   s08 tmp;
   // transmit compass heading
   tx_byte(atan2(h.x, h.y));
   // transmit battery reading
   tx_byte(battery);
   // transmit speeds
   tmp = lspeed;
   if( mode == M_REVERSE ) tmp = -tmp;
   tx_byte(tmp); 

   tmp = rspeed;
   if( mode == M_REVERSE ) tmp = -tmp;
   tx_byte(tmp); 
   // transmit counts
   tx_byte(lcount & 0xFF); // low
   tx_byte(lcount >> 8); // hi
   tx_byte(rcount & 0xFF); // low
   tx_byte(rcount >> 8); // hi
   // transmit button data
   tx_byte(0x80 | digital(2) | (digital(3) << 1));
   // end-of-packet null
   tx_byte(0);
   return;
}

/* first thread, communication with the higher-level controller */
#define PACKET 7
void thread0() {
   u08 bytes[PACKET];
   u08 i;
   struct heading h;
   h.x = 0;
   h.y = 0;
   tx_packet(h);
   while(1) {
      /*bytes[0] = rx_byte();*/
      u08 steer;
      s08 speed;
      bytes[0] = 0;
      while (rx_byte() != 'S'); /* next input byte */

      led_on();
      for( i=1; i<PACKET; i++ ) {
         bytes[i] = rx_byte();
      }
      led_off();
      if( bytes[PACKET-1] != 'E' ) {
         while( rx_byte() != 'E' );
      } else {
         //bytes[1] = rx_byte();
         //bytes[2] = rx_byte();
         speed = bytes[1];
         speed = speed>30?30:speed;
         speed = speed<-30?-30:speed;
         steer = (s16)bytes[2] + 112;

         // limit top speed
         if( speed > 50 ) speed = 50;
         if( speed < -50 ) speed = -50;
         target_speed = speed*3;
         //set_servo_position(0,speed);   /* main drive */
         set_servo_position(1,steer); /* steering */
         
         // read compass and transmit back to propellor
         h = compass();
         // compass calibration
         h.x -= 11;
         h.y += 15;
         tx_packet(h);
      }

      clear_screen();
      print_int(speed);
      print_string(" ");
      print_int((s08)bytes[2]);
      print_string(" ");
      print_int(power);
      print_string(" ");
      print_int(battery);
      next_line();
      print_int(lspeed);
      print_string(" ");
      print_int(rspeed);
      print_string(" ");
      print_int(qspeed);
      print_string(" ");
      print_int(atan2(h.x, h.y));
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

/* run at 50Hz or less */
#define SPEED_DIV 4

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
   lcount = 0;
   rcount = 0;
   target_speed = 0;

   initialize();
   servo_init();
   compass_init();
   serial_init();

   system_init();
   schedule(0);
   priority(100);
   system(wheelmon, 1, 0); /* once per mS, highest priority */
   system(speedman, 100, 1); /* every 20mS (50Hz) to manage speed */
   system(battery_thread, 250, 2); /* every quarter-second, lowest priority */

   set_servo_position(0,120); /* power */
   set_servo_position(1,120); /* steering */
   delay_ms(40); /* wait for switch to stabilize? */
   /*while(!get_sw1()) {
      a = knob();
      //set_servo_position(0,a);
      target_speed = ((a - 120)/2)*6;
      clear_screen();
      print_string("Waiting ");
      print_int(lspeed);
      print_string(" ");
      print_int(rspeed);
      next_line();
      print_int(target_speed);
      print_string(" ");
      print_int(power);
      print_string(" ");
      print_int(qspeed);
      print_string(" ");
      print_int(power/16 + 120);
      //yeild();
      delay_ms(40);
   }*/
   delay_ms(2000); // wait for propeller board to start up

   clear_screen();
   print_string("Waiting data");


   thread0();
}

/* general notes:
 *
 * tire circumference: 13"
 *
 * 1 speed unit ~= 6.5 in/second ~= 0.37 MPH
 * 1 MPH ~= 17.6 in/second ~= 2 speed units
 * speed 25 ~= 9.2 MPH
 * 10 MPH ~= speed 27
 * 5 MPH ~= speed 13.4
 */
