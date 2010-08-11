# 1 "slash.c"
# 1 "<built-in>"
# 1 "<command line>"
# 1 "slash.c"





# 1 "polybot_library/globals.h" 1
# 10 "polybot_library/globals.h"
typedef unsigned char u08;
typedef signed char s08;
typedef unsigned int u16;
typedef signed int s16;
# 7 "slash.c" 2
# 1 "system.h" 1






char system( void (*)(void) );

void system_init(void);

void yeild(void);

extern char current_pid;
# 8 "slash.c" 2
# 1 "/usr/lib/gcc/avr/4.1.2/../../../../avr/include/avr/io.h" 1 3
# 86 "/usr/lib/gcc/avr/4.1.2/../../../../avr/include/avr/io.h" 3
# 1 "/usr/lib/gcc/avr/4.1.2/../../../../avr/include/avr/sfr_defs.h" 1 3
# 123 "/usr/lib/gcc/avr/4.1.2/../../../../avr/include/avr/sfr_defs.h" 3
# 1 "/usr/lib/gcc/avr/4.1.2/../../../../avr/include/inttypes.h" 1 3
# 37 "/usr/lib/gcc/avr/4.1.2/../../../../avr/include/inttypes.h" 3
# 1 "/usr/lib/gcc/avr/4.1.2/../../../../avr/include/stdint.h" 1 3
# 116 "/usr/lib/gcc/avr/4.1.2/../../../../avr/include/stdint.h" 3
typedef int int8_t __attribute__((__mode__(__QI__)));
typedef unsigned int uint8_t __attribute__((__mode__(__QI__)));
typedef int int16_t __attribute__ ((__mode__ (__HI__)));
typedef unsigned int uint16_t __attribute__ ((__mode__ (__HI__)));
typedef int int32_t __attribute__ ((__mode__ (__SI__)));
typedef unsigned int uint32_t __attribute__ ((__mode__ (__SI__)));
typedef int int64_t __attribute__((__mode__(__DI__)));
typedef unsigned int uint64_t __attribute__((__mode__(__DI__)));
# 135 "/usr/lib/gcc/avr/4.1.2/../../../../avr/include/stdint.h" 3
typedef int16_t intptr_t;




typedef uint16_t uintptr_t;
# 152 "/usr/lib/gcc/avr/4.1.2/../../../../avr/include/stdint.h" 3
typedef int8_t int_least8_t;




typedef uint8_t uint_least8_t;




typedef int16_t int_least16_t;




typedef uint16_t uint_least16_t;




typedef int32_t int_least32_t;




typedef uint32_t uint_least32_t;




typedef int64_t int_least64_t;




typedef uint64_t uint_least64_t;
# 200 "/usr/lib/gcc/avr/4.1.2/../../../../avr/include/stdint.h" 3
typedef int8_t int_fast8_t;




typedef uint8_t uint_fast8_t;




typedef int16_t int_fast16_t;




typedef uint16_t uint_fast16_t;




typedef int32_t int_fast32_t;




typedef uint32_t uint_fast32_t;




typedef int64_t int_fast64_t;




typedef uint64_t uint_fast64_t;
# 249 "/usr/lib/gcc/avr/4.1.2/../../../../avr/include/stdint.h" 3
typedef int64_t intmax_t;




typedef uint64_t uintmax_t;
# 38 "/usr/lib/gcc/avr/4.1.2/../../../../avr/include/inttypes.h" 2 3
# 76 "/usr/lib/gcc/avr/4.1.2/../../../../avr/include/inttypes.h" 3
typedef int32_t int_farptr_t;



typedef uint32_t uint_farptr_t;
# 124 "/usr/lib/gcc/avr/4.1.2/../../../../avr/include/avr/sfr_defs.h" 2 3
# 87 "/usr/lib/gcc/avr/4.1.2/../../../../avr/include/avr/io.h" 2 3
# 224 "/usr/lib/gcc/avr/4.1.2/../../../../avr/include/avr/io.h" 3
# 1 "/usr/lib/gcc/avr/4.1.2/../../../../avr/include/avr/iom32.h" 1 3
# 225 "/usr/lib/gcc/avr/4.1.2/../../../../avr/include/avr/io.h" 2 3
# 328 "/usr/lib/gcc/avr/4.1.2/../../../../avr/include/avr/io.h" 3
# 1 "/usr/lib/gcc/avr/4.1.2/../../../../avr/include/avr/portpins.h" 1 3
# 329 "/usr/lib/gcc/avr/4.1.2/../../../../avr/include/avr/io.h" 2 3
# 338 "/usr/lib/gcc/avr/4.1.2/../../../../avr/include/avr/io.h" 3
# 1 "/usr/lib/gcc/avr/4.1.2/../../../../avr/include/avr/version.h" 1 3
# 339 "/usr/lib/gcc/avr/4.1.2/../../../../avr/include/avr/io.h" 2 3
# 9 "slash.c" 2




struct heading
{
 int x;
 int y;
};


struct heading compass();


void compass_init();


static int sine[64] = {0,6,13,19,25,31,38,44,50,56,62,68,74,80,86,92,98,104,
109,115,121,126,132,137,142,147,152,157,162,167,172,177,181,185,190,194,198,
202,206,209,213,216,220,223,226,229,231,234,237,239,241,243,245,247,248,250,
251,252,253,254,255,255,256,256
};


u16 getSonar(u08 addr)
{
 while(!((*(volatile uint8_t *)((0x0B) + 0x20)) & (1<<5)) )
 {
  ;
 }
 (*(volatile uint8_t *)((0x0C) + 0x20)) = addr;
 while(!((*(volatile uint8_t *)((0x0B) + 0x20)) & (1<<5)) )
 {
  ;
 }
 (*(volatile uint8_t *)((0x0C) + 0x20)) = 84;

 u08 low, high;
 u16 result;
 while(!((*(volatile uint8_t *)((0x0B) + 0x20)) & (1<<7)) )
 {
  ;
 }
 high = (*(volatile uint8_t *)((0x0C) + 0x20));
 while(!((*(volatile uint8_t *)((0x0B) + 0x20)) & (1<<7)) )
 {
  ;
 }
 low = (*(volatile uint8_t *)((0x0C) + 0x20));
 result = high;
 result = result << 8;
 result |= low;
 return result;
}


void sonar_init() {

 (*(volatile uint8_t *)((0x0A) + 0x20)) = 0x18;
 (*(volatile uint8_t *)((0x20) + 0x20)) = 0x8E;
 (*(volatile uint8_t *)((0x20) + 0x20)) = 0x00;
 (*(volatile uint8_t *)((0x09) + 0x20)) = 0x67;
}

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

u16 distance(u08 addr)
{
 u16 ir =0;
 u16 sonar = getSonar(addr);
 ir = IR(addr);

 if (ir < 25)
 {

  if(ir > 7 && sonar > 50)
  {
   return 0;
  }
  else
  {
   return ir;
  }
 }
 else
 {
  return sonar;
 }
}

void serv()
{
   u08 pos=0;
   while(1)
   {
      set_servo_position(current_pid+2, pos);
      pos = pos>=250?0:pos+1;
      delay_ms(current_pid+2);
   }
}

void serv2()
{
   u08 pos=0;
   while(1)
   {
      set_servo_position(2, pos);
      pos = pos>=250?0:pos+1;
      delay_ms(1);
   }
}

void serv3()
{
   u08 pos=0;
   while(1)
   {
      set_servo_position(3, pos);
      pos = pos>=250?0:pos+1;
      delay_ms(2);
   }
}

void serv4()
{
   u08 pos=0;
   while(1)
   {
      set_servo_position(4, pos);
      pos = pos>=250?0:pos+1;
      delay_ms(3);
   }
}

void serv5()
{
   u08 pos=0;
   while(1)
   {
      set_servo_position(5, pos);
      pos = pos>=250?0:pos+1;
      delay_ms(4);
   }
}

int main(void)
{
 struct heading result;
 u08 ir=0;
 u08 i=0;
 u08 a=120;
 u08 b=120;
 u16 sonar;

 initialize();

 servo_init();


 compass_init();

 set_servo_position(0,120);
 set_servo_position(1,120);
 set_servo_position(2,120);
 set_servo_position(3,120);
 set_servo_position(4,120);
 set_servo_position(5,120);
 while(!get_sw1()) {
  a = knob();
  set_servo_position(0,a);
  clear_screen();
  print_string("Waiting");
  next_line();
  print_int(a);
  delay_ms(40);
 }

 system_init();
 system(serv);
 system(serv);
 system(serv);
 serv();


 while(1);

 while(1)
 {
  result = compass();
  sonar = getSonar(0);

  if(i>0) {
   i--;
   a -= 1;
   a = a<105?105:a;
   b -= 5;
   b = b<40?40:b;
   if(IR(0)<20) {
    a = 120;
    b += 5;
    i=0;
   }
  } else {
   a += 1;
   a = a>135?135:a;
   b += 5;
   b = b>120?120:b;
   if(sonar < 30) {
    i=200;
    a = 120;
    b--;
   }
  }

  set_servo_position(0, a);
  set_servo_position(1, b);
  clear_screen();
  print_string("a: ");
  print_int(a);
  print_string(" b: ");
  print_int(b);
  next_line();
  print_string("s: ");
  print_int(sonar);
  delay_ms(20);
 }
}
