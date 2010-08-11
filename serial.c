/* serial.c
 *
 * Serial routines for ATmega32
 *
 * Author: Austin Hendrix
*/

#include "polybot_library/globals.h"
#include "serial.h"
#include <avr/io.h>
#include <avr/interrupt.h>

/* recieve circular fifo (10 bytes total 20% overhead) */
u08 rx_head = 0; /* points to next writeable byte */
volatile u08 rx_size = 0; /* number of byts in buffer */
u08 rx_buf[8];

/* send circular fifo (10 bytes total, 20% overhead) */
u08 tx_head = 0; /* next writeable byte */
volatile u08 tx_size = 0; /* number of bytes in buffer */
u08 tx_buf[8];

/* recieve interrupt */
ISR(USART_RXC_vect) /* receive complete */
{
   /* read into fifo, allow overruns for now. */
   rx_buf[rx_head++] = UDR;
   rx_head &= 7;
   rx_size++;
}

/* determine if there is data in the rx buffer */
u08 rx_ready(void) {
   return rx_size > 0;
}

/* get a byte from recieve buffer. block until data recieved */
u08 rx_byte(void) {
   while (!rx_size);
   return rx_buf[(rx_head - rx_size--) & 7];
}

/* transmit interrupt */
ISR(USART_UDRE_vect) /* ready for more data to transmit */
{
   if (tx_size) {
      UDR = tx_buf[(tx_head - tx_size--) & 7];
   } else {
	   cbi(UCSRB, 5); /* disable send interrupt */
   }
}

/* determine if there is space for another byte in the transmit buffer */
u08 tx_ready(void) {
   return tx_size < 8;
}

/* put a byte in the transmite buffer. block until space available */
void tx_byte(u08 b) {
   while (tx_size > 7);

   /* messing with buffer pointers is not atomic; need locking here */
   cbi(UCSRB, 5); /* diable send interrupt (just enough locking) */
   tx_buf[tx_head++] = b;
   tx_head &= 7;
   tx_size++;
   /* done messing with buffer pointers */

   sbi(UCSRB, 5); /* enable send interrupt */
}

/* setup and enable serial interrupts */
void serial_init()
{
   serial_stop();

   /* rx pin setup */
   cbi(DDRD, 0); /* set pin input */
   cbi(PORTD,0); /* enable input pin pull-up */

	/* USART init code */
	UCSRB = 0x18; /* RX and TX enable, interrupts */
	UCSRC = 0x8E; /* no parity, 1 stop, 8bit */
	UBRRH = 0x00; /* high byte, serial divisor */
   /*UBRRL = 0x67; /* low byte, serial divisor. 9600 baud */
   UBRRL = 0x63; /* low byte, serial divisor. 10000 baud */

   /* buffer init */
   tx_head = 0;
   tx_size = 0;
   rx_head = 0;
   rx_size = 0;
   

	/* set the USART_RXC interrupt enable bit */
	sbi(UCSRB, 7);
}

/* stops the serial interrupts */
void serial_stop()
{
	/* clear both interrupt enable bits */
	cbi(UCSRB, 5);
	cbi(UCSRB, 7);
}

