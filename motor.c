/* austin/motor2.c
new code to control DC motors
by Austin Hendrix
10/30/2006
*/

#include "polybot_library/globals.h"
#include <avr/io.h>
#include <avr/interrupt.h>
#include <util/delay.h>

#define PWM_FREQUENCY 500 /* pwm frequency in Hz */
#define PWM_PERIOD_CYCLES 16000000/PWM_FREQUENCY/8 /* prescalar 8 */
#define MOTOR_POWER_STEPS 20 /* number of discrete power levels */
#define MAX_TIMER PWM_PERIOD_CYCLES /* value when timer should overflow */

u08 motor_output;
/* how the bits in motor_output are used:
   7 6 5 4 3 2 1 0
   7=motor 3 direction
   6=motor 3 enable
   5=motor 2 direction
   4=motor 2 enable
   3=motor 1 direction
   2=motor 1 enable
   1=motor 0 direction
   0=motor 0 enable
*/

u08 motor_counter = 0;
u08 motor_order[3];
u16 time_next[3];

/* set_motor_power takes 2 parameters: the motor number and the direction.
The motor number should be between 0 and 3.  0 is the leftmost motor.
The direction is a number between -100 and 100 */
void set_motor_power(u08 num, signed char direction)
{
	/*u08 power;
	u16 time_on;
	u08 i, j;
	if (direction > 100) {
		direction = 100;
	}
	if (direction < -100) {
		direction = -100;
	}

	power = abs(direction)/(100/MOTOR_POWER_STEPS);
	time_on = power * (PWM_PERIOD_CYCLES/MOTOR_POWER_STEPS);
	motor_time[num] = time_on;
	
	if(direction >= 0)
	{
		sbi(motor_order[0],num*2+1);
	}
	else
	{
		cbi(motor_order[0],num*2+1);
	}
	if(power>0)
	{
		sbi(motor_order[0], num*2);
	}
	else
	{
		cbi(motor_order[0], num*2);
		motor_time[num] = MAX_TIMER;
	}
	
	/* done */
}

void motor_init(void)
{
	u08 i = 0;
	/* enable timer (set prescalar to /8) */
	TCCR1B |= _BV(CS11);

	time_next[0] = 1000;
	time_next[1] = 1000;
	time_next[2] = 2000;
	motor_order[0] = 15;
	motor_order[1] = 3;
	motor_order[2] = 0;
	motor_output = 0;

	sbi(TIMSK,3);  /* enable output compare OC1B */

}

ISR(TIMER1_COMPB_vect) {
	
	motor_output = motor_order[motor_counter];
	OCR1B += time_next[motor_counter];
	
	motor_counter++;
	if(motor_counter>2)
	{
		motor_counter = 0;
	}
  
	/* actualy set the motor outputs */
	cli();  /* disable interrupts */
	sbi(PORTD,4);  /* disable digital inputs */
	DDRC = 0xff;   /* make port C outputs */
	PORTC = motor_output;
	_delay_loop_1(1);
	sbi(PORTD,5);  /* clock in the motor output */
	_delay_loop_1(1);
	cbi(PORTD,5);  /* clock in the motor output */
	_delay_loop_1(1);
	DDRC = 0x00;  /* make port C inputs again */
	sei();  /* enable interrupts */
}
