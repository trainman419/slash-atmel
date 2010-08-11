/* system.h
 * header file for simple operating system (system.s) for ATMega32/Polybot
 *
 * defines system(), system_init() and yeild() functions
 */

char system( void (*)(void) );

void system_init(void);

void yeild(void);

extern char current_pid;
