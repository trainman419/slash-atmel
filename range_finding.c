/***************************************************************************************
 * range_finding.c
 * 
 * Uses PD control to modify the speed of the two wheels of the robot based on readings
 * from an IR Range Sensor facing in the 10 o'clock position next to a curved wall.  
 * When the program starts, the robot's current distance to the wall is measured with the
 * range sensor to be used as the set point.  The robot will follow the wall at this
 * distance until it is stopped
 *
 * For use at the CalPOly Robotics Club BotShop.  
 * This code is designed to run on the POlyBot robot development board which uses the 
 * ATMega32 microcontroller.
 *
 * Created 10/12/06 Dana Desrosiers
/***************************************************************************************/

// these files need to be included because they contain functions and other information
// you will use in this program
#include "polybot_library/globals.h"
#include <avr/io.h>
#include <avr/interrupt.h>
#include <util/delay.h>

// see BotShop Manual Chapter? Section? for instructions on how to find the right values for
// KP and KD and how PID Control works.  You will need to experiment.
#define KP 0.5   // proportionality coefficient
#define KD 0.5   // derviative coefficient 

#define BASESPEED     50    // percent of max speed that the robot will travel
#define LEFT_WHEEL    0     // motor port that the left motor is connected to
#define RIGHT_WHEEL   1     // motor port that the right motor is connected to
#define RANGE_SENSOR  0     // analog port that the left sensor is connected to

/* we have to declare this functions so we can define them later */
int move( s08 wheel1, s08 wheel2 );

/*****************************************************************************
 * These variable is used in the interrupt routine below.  u08 means it is an 
 * unsigned 8 bit number (0-255).  it is declared volatile because its value
 * must not change between interrupts.  it might get overwritten between 
 * interrupts if it is not.  Don't worry about why for now.
/****************************************************************************/
volatile u08 prevError = 0;
volatile u08 set_point;

int main(void) {
    
    initialize();

    print_string("BotShop");
    next_line();
    print_string("Wall Following");

    /*****************************************************************
     * set timer 0 to trigger the interrupt 100 times per second.  
     * the OCR register sets how many counts between interrupts.  
     * the prescaler set how many clock cycles for every count.
     * 16MHz / prescaler / OCR = interrupts per second.
    /*****************************************************************/
    TCCR0 |= _BV(CS02) | _BV(CS00);   // set prescaler to 1024
    OCR0 = 156;

    while( !get_sw1() );   // wait for button to be pressed
    while( get_sw1() );    // wait for button to be released

    set_point = analog(RANGE_SENSOR);
	
    // enable timer 0 interrupt
    TIMSK |= _BV(OCIE0);             // enable timer0 interrupt
	
    // start moving
    move( BASESPEED, BASESPEED );

    // the while loop will spin forever so the program never ends
    // the interrupt handler interrupts this loop to execute its code at regular intervals
    while( 1 );
	
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

/**********************************************************************************
 * This is the meat of the wall following algorithm.  Data is read from the range
 * sensor indicating how far the robot is from the wall.  The goal is to keep
 * this distance the same as the set point.  PD control is used to calculate a 
 * correction to send to the wheels to keep the sensors balanced and the robot over
 * the line.  PD is a simplification of PID control, read about how this works in 
 * the BotShop manual Programming Section.
 **********************************************************************************/
ISR( TIMER0_COMP_vect )
{
	u08 error;
	u08 prop;       // the proportional(P) term in PID control
	u08 deriv;      // the dervative(D) term in PID control 
	u08 correction; // the total correction
	
	// we want the sensor reading to be the same as the set point. This indicates that 
	// The robot is the same distance from the wall as when it started.  
	// the error is the difference between the two
	error = analog(RANGE_SENSOR) - set_point;   
	
	prop = error*KP;                
	deriv = (prevError-error)*KD;   
	correction = prop-deriv;         
			
	/*********************************************************************
	 * change the speed of the wheels by the amount determined by
	 * correction.  If correction is positive, the left sensor is more
	 * over the line than the right sensor, so the left wheel slows
	 * down and the right wheel speeds up to make the robot veer left
	 * back to the center.  If the right sensor is more over the line
	 * than the left, correction will be negative and the opposite
	 * action will occur.
	/*********************************************************************/
	move( BASESPEED - correction, BASESPEED + correction );
	
	prevError = error;
	
	/***********************************************************************
	 * TCNT is the register that actually does the counting.  The interrupt
	 * is triggered when TCNT = OCR.  We need to reset it so it can start
	 * counting again for the next interrupt.
	/***********************************************************************/ 
	TCNT0 = 0;
}
