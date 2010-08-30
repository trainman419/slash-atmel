#include <string.h>
#include "globals.h"
#include <avr/io.h>
#include <avr/interrupt.h>

// LCD Ram addresses
#define HOME                  0x80
#define LINE_2                0XC0

void write_lcd(u08 data) {
  cli();
  DDRC = 0xff;  //make port C outputs

  PORTC = data;
  delay_us(1);
  sbi(PORTB,0);  //set the clock high for the LCD 
  delay_us(1);
  cbi(PORTB,0);  //set the clock low for the LCD 
  delay_us(1);

  DDRC = 0x00;  //make port C inputs again
  sei();
}

void write_control(u08 data) {
  cbi(PORTB,1); //set RS low
  write_lcd(data);
}

void write_data(u08 data) {
  sbi(PORTB,1); //set RS high
  write_lcd(data);
}

void lcd_init(void) {
  //initialize the LCD as described in the HD44780 datasheet

  write_control(0x38);  //function set
  delay_ms(5);

  write_control(0x38);  //function set
  delay_us(160);

  write_control(0x38);  //function set
  delay_us(160);
  write_control(0x38);  //function set
  delay_us(160);
  write_control(0x08);  //turn display off
  delay_us(160);
  write_control(0x01);  //clear display
  delay_us(4000);
  write_control(0x06);  //set entry mode
  delay_us(160);
}

void print_string(char* string) {
  u08 i;
  u08 num_bytes = strlen(string);

  for (i=0;i<num_bytes;i++) {
    write_data(string[i]);
    delay_us(100);
  }
}

void print_int(u16 number) {
  u08 test[7];

  print_string((char*)itoa(number,test,10
  ));
}

void print_fp(float number) {
  char s[10];

  dtostre(number,s,3,0);
  print_string(s);
}

void clear_screen(void) {
  write_control(0x01);  //clear display
  delay_us(3400);
}

void next_line(void) {
  write_control(0xc0);  //go to the second line on the display
  delay_us(100);
}

// Moves the LCD cursor to row <row> column <col>.
// <row> ranges from 0 to 1.
// <col> ranges from 0 to 16.
void lcd_cursor(u08 row, u08 col) {
  write_control(HOME | (row << 6) | (col % 17));
  delay_us(100);
}

