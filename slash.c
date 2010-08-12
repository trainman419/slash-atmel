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
      bytes[0] = 0;
      while (rx_byte() != 0); /* next input byte */
      bytes[1] = rx_byte();
      bytes[2] = rx_byte();
      steer = (s16)bytes[2] + 120;
      set_servo_position(0,120);   /* main drive */
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

void battery_thread() {
   /* assume the task switcher is enabled */
   battery = analog(0);
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

   initialize();
   servo_init();
   compass_init();
   serial_init();

   set_servo_position(0,120); /* power */
   set_servo_position(1,120); /* steering */
   while(!get_sw1()) {
      a = knob();
      set_servo_position(0,a);
      clear_screen();
      print_string("Waiting");
      next_line();
      print_int(a);
      delay_ms(40);
   }

   thread0();
}


