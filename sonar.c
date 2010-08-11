#include "polybot_library/globals.h"
#include <avr/io.h>
#include <avr/interrupt.h>
#include <util/delay.h>

//for SRF02 Sonars
//number of sonars, MUST be equal to the number of sonars actually attached to the UART
#define NUM_SONARS 1
u16 sonars02[NUM_SONARS];
u08 currentSonar = 0;
u08 byte = 0;

//for SRF05 Sonars
u16 sonar05 = 0;

ISR(USART_RXC_vect) //receive complete
{
	//for debugging, turn led off at beginning of receive cycle
	//led_off();
	if(byte)
	{
		cbi(UCSRB, 7);
		sbi(UCSRB, 5);
		sonars02[currentSonar] |= UDR;
		/*currentSonar++;
		if(currentSonar>=NUM_SONARS)
		{
			currentSonar=0;
		}*/
		byte = 0;
		UDR = currentSonar;
		//for debugging, turn light on at beginning of transmit cycle
		//led_on();
	} else {
		u16 read = UDR;
		read = read<<8;
		sonars02[currentSonar] = read;
		byte = 1;
	}
}

ISR(USART_UDRE_vect) //ready for more data to transmit
{
	cbi(UCSRB, 5);
	sbi(UCSRB, 7);
	UDR = 84; //ranging mode: 83:inches, 84:cm, 85:us
}

ISR(INT1_vect)
{
	sonar05 += TCNT0;
	TCCR0 = 0;
	sonar05 /= 29;
}

ISR(TIMER0_OVF_vect)
{
	TCNT0 = 0;
	sonar05 += 256;
}

//non-interrupt routine to send sonar commands
void sendSonar(u08 addr, u08 cmd)
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
	UDR = cmd;
}

//non-interrupt routine to get data from the serial port (sonar)
u16 getSonar()
{
	u08 low, high;
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
	return low + ((u16)high)*256;
}

//starts the interrupts to continuosly update the SRF02 sonar buffer
void startSonar02ISR()
{
	//USART init code
	UCSRB = 0x18; //RX and TX enable, no interrupts
	UCSRC = 0x8E; //no parity, 1 stop, 8bit
	UBRRH = 0x00;
	UBRRL = 0x67;
	//set the USART_RXC interrupt enable bit
	sbi(UCSRB, 7);
	currentSonar = 0;
	byte = 0;
	sendSonar(0, 85);
	/*while(!(UCSRA & (1<<UDRE)) ) //not ready to transmit
	{
		;//wait
	}
	UDR = currentSonar;*/
}

//stops the interrupts for the SRF02 sonars
void stopSonar02ISR()
{
	//clear both interrupt enable bits
	cbi(UCSRB, 5);
	cbi(UCSRB, 7);
}

//sets up the interrupt for the SRF05 sonar
void startSonar05ISR()
{
	//timer 0 control register
	TCCR0 = 0; //stopped; set to 1 to run from system clock
	sbi(TIMSK, 0); //enable interrupt on timer0 overflow
	//interrupt INT1 control register
	sbi(MCUCR, 3); //together, these two bits trigger
	cbi(MCUCR, 2); //an interrupt on a falling edge
	sbi(GICR, 7);  //enable interrupt INT1
	
	cbi(DDRD, 3);  //input pin direction
	cbi(PORTD, 3); //no pull up on input pin
	sbi(DDRD, 2);  //output pin direction
}

//sends a ping with the SRF05 sonar
void sonar05ping()
{
	sonar05 = 0;   //reset the sonar reading
	TCNT0 = 0;     //reset the timer
	sbi(PORTD, 2); //begin output pulse
	delay_us(10);  //wait for the sonar to recognize the pulse
	cbi(PORTD, 2); //turn the output off
	TCCR0 = 2; //stopped; set to 1 to run from system clock
	delay_ms(19);  //long enough for the sonar to return
	led_off();
}

void stopSonar05ISR()
{
	cbi(TIMSK, 0); //disable interrupt on timer0 overflow
	cbi(GICR, 7); //disable interrupt INT1
}

int main(void)
{
	initialize();
	motor_init();
	
	led_on();
	delay_ms(400);
	led_off();
	delay_ms(400);
	startSonar02ISR();
	startSonar05ISR();
	led_on();
	delay_ms(400);
	led_off();
	delay_ms(400);
	while(1)
	{
		clear_screen();
		sonar05ping();
		print_int(sonar05);
		next_line();
		delay_ms(200);
		print_int(sonars02[0]);
		delay_ms(200);
	}
}
