/** This program blinks an LED in order to say hello. It is intended for an Atmel
 *  AVR series processor. It was tested on an ATMega32. 
 *
 *  The first program in most handbooks and manuals usually prints “Hello, World”
 *  (or sometimes something more witty) to the screen. However, most robot control
 *  computers don’t have screens. So this program will flash an LED on and off instead.
 *  There are a lot of concepts demonstrated in this program, but don’t be intimidated
 *  by its comparatively large size. The easiest way to learn to use programs such as 
 *  this is to copy and paste them into your compiler, try running them as is, and then 
 *  make small changes; then you can see the effect of each of your changes on how the 
 *  program works.
 *  
 *  Revisions: 
 *      09-04-06  JR  Original file
 */



// The following lines cause the compiler to include files called 'stdio.h' and
// 'io.h' into the program. Each of those files contains information supplied by
// the compiler vendor which is needed to create a working program. 
#include <stdio.h>
#include <avr/io.h>

// This next line assigns the name LED_BIT to a number. This is done to make the 
// program easier to read. It also makes the program easier to change, because if you
// need to change the number, you only have to change it in one place rather than 
// doing a tedious search-and-replace operation on your entire program. 
#define LED_BIT 0x01


//------------------------------------------------------------------------------------
/** This function causes the processor to get stuck in a loop for a short time. 
 *  Delay loops aren't usually a good idea, so the function is described as dumb. 
 */

void dumb_delay (void)
    {
    long dumbcount;
    
    for (dumbcount = 0; dumbcount < 1000; dumbcount++);
    }


//------------------------------------------------------------------------------------
/** This is the main routine. It is the part of the program which begins running as
 *  soon as the processor has been started up. 
 */

main ()
    {
    // Write the LED_BIT number to the data direction register for port A. This sets
    // one pin to be an output, while all other pins become inputs. 
    DDRA = LED_BIT;

    // Write all zeros to port A. This causes the output pin to go to 0 volts and the
    // other pins, which are inputs, to turn off their pullup resistors. 
    PORTA = 0x00;

    //------------------------------- Main Loop --------------------------------------
    while (1)
        {
        // Compute the exclusive-OR of the number currently in port A and the LED bit
        // code. This causes one pin on port A to be toggled: if it was previously a
        // zero, it becomes one; if it was one, it becomes zero. 
        PORTA ^= LED_BIT;

        // Call the dumb delay function. This causes the processor to pause for a
        // short time. If this weren't done, the LED would flash so quickly that you
        // could never see it blinking (it would appear to be on at half brightness).
        // Hint: Does this suggest a technique for controlling motor speed? 
        dumb_delay ();
        }
    }