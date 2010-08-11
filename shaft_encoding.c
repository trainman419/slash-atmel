/***************************************************************************************
 * shaft_encoding.c
 * 
 * Uses shaft encoding to quide a robot in a square pattern over four dots based on 
 * readings from two photo sensors.  The sensors monitor a circular piece of paper with 
 * alternating white and black slices on each wheel to determine how far the robot has 
 * moved or how much it has turned.  
 *
 * For use at the CalPOly Robotics Club BotShop.  
 * This code is designed to run on the PolyBot robot development board which uses the 
 * ATMega32 microcontroller.
 *
 * Created 10/6/06 Dana Desrosiers
/***************************************************************************************/

// these files need to be included because they contain functions and other information
// you will use in this program
#include "polybot_library/globals.h"
#include <avr/io.h>
#include <avr/interrupt.h>
#include <util/delay.h>

/******************************************************************************************
 * #defines will automatically replace the word (ex. BASESPEED) with the number (ex. 50)
 * when the program is compiled.  this will make it quick and easy to change these 
 * constants everywhere in the program by changing it in just one place.  It also makes the
 * code more readable.
/******************************************************************************************/
// see BotShop Manual Chapter? Section? to learn about thresholding
#define TLOW  50     // sensor reading must be lower than this to be considered white
#define THIGH 200   // sensor reading must be higher than this to be considered black

#define LEFT_WHEEL   0     // motor port that the left motor is connected to
#define RIGHT_WHEEL  1     // motor port that the right motor is connected to
#define LEFT_SENSOR  0     // analog port that the left sensor is connected to
#define RIGHT_SENSOR 1     // analog port that the right sensor is connected to


/* we have to declare these functions so we can define them later */
int move( s08 wheel1, s08 wheel2 );
void printData( int, int );       // we don't really need to give the parameters names here
void getSensorData( u08 *leftSensor, u08 *rightSensor );

/*****************************************************************************
 * These variables are used in the interrupt routine below.  u08 means it is an 
 * unsigned 8 bit number (0-255).  An int is a signed 16 bit number (-32768 to 
 * 32768).  They are declared volatile because their values must not change 
 * between interrupts.  They might get overwritten between interrupts if they
 * are not.  Don't worry about why for now.
/****************************************************************************/
volatile u08 rightPrev = 0;     // the color the sensor saw on last interrupt
volatile u08 leftPrev = 0;      // the color the sensor saw on last interrupt
volatile int rightCount = 0;   // how much the right wheel has moved
volatile int leftCount = 0;    // how much the left wheel has moved 
volatile int spinCount = 0;    // how far has the robot turned      
volatile u08 spinning = 0;     // is the robot turning
volatile u08 turnCount = 0;    // how many turns have been made

int main(void) {
    
    initialize();

	print_string("BotShop ");
	next_line();
	print_string("Shaft Encoding");

	/*****************************************************************
         * set timer 0 to trigger the interrupt 1000 times per second.  
         * the OCR register sets how many counts between interrupts.  
         * the prescaler set how many clock cycles for every count.
	 * 16MHz / prescaler / OCR = interrupts per second.
	/*****************************************************************/
	TCCR0 |= _BV(CS02) | _BV(CS00);   // set prescaler to 1024
        OCR0 = 15;

	while( !get_sw1() );   // wait for button to be pressed
	while( get_sw1() );    // wait for button to be released

	// start watching if the wheels are turning
	TIMSK |= _BV(OCIE0);             // enable timer0 interrupt

	// start moving
	move(50,50);

	// the while loop will spin forever so the program never ends
	// the interrupt handler interrupts this loop to execute its code at regular intervals
	while(1);
	
	return 0;
}

/********************************************************************************
 * this function makes it easy to set the speed of both motors in one statement.
 * parameters wheel1 and wheel2 are signed 8 bit numbers (-127 to 127).  
 * -100 => full reverse, 
 * 0    => stop,
 * 100  => full speed ahead
/*********************************************************************************/
int move( s08 wheel1, s08 wheel2 )
{
	// LEFT_WHEEL and RIGHTWHEEL are set above in the #define section
	set_motor_power( LEFT_WHEEL, wheel1 );
	set_motor_power( RIGHT_WHEEL, -wheel2 ); // this motor is facing the opposite direction from the 
										      // other motor so it must go in the opposite direction 
	return 0;
}

/* print the current count of how many ticks the encoders observed for each wheel to the lcd screen */
void printData( int left, int right)
{
	clear_screen();
	print_string( "Left Count: ");
	print_int( left );
	next_line();
	print_string( "Right Count: " );
	print_int( right );
}

/************************************************************************** 
 * read the sensors connected to analog ports, set in #defines above, and 
 * put the result, a number between 0 and 255 (0 = white, 255 = black), 
 * into leftsensor and rightsensor.  A pointer to leftSensor and rightSensor
 * are used because otherwise these changes would be made to copies of these
 * variables and will not be saved.  By using pointers, the changes made to 
 * both of these variables will be available in the calling function without
 * having to return anything.
/**************************************************************************/
void getSensorData( u08 *leftSensor, u08 *rightSensor )
{
    *leftSensor = analog(LEFT_SENSOR);
	*rightSensor = analog(RIGHT_SENSOR);
}

/****************************************************************************************
 * This is the meat of the shaft encoding algorithm.  The photosensors (shaft encoders)
 * are read and compared to their values during the previous interrupt.  If the wheel
 * moved from a black section to white section (or vice versa) since the last interrupt,
 * a counter is incremented and displayed on the LCD screen.  Interrupt is turned off 
 * when the robot has completed a square pattern.
/****************************************************************************************/
ISR( TIMER0_COMP_vect )
{
	u08 wLeft;
	u08 wRight; 
	
	getSensorData( &wLeft, &wRight );
	
	// left wheel
	if( wLeft < TLOW && leftPrev == 1 )  // reading went from high to low
	{
		leftCount++;
		spinCount++;
		leftPrev = 0;
		printData(leftCount,rightCount);
	}
	else if( wLeft > THIGH && leftPrev == 0 )  // reading went from low to high
	{
		leftCount++;
		spinCount++;
		leftPrev = 1;
		printData(leftCount,rightCount);
	}
	// low=>low: do nothing
	// high=>high: do nothing

	// right wheel
	if( wRight < TLOW && rightPrev == 1 )  // reading went from high to low
	{
		rightCount++;
		rightPrev = 0;
		printData(leftCount,rightCount);
	}
	else if( wRight > THIGH && rightPrev == 0 )  // reading went from low to high
	{
		rightCount++;
		rightPrev = 1;
		printData(leftCount,rightCount);
	}
	
	// if the bot moved forward enough it is time to turn
	if( (rightCount+leftCount) >= 320 )   
	{
		spinning = 1;    // is spinning
		spinCount = 0;
		leftCount = 0;
		rightCount = 0;
		move(50,-50);
	}
	
	// if done turning, reset to go straight again
	if( spinning && spinCount >= 27 )   
	{
		turnCount++;
        if( turnCount == 4 )   // stop when a complete circle has been made
        {
            move (0,0);
            cli();   // turn off interrupts to end the program (does the program really end?)
        }
        else
        {
            move(50,50);
        }
		leftCount = 0;
		rightCount = 0;
		spinning = 0;   // not spinning
	}
}
