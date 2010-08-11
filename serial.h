/* serial.h
 *
 * header file for serial function for ATMega32
 *
 * Author: Austin Hendrix
 */

/* setup and enable serial interrupts */
void serial_init();

/* stops the serial interrupts */
void serial_stop();

/* put a byte in the transmite buffer. block until space available */
void tx_byte(u08 b);

/* determine if there is space for another byte in the transmit buffer */
u08 tx_ready(void);

/* determine if there is data in the rx buffer */
u08 rx_ready(void);

/* get a byte from recieve buffer. block until data recieved */
u08 rx_byte(void);

