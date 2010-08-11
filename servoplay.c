#include "polybot_library/globals.h"
#include <avr/io.h>
#include <avr/interrupt.h>
#include <util/delay.h>

#define MIN_POWER 30

//non-interrupt routine to get data from the sonar
u16 getSonar(u08 addr)
{
	while(!(UCSRA & (1<<UDRE)) ) //not ready to transmit
	{
		;//wait
	}
	UDR = addr;
	while(!(UCSRA & (1<<UDRE)) ) //not ready to transmit
	{
		;//wait
	}
	UDR = 84;

	u08 low, high;
	u16 result;
	while(!(UCSRA & (1<<RXC)) )
	{
		; //wait
	}
	high = UDR;
	while(!(UCSRA & (1<<RXC)) )
	{
		; //wait
	}
	low = UDR;
	result = high;
	result = result << 8;
	result |= low;
	return result;
}

//initializes the USART for communicating with the sonars
void sonar_init() {
	//USART init code
	UCSRB = 0x18; //RX and TX enable, no interrupts
	UCSRC = 0x8E; //no parity, 1 stop, 8bit
	UBRRH = 0x00;
	UBRRL = 0x67;
}

u08 IR(u08 addr)
{
	u16 dist = analog(0);
	delay_ms(1);
	dist += analog(0);
	delay_ms(1);
	dist += analog(0);
	delay_ms(1);
	dist += analog(0);
	dist /= 4;
	return dist;
}

int main(void)
{
	initialize();
	servo_init();
	motor_init();
	sonar_init();
	set_servo_position(0, 120); //center the servo
	
	print_string("Rodentia Demo");
	next_line();
	print_string("by Austin");
	
	led_on();
	delay_ms(100);
	led_off();
	delay_ms(100);
	led_on();
	delay_ms(100);
	led_off();
	
	//wait for a start signal
	while(!get_sw1())
	{
		/*u08 temp;
		clear_screen();
		temp = analog(0);
		print_int(temp);*/
		delay_ms(50);
	}
	led_on();
	
	while(1)
	{ //find and point toward heading with minimum sonar reading
		u08 heading = 0;
		/*u16 minHeading = 0;
		u16 left = 0;
		u08 aLeft = 1;
		
		u16 right = 0;
		u08 aRight = 1;*/
		u16 sonar = 0x0;
		u16 temp = 0;
		set_servo_position(0, 120); //center the servo
		set_motor_power(0, MIN_POWER);
		set_motor_power(1, -MIN_POWER);
		while(heading < 170) //what's the magic number?
		{
			/*u08 tempL = analog(1);
			u08 tempR = analog(2);
			if(tempL < 25 && aLeft)
			{
				set_motor_power(0, 0);
				left++;
				aLeft = 0;
			}
			if(tempL > 180 && !aLeft)
			{
				set_motor_power(0, 0);
				left++;
				aLeft =  1;
			}
			if(tempR < 25 && aRight)
			{
				set_motor_power(1, 0);
				right++;
				aRight = 0;
			}
			if(tempR > 180 && !aRight)
			{
				set_motor_power(1, 0);
				right++;
				aRight =  1;
			}
			if(left > heading && right > heading)*/
			{
				heading++;
				temp = getSonar(0);
				if(IR(0) > 70)
				{
					temp = 0;
				}
				if(temp > sonar)
				{
					sonar = temp;
					//minHeading = heading;
				}
				clear_screen();
				print_string("here=");
				print_int(temp);
				print_string(" max=");
				print_int(sonar);
				/*next_line();
				print_string("Hdng=");
				print_int(heading);
				print_string(" minH=");
				print_int(minHeading);
				if(left < right)
				{ //left motor on
					set_motor_power(0, MIN_POWER);
				}
				else if (right < left)
				{ //right motor on
					set_motor_power(1, -MIN_POWER);
				}
				else
				{
					set_motor_power(0, MIN_POWER);
					set_motor_power(1, -MIN_POWER);
				}*/
			}
		}
		
		if(sonar > 140)
		{ //set a reasonable maximum value for sonar
			sonar = 140;
		}
		
		//turn back to minumum heading
		temp = 0;
		while( temp < sonar )
		{
			temp = getSonar(0) + 3;
			if(IR(0) > 70)
			{
				temp = 0;
			}
			clear_screen();
			print_string("here=");
			print_int(temp);
			print_string(" max=");
			print_int(sonar);
		}
		/*set_motor_power(0, -MIN_POWER);
		set_motor_power(1, MIN_POWER);
		while(heading > minHeading)
		{
			u08 tempL = analog(1);
			u08 tempR = analog(2);
			if(tempL < 25 && aLeft)
			{
				set_motor_power(0, 0);
				left--;
				aLeft = 0;
			}
			if(tempL > 180 && !aLeft)
			{
				set_motor_power(0, 0);
				left--;
				aLeft =  1;
			}
			if(tempR < 25 && aRight)
			{
				set_motor_power(1, 0);
				right--;
				aRight = 0;
			}
			if(tempR > 180 && !aRight)
			{
				set_motor_power(1, 0);
				right--;
				aRight =  1;
			}
			if(left < heading && right < heading)
			{
				heading--;
				clear_screen();
				print_string("L=");
				print_int(left);
				print_string(" R=");
				print_int(right);
				next_line();
				print_string("Hdng=");
				print_int(heading);
				print_string(" minH=");
				print_int(minHeading);
				if(left > right)
				{ //left motor on
					set_motor_power(0, -MIN_POWER);
				}
				else if (right > left)
				{ //right motor on
					set_motor_power(1, MIN_POWER);
				}
				else
				{
					set_motor_power(0, -MIN_POWER);
					set_motor_power(1, MIN_POWER);
				}
			}
		}*/
		set_motor_power(0, 0);
		set_motor_power(1, 0);
		
		//scan with IR for obstacles
		delay_ms(500);
		u08 dir=120;
		s08 dDir = 1;
		u08 dist = IR(0);
		set_motor_power(0, 100);
		set_motor_power(1, 100);
		while(dist < 100)
		{
			dir += dDir;
			set_servo_position(0, dir);
			if(dir >= 200)
			{
				dDir = -1;
			}
			if(dir <= 40)
			{
				dDir = 1;
			}
			dist = IR(0);
			clear_screen();
			print_string("Distance=");
			print_int(dist);
		}
	}
	/*u08 temp;
	
	while(1)
	{
		clear_screen();
		temp = analog(0);
		print_int(temp);
		set_servo_position(0,temp);
		delay_ms(50);
	}*/
}
