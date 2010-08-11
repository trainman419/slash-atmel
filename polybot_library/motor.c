//Code for the DC motor control

#include "globals.h"
#include <avr/io.h>
#include <avr/interrupt.h>
#include <util/delay.h>

// NUM_ACTIVE_MOTORS defines the number of motors you are using.
// By default, all motors are enabled.  If NUM_ACTIVE_MOTORS is set to 3,
// then motors 0-2 are enabled.  Reducing this number reduces the 
// amount of time spent in the interrupt routine.
#define NUM_ACTIVE_MOTORS 2

#define PWM_FREQUENCY 500  //frequency in Hertz for the motor PWM
#define PWM_PERIOD_CYCLES 16000000/PWM_FREQUENCY/8 //prescalar is 8 
#define MOTOR_POWER_STEPS 20  //number of different power levels

u08 motor_power_setting[4]; //stores the current motor power setting: 0 to 100
volatile u08 motor_high; //the lower 4 bits tell which motor enable pins are currently high
u16 motor_next[4];
volatile u08 num_motor_high;
volatile u16 motor_begin_period;
volatile u16 on_time;

volatile u08 motor_output;
// how the bits in motor_output are used:
// 7 6 5 4 3 2 1 0
// 7=motor 3 direction
// 6=motor 3 enable
// 5=motor 2 direction
// 4=motor 2 enable
// 3=motor 1 direction
// 2=motor 1 enable
// 1=motor 0 direction
// 0=motor 0 enable

// set_motor_power takes 2 parameters: the motor number and the direction.
// The motor number should be between 0 and 3.  0 is the leftmost motor.
// The direction is a number between -100 and 100
void set_motor_power(u08 num, signed char direction) {
  if (direction > 100) {
    direction = 100;
  }
  if (direction < -100) {
    direction = -100;
  }
  cli();
  motor_power_setting[num] = abs(direction)/(100/MOTOR_POWER_STEPS);
  motor_next[num] = motor_power_setting[num] * (PWM_PERIOD_CYCLES/MOTOR_POWER_STEPS);
  
  if (direction >= 0) {
    sbi(motor_output,num*2+1);
  } else {
    cbi(motor_output,num*2+1);
  }
  num_motor_high=0;
  sei();
}

void motor_init(void) {
  //enable timer (set prescalar to /8)
  cli();
  TCCR1B |= _BV(CS11);

  sbi(TIMSK,3);  //enable output compare OC1B

  set_motor_power(0,0);
  set_motor_power(1,0);
  set_motor_power(2,0);
  set_motor_power(3,0);

  sei();
}

ISR(TIMER1_COMPB_vect) {
  u08 i;
  u16 temp_time=0xffff;
  u16 temp_diff;
  u08 num_low=0;
  
  if (num_motor_high==0) {
    //If all of the PWM periods for the motors are over, then
    //go through each of the active motors and set the outputs
    //to be high.
    
    for (i=0;i<NUM_ACTIVE_MOTORS;i++) {
		if ((motor_power_setting[i] != 0) && (motor_power_setting[i] != MOTOR_POWER_STEPS)) {
			sbi(motor_output,2*i);
			sbi(motor_high,i);
			num_motor_high++;
	
			if (motor_next[i] < temp_time) {
				temp_time = motor_next[i];  //find next time to get interrupt
			}
		} else if (motor_power_setting[i] == 0) {
			//If the motor power is 0, then set the output pin to 
			//low all of the time.
			cbi(motor_output,2*i);
			num_low++;
		} else {
			//If the motor power is 100, then set the output pin to
			//high all of the time.
			sbi(motor_output,2*i);
		}
    }
    
    if (num_low == NUM_ACTIVE_MOTORS) {
		temp_time = PWM_PERIOD_CYCLES/2;
    }
    
    on_time = temp_time;
    motor_begin_period = OCR1B;
    OCR1B += temp_time;
    
  } else {
    //Whenever an interrupt occurs and it is not the start of a new
    //PWM period, then check each motor output pin to see if it should
    //be set low.  For each motor output pin that is set low, the variable
    //num_motor_high is decremented.

    for (i=0;i<NUM_ACTIVE_MOTORS;i++) {
		//Whenever a motor output is high, check if the current time
		//is beyond the high time for the motor.  If so, turn off the
		//motor.
		if (bit_is_set(motor_high,i) && (motor_next[i] <= on_time)) {	
			cbi(motor_high,i);
			cbi(motor_output,2*i); //set this motor output to low
			num_motor_high--;
		}
      
		if (bit_is_set(motor_high,i) && (motor_next[i] < temp_time)) {
			temp_time = motor_next[i];
		}
    }
    
    if (num_motor_high == 0) {
		OCR1B = motor_begin_period + PWM_PERIOD_CYCLES;
    } else {
		temp_diff = temp_time - on_time;
		on_time = temp_time;
		OCR1B += temp_diff;
    }
  }
  
  cli();  //disable interrupts
  sbi(PORTD,4);  //disable digital inputs
  DDRC = 0xff;   //make port C outputs
  PORTC = motor_output;
  _delay_loop_1(3);
  sbi(PORTD,5);  //clock in the motor output
  _delay_loop_1(3);
  cbi(PORTD,5);  //clock in the motor output
  _delay_loop_1(3);
  DDRC = 0x00;  //make port C inputs again
  sei();  //enable interrupts

}

