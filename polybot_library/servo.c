//The code handles each servo in a round-robin manner.  One servo is serviced 
//over a 2.5ms period of time.  During a given 2.5ms period, the servo signal 
//is set high for the appropriate amount of time and then set to low.  
//Servicing all 8 servos takes 8*2.5ms = 20ms (which is the period for a 
//servo signal to repeat)

#include "globals.h"
#include <avr/io.h>
#include <avr/interrupt.h>
#include <util/delay.h>

//By default the code generates signals for all 8 servos.  You can change
//NUM_SERVOS to the actual number of servos you are using.  This reduces the
//amount of CPU time spent generating servo signals.
#define NUM_SERVOS 8  //number of active servos

#define MAX_PERIOD 20*((u16)(2000/NUM_SERVOS))
//20ms divided by NUM_SERVOS = number of milliseconds to work on each servo
//2000 = number of clock cycles in 1 millisecond with a 16MHz clock and 
//prescalar of 8

#define SERVO_PORT PORTC

volatile u08 servo_state=0;
volatile u08 high=0;
volatile u16 servo_position[8];
volatile u16 servo_low_time[8];
volatile u08 servo_output;

void servo_off(u08 servo_num) {
  //This function turns a servo off

  servo_position[servo_num] = 4600;  //hard-coded constant to signify the servo is off
  servo_low_time[servo_num] = MAX_PERIOD - servo_position[servo_num];
}

void set_servo_position(u08 servo_num, u08 position) {
  u16 low_time;
  u16 high_time;

  //This function set the position of the servos.  The first 
  //parameter (0 or 1) selects the servo.  The second 
  //parameter (0-255) sets the servo position

  //position runs from 0 to 255
  if (position > 250) {
    position = 250;
  }

  high_time = 1800 + (10 * position);
  //this sets the servo pulse width to .9ms to 2.15ms

  low_time = MAX_PERIOD - servo_position[servo_num];

  cli();
  servo_position[servo_num] = high_time;
  servo_low_time[servo_num] = low_time;
  sei();
}

//This function initializes the timers so that the other servo 
//routines function correctly.  Call this function before 
//using any of the servo functions.
void servo_init(void) {
  u08 i=0;

  for (i=0;i<NUM_SERVOS;i++) {
    servo_off(i);
  }

  TCCR1B |= _BV(CS11); //enable timer (set prescalar to /8)
  sbi(TIMSK,4);  //OC1A interrupts

  sei (); //enable interrupts
}

void write_servo_output(void) {
  cli();  //disable interrupts
  sbi(PORTD,4);  //disable digital inputs
  DDRC = 0xff;

  PORTC = servo_output;
  _delay_loop_1(1);
  sbi(PORTD,6);  //clock in the servo output
  _delay_loop_1(1);
  cbi(PORTD,6);  //clock in the servo output
  _delay_loop_1(1);
  DDRC = 0x00;
  sei();  //enable interrupts
}

ISR(TIMER1_COMPA_vect) {
  //This is the interrupt routine to control 8 servos
  if (high==1) {
    servo_output = 0;
    write_servo_output();
    OCR1A += servo_low_time[servo_state];
    high=0;
  } else {
    servo_state++;

    if (servo_state == NUM_SERVOS) {
      //start over at servo 0
      servo_state=0;
    }

    servo_output = 0;

    if (servo_position[servo_state] != 4600) {
      sbi(servo_output,servo_state);
      write_servo_output();
    }

    OCR1A += servo_position[servo_state];
    high=1;
  }
}
