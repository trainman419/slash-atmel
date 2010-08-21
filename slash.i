# 1 "slash.c"
# 1 "<built-in>"
# 1 "<command-line>"
# 1 "slash.c"





# 1 "polybot_library/globals.h" 1
# 10 "polybot_library/globals.h"
typedef unsigned char u08;
typedef signed char s08;
typedef unsigned int u16;
typedef signed int s16;
# 7 "slash.c" 2
# 1 "system.h" 1






char system( void (*)(void), unsigned char sched, unsigned char pri);

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

void schedule(unsigned char sched);

void priority(unsigned char pri);

extern struct pid_entry process_table[4];
# 8 "slash.c" 2
# 1 "serial.h" 1
# 9 "serial.h"
void serial_init();


void serial_stop();


void tx_byte(u08 b);


u08 tx_ready(void);


u08 rx_ready(void);


u08 rx_byte(void);
# 9 "slash.c" 2
# 1 "compass.h" 1
# 9 "compass.h"
struct heading
{
 int x;
 int y;
};


struct heading compass();


void compass_init();
# 10 "slash.c" 2
# 1 "/usr/lib/gcc/avr/4.3.5/../../../avr/include/avr/io.h" 1 3
# 99 "/usr/lib/gcc/avr/4.3.5/../../../avr/include/avr/io.h" 3
# 1 "/usr/lib/gcc/avr/4.3.5/../../../avr/include/avr/sfr_defs.h" 1 3
# 126 "/usr/lib/gcc/avr/4.3.5/../../../avr/include/avr/sfr_defs.h" 3
# 1 "/usr/lib/gcc/avr/4.3.5/../../../avr/include/inttypes.h" 1 3
# 37 "/usr/lib/gcc/avr/4.3.5/../../../avr/include/inttypes.h" 3
# 1 "/usr/lib/gcc/avr/4.3.5/../../../avr/include/stdint.h" 1 3
# 121 "/usr/lib/gcc/avr/4.3.5/../../../avr/include/stdint.h" 3
typedef int int8_t __attribute__((__mode__(__QI__)));
typedef unsigned int uint8_t __attribute__((__mode__(__QI__)));
typedef int int16_t __attribute__ ((__mode__ (__HI__)));
typedef unsigned int uint16_t __attribute__ ((__mode__ (__HI__)));
typedef int int32_t __attribute__ ((__mode__ (__SI__)));
typedef unsigned int uint32_t __attribute__ ((__mode__ (__SI__)));

typedef int int64_t __attribute__((__mode__(__DI__)));
typedef unsigned int uint64_t __attribute__((__mode__(__DI__)));
# 142 "/usr/lib/gcc/avr/4.3.5/../../../avr/include/stdint.h" 3
typedef int16_t intptr_t;




typedef uint16_t uintptr_t;
# 159 "/usr/lib/gcc/avr/4.3.5/../../../avr/include/stdint.h" 3
typedef int8_t int_least8_t;




typedef uint8_t uint_least8_t;




typedef int16_t int_least16_t;




typedef uint16_t uint_least16_t;




typedef int32_t int_least32_t;




typedef uint32_t uint_least32_t;







typedef int64_t int_least64_t;






typedef uint64_t uint_least64_t;
# 213 "/usr/lib/gcc/avr/4.3.5/../../../avr/include/stdint.h" 3
typedef int8_t int_fast8_t;




typedef uint8_t uint_fast8_t;




typedef int16_t int_fast16_t;




typedef uint16_t uint_fast16_t;




typedef int32_t int_fast32_t;




typedef uint32_t uint_fast32_t;







typedef int64_t int_fast64_t;






typedef uint64_t uint_fast64_t;
# 273 "/usr/lib/gcc/avr/4.3.5/../../../avr/include/stdint.h" 3
typedef int64_t intmax_t;




typedef uint64_t uintmax_t;
# 38 "/usr/lib/gcc/avr/4.3.5/../../../avr/include/inttypes.h" 2 3
# 77 "/usr/lib/gcc/avr/4.3.5/../../../avr/include/inttypes.h" 3
typedef int32_t int_farptr_t;



typedef uint32_t uint_farptr_t;
# 127 "/usr/lib/gcc/avr/4.3.5/../../../avr/include/avr/sfr_defs.h" 2 3
# 100 "/usr/lib/gcc/avr/4.3.5/../../../avr/include/avr/io.h" 2 3
# 206 "/usr/lib/gcc/avr/4.3.5/../../../avr/include/avr/io.h" 3
# 1 "/usr/lib/gcc/avr/4.3.5/../../../avr/include/avr/iom32.h" 1 3
# 207 "/usr/lib/gcc/avr/4.3.5/../../../avr/include/avr/io.h" 2 3
# 408 "/usr/lib/gcc/avr/4.3.5/../../../avr/include/avr/io.h" 3
# 1 "/usr/lib/gcc/avr/4.3.5/../../../avr/include/avr/portpins.h" 1 3
# 409 "/usr/lib/gcc/avr/4.3.5/../../../avr/include/avr/io.h" 2 3

# 1 "/usr/lib/gcc/avr/4.3.5/../../../avr/include/avr/common.h" 1 3
# 411 "/usr/lib/gcc/avr/4.3.5/../../../avr/include/avr/io.h" 2 3

# 1 "/usr/lib/gcc/avr/4.3.5/../../../avr/include/avr/version.h" 1 3
# 413 "/usr/lib/gcc/avr/4.3.5/../../../avr/include/avr/io.h" 2 3


# 1 "/usr/lib/gcc/avr/4.3.5/../../../avr/include/avr/fuse.h" 1 3
# 248 "/usr/lib/gcc/avr/4.3.5/../../../avr/include/avr/fuse.h" 3
typedef struct
{
    unsigned char low;
    unsigned char high;
} __fuse_t;
# 416 "/usr/lib/gcc/avr/4.3.5/../../../avr/include/avr/io.h" 2 3


# 1 "/usr/lib/gcc/avr/4.3.5/../../../avr/include/avr/lock.h" 1 3
# 419 "/usr/lib/gcc/avr/4.3.5/../../../avr/include/avr/io.h" 2 3
# 11 "slash.c" 2
# 27 "slash.c"
static int sine[64] = {0,6,13,19,25,31,38,44,50,56,62,68,74,80,86,92,98,104,
109,115,121,126,132,137,142,147,152,157,162,167,172,177,181,185,190,194,198,
202,206,209,213,216,220,223,226,229,231,234,237,239,241,243,245,247,248,250,
251,252,253,254,255,255,256,256
};

volatile u08 battery;
volatile s16 lspeed;
volatile s16 rspeed;

u08 IR(u08 addr)
{
   u16 dist = analog(addr);
   delay_ms(1);
   dist += analog(addr);
   delay_ms(1);
   dist += analog(addr);
   delay_ms(1);
   dist += analog(addr);
   dist /= 4;
   dist = (2112 / (dist + 28)) - 5;
   return dist;
}


void thread0() {
   u08 bytes[3];
   while(1) {

      u08 steer;
      u08 speed;
      bytes[0] = 0;
      while (rx_byte() != 0);

      bytes[1] = rx_byte();
      bytes[2] = rx_byte();
      speed = bytes[1]>30?30:bytes[1];
      speed = (s16)speed + 120;
      steer = (s16)bytes[2] + 120;
      set_servo_position(0,speed);
      set_servo_position(1,steer);

      led_on();
      clear_screen();
      print_int(bytes[0]);
      print_string(" ");
      print_int(bytes[1]);
      print_string(" ");
      print_int((s08)bytes[2]);
      led_off();
   }
}


void battery_thread() {

   while(1) {
      battery = analog(0);
      yeild();
   }
}


void wheelmon() {
   u16 lcnt = 0;
   u16 rcnt = 0;
   while(1) {
# 115 "slash.c"
      yeild();
   }
}

int main(void)
{
   struct heading result;
   u08 ir=0;
   u08 i=0;
   u08 a=120;
   u08 b=120;
   u08 backup=0;
   u08 steer_inc=6;
   u16 sonar;

   lspeed = 0;
   rspeed = 0;

   initialize();
   servo_init();
   compass_init();
   serial_init();

   schedule(0);
   priority(255);
   system_init();
   system(wheelmon, 1, 0);


   set_servo_position(0,120);
   set_servo_position(1,120);
   delay_ms(40);
   while(!get_sw1()) {
      a = knob();
      set_servo_position(0,a);
      clear_screen();
      print_string("Waiting ");
      print_int(lspeed);
      print_string(" ");
      print_int(rspeed);
      next_line();
      print_int(a);
      if( get_sw1() ) {
         print_string(" +");
      } else {
         print_string(" -");
      }
      delay_ms(40);
   }

   clear_screen();
   print_string("Waiting data");


   thread0();
}
