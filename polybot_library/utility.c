//Various utility functions for the PolyBot board

#include "globals.h"
#include <avr/io.h>
#include <avr/interrupt.h>
#include <util/delay.h>

//returns status of the SW1 button
//returns 1 when the button is pressed
//returns 0 when the button is not pressed
u08 get_sw1(void) {
  return (s08)PIND >= 0;
}

//turns the relay driver port on
void relay_on(void) {
  sbi(DDRB,3);
  sbi(PORTB,3);
}

//turns the relay driver port off
void relay_off(void) {
  sbi(DDRB,3);
  cbi(PORTB,3);
}

//turns the led on
void led_on(void) {
  sbi(DDRA,4);
  sbi(PORTA,4);
}

//turns the led off
void led_off(void) {
  sbi(DDRA,4);
  cbi(PORTA,4);
}

//returns the value of a digital input
u08 digital(u08 num) {
  u08 value;

  cli(); // disable interrupts
  DDRC = 0;
  cbi(PORTD,4); //enable digital input latch
  _delay_loop_1(1); // delay roughly 1uS
  value = PINC;
  _delay_loop_1(1); // delay roughly 1uS
  sbi(PORTD,4); //disable digital input latch
  sei(); // enable interrupts

  return ((value & _BV(num)) != 0);
}

//perform all initialization
void initialize(void) {
  DDRC = 0x00;

  sbi(DDRD,4);
  sbi(DDRD,5);
  sbi(DDRD,6);

  sbi(PORTD,4);
  cbi(PORTD,5);
  cbi(PORTD,6);

  sbi(DDRB,0);
  sbi(DDRB,1);
  cbi(PORTB,0); //set E low
  cbi(PORTB,1); //set RS low

  sbi(PORTD,7); //enable pullup for switch

  //initialization for each system
  //commenting out unused systems increases overall performance
  //servo_init();
  adc_init();
  lcd_init();
  //motor_init();
  
  /*Turn off watchdog timer*/
  WDTCR |= (1<<WDTOE) | (1<<WDE);
  WDTCR = 0x00;

  write_control(0x0C); //turn on lcd
  delay_us(160);
}
