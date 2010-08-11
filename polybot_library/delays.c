#include "globals.h"
#include <avr/io.h>
#include <util/delay.h>

//delay_ms
//Provide a busy wait loop for a number of milliseconds
void delay_ms(u16 num) {  //approximate delay in milliseconds
  u16 i;

  for (i=0;i<num;i++) {
    _delay_loop_2(4000);
  }
}

//delay_us
//Provide a busy wait loop for a number of microseconds
void delay_us(u16 num) {  //approximate delay in microseconds
  u16 i;

  for (i=0;i<num;i++) {
    _delay_loop_2(4);
  }
}

