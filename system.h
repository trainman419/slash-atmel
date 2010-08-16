/* system.h
 * header file for simple operating system (system.s) for ATMega32/Polybot
 *
 * defines system(), system_init() and yeild() functions
 */

char system( void (*)(void) );

void system_init(void);

void yeild(void);

extern char current_pid;

struct pid_entry {
   unsigned char r[32];
   unsigned char sreg;
   unsigned char spl;
   unsigned char sph;
   unsigned char schedule;
   unsigned char priority;
   unsigned char last;
};

extern struct pid_entry process_table[4];
