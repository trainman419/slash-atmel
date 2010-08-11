#include "globals.h"
#include <avr/io.h>
#include <avr/interrupt.h>
#include <util/delay.h>
#include <math.h>

int main(void) {
  initialize();

  led_on();
  delay_ms(200);
  led_off();
  delay_ms(200);
  led_on();
  delay_ms(200);
  led_off();
  delay_ms(200);

  print_string("PolyBot Board");

  while(1) {
  }

  return 0;
}
