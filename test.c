#include "polybot_library/globals.h"
#include <avr/io.h>
#include <avr/interrupt.h>
#include <util/delay.h>
#include <math.h>

int main(void) {
  initialize();
  motor_init();

  led_on();
  delay_ms(200);
  led_off();
  delay_ms(200);
  led_on();
  delay_ms(200);
  led_off();
  delay_ms(200);

  print_string("Wall Following");
  next_line();
  print_string("by Austin");
   
  /*clear_screen();
  print_string("Warninng:");
  next_line();
  print_string("Testing Motors");
  set_motor_power(0,50);
  set_motor_power(1,-100);
  delay_ms(1000);
  set_motor_power(0,0);
  set_motor_power(1,0);*/
  u08 dist=0;
  s08 m1=0, m0=0;
  
  while(!get_sw1())
  {
	;
  }

  while(1) {
	dist = analog(0);
	/*if(dist<70)
	{
		set_motor_power(0, -100);
		set_motor_power(1, 30);
	}
	else
	{
		set_motor_power(0, -30);
		set_motor_power(1, 100);
	}*/
	if(dist > 70)
	{
		m1 = 100;
	}
	else
	{
		m1 = dist*2 - 40;
	}
	if(dist < 70)
	{
		m0 = 100;
	}
	else
	{
		m0 = 240-(2* dist);
	}
	set_motor_power(0, -m1);
	set_motor_power(1, -m0);
	clear_screen();
	print_string("Distance: ");
	print_int(dist);
	next_line();
	print_string("M0: ");
	print_int(m0);
	print_string(" M1: ");
	print_int(m1);
	delay_ms(100);
  }

  return 0;
}
