// This code contains routines for the analog to digital conversion.

#include "globals.h"
#include <avr/io.h>
#include <util/delay.h>

void adc_init(void) {
  ADCSRA |= _BV(ADEN) | _BV(ADPS2) | _BV(ADPS0); //enable ADC and set prescalar to /64 

  ADMUX |= _BV(ADLAR); //left shift data 

  DDRA |= 0xE0; //set bits 5,6,7 to be outputs
}

// Returns the reading from analog sensor number <sensor>.
// <sensor> ranges from 0 to 9. 
// Each conversion takes 26us = 62.5ns * 13 cycles * 32 prescalar
u08 analog(u08 num) {
  ADMUX &= 0xE0; //clear the lower 5 bits

  //if the input is less than 7, then it is an input connected to the CD4051
  if (num < 7) {
    cbi(PORTA,7);
    cbi(PORTA,6);
    cbi(PORTA,5);
    PORTA |= ((num+1) << 5);
    _delay_loop_1(100); //wait for the voltage to stabilize
  } else {
    ADMUX |= (num-6); 
  }

  ADCSRA |= _BV(ADSC);  //start conversion
  loop_until_bit_is_clear(ADCSRA, ADSC);

  return ADCH;
}

// Returns the knob value (0-255)
u08 knob(void) {
  cbi(PORTA,7);
  cbi(PORTA,6);
  cbi(PORTA,5);
  _delay_loop_1(2);
  ADMUX &= 0xE0; //clear the lower 5 bits
  
  ADCSRA |= _BV(ADSC);  //start conversion
  loop_until_bit_is_clear(ADCSRA, ADSC);
  
  return ADCH;
}
