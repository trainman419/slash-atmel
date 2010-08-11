# 1 "map.c"
# 1 "<built-in>"
# 1 "<command line>"
# 1 "map.c"





# 1 "polybot_library/globals.h" 1
# 10 "polybot_library/globals.h"
typedef unsigned char u08;
typedef signed char s08;
typedef unsigned int u16;
typedef signed int s16;
# 7 "map.c" 2
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
# 8 "map.c" 2
# 1 "/usr/lib/gcc/avr/4.1.2/../../../../avr/include/avr/interrupt.h" 1 3
# 9 "map.c" 2
# 1 "/usr/lib/gcc/avr/4.1.2/../../../../avr/include/util/delay.h" 1 3
# 84 "/usr/lib/gcc/avr/4.1.2/../../../../avr/include/util/delay.h" 3
static inline void _delay_loop_1(uint8_t __count) __attribute__((always_inline));
static inline void _delay_loop_2(uint16_t __count) __attribute__((always_inline));
static inline void _delay_us(double __us) __attribute__((always_inline));
static inline void _delay_ms(double __ms) __attribute__((always_inline));
# 101 "/usr/lib/gcc/avr/4.1.2/../../../../avr/include/util/delay.h" 3
void
_delay_loop_1(uint8_t __count)
{
 __asm__ volatile (
  "1: dec %0" "\n\t"
  "brne 1b"
  : "=r" (__count)
  : "0" (__count)
 );
}
# 123 "/usr/lib/gcc/avr/4.1.2/../../../../avr/include/util/delay.h" 3
void
_delay_loop_2(uint16_t __count)
{
 __asm__ volatile (
  "1: sbiw %0,1" "\n\t"
  "brne 1b"
  : "=w" (__count)
  : "0" (__count)
 );
}
# 150 "/usr/lib/gcc/avr/4.1.2/../../../../avr/include/util/delay.h" 3
void
_delay_us(double __us)
{
 uint8_t __ticks;
 double __tmp = ((16000000UL) / 3e6) * __us;
 if (__tmp < 1.0)
  __ticks = 1;
 else if (__tmp > 255)
  __ticks = 0;
 else
  __ticks = (uint8_t)__tmp;
 _delay_loop_1(__ticks);
}
# 175 "/usr/lib/gcc/avr/4.1.2/../../../../avr/include/util/delay.h" 3
void
_delay_ms(double __ms)
{
 uint16_t __ticks;
 double __tmp = ((16000000UL) / 4e3) * __ms;
 if (__tmp < 1.0)
  __ticks = 1;
 else if (__tmp > 65535)
  __ticks = 0;
 else
  __ticks = (uint16_t)__tmp;
 _delay_loop_2(__ticks);
}
# 10 "map.c" 2

# 1 "/usr/lib/gcc/avr/4.1.2/../../../../avr/include/math.h" 1 3
# 93 "/usr/lib/gcc/avr/4.1.2/../../../../avr/include/math.h" 3
extern double cos(double __x) __attribute__((__const__));







extern double fabs(double __x) __attribute__((__const__));
# 118 "/usr/lib/gcc/avr/4.1.2/../../../../avr/include/math.h" 3
extern double fmod(double __x, double __y) __attribute__((__const__));
# 130 "/usr/lib/gcc/avr/4.1.2/../../../../avr/include/math.h" 3
extern double modf(double __value, double *__iptr);







extern double sin(double __x) __attribute__((__const__));






extern double sqrt(double __x) __attribute__((__const__));







extern double tan(double __x) __attribute__((__const__));







extern double floor(double __x) __attribute__((__const__));







extern double ceil(double __x) __attribute__((__const__));
# 183 "/usr/lib/gcc/avr/4.1.2/../../../../avr/include/math.h" 3
extern double frexp(double __value, int *__exp);
# 197 "/usr/lib/gcc/avr/4.1.2/../../../../avr/include/math.h" 3
extern double ldexp(double __x, int __exp) __attribute__((__const__));






extern double exp(double __x) __attribute__((__const__));






extern double cosh(double __x) __attribute__((__const__));






extern double sinh(double __x) __attribute__((__const__));






extern double tanh(double __x) __attribute__((__const__));
# 236 "/usr/lib/gcc/avr/4.1.2/../../../../avr/include/math.h" 3
extern double acos(double __x) __attribute__((__const__));
# 247 "/usr/lib/gcc/avr/4.1.2/../../../../avr/include/math.h" 3
extern double asin(double __x) __attribute__((__const__));
# 258 "/usr/lib/gcc/avr/4.1.2/../../../../avr/include/math.h" 3
extern double atan(double __x) __attribute__((__const__));
# 269 "/usr/lib/gcc/avr/4.1.2/../../../../avr/include/math.h" 3
extern double atan2(double __y, double __x) __attribute__((__const__));
# 278 "/usr/lib/gcc/avr/4.1.2/../../../../avr/include/math.h" 3
extern double log(double __x) __attribute__((__const__));
# 287 "/usr/lib/gcc/avr/4.1.2/../../../../avr/include/math.h" 3
extern double log10(double __x) __attribute__((__const__));






extern double pow(double __x, double __y) __attribute__((__const__));







extern int isnan(double __x) __attribute__((__const__));







extern int isinf(double __x) __attribute__((__const__));
# 320 "/usr/lib/gcc/avr/4.1.2/../../../../avr/include/math.h" 3
extern double square(double __x) __attribute__((__const__));
# 12 "map.c" 2




u08 grid[1536];
u08 x;
u08 y;


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
# 48 "map.c"
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


u08 sweep()
{
 u08 i=0;
 u16 tmp;
 u16 min = 65535;
 u08 min_pos;
 do
 {
  tmp = distance(0);
  set_servo_position(0, i);
  if(tmp < min)
  {
   min = tmp;
   min_pos = i;
  }
  delay_ms(10);
  i++;
 } while(i>0);
 return min_pos;
}



void set_grid(u08 x, u08 y)
{
 u16 index = y<<4;
 index += x>>3;
 grid[index] |= 1<<(x&7);
}


void clear_grid(u08 x, u08 y)
{
 u16 index = y<<4;
 index += x>>3;
 grid[index] &= ~(1<<(x&7));
}


u08 get_grid(u08 x, u08 y)
{
 u16 index = y<<4;
 index += x>>3;
 return (grid[index]&(1<<(x&7)));
}


struct heading compZero;

void calCompass()
{
 int xmin, xmax;
 int ymin, ymax;
 struct heading temp;
 u08 i=0;

 temp = compass();

 xmin = temp.x;
 xmax = temp.x;
 ymin = temp.y;
 ymax = temp.y;

 clear_screen();
 print_string("Calibrating");
 next_line();
 print_string("Compass");

 set_motor_power(0,25);
 set_motor_power(1,-25);


 for(i=0; i<255; i++)
 {
  clear_screen();
  print_string("Calibrating");
  next_line();
  print_string("Compass");

  temp = compass();
  if(xmin > temp.x)
   xmin = temp.x;
  else if(xmax < temp.x)
   xmax = temp.x;

  if(ymin > temp.y)
   ymin = temp.y;
  else if(ymax < temp.y)
   ymax = temp.y;
  delay_ms(10);
 }
 set_motor_power(0,0);
 set_motor_power(1,0);

 compZero.x = (xmin+xmax)>>1;
 compZero.y = (ymin+ymax)>>1;
 clear_screen();
 print_string("x: ");
 print_int( (xmin+xmax)>>1 );
 next_line();
 print_string("y: ");
 print_int( (ymin+ymax)>>1 );
 while(!get_sw1());
# 239 "map.c"
}




void scan()
{
 s08 rawX[64];
 s08 rawY[64];
 u08 i;
 s16 localX, localY;
 u08 x, y;
 s08 minX, minY, maxX, maxY;
 s08 posX, posY;
 u16 tmp, tmp2, tmp3;
 struct heading cmp;


 set_servo_position(0,0);


 cmp = compass();
 cmp.x -= compZero.x;
 cmp.y -= compZero.y;


 for(i=0; i<255; i+=4)
 {
  tmp = distance(0);
  set_servo_position(0,i+4);

  localX = (cmp.x * sine[63-i]) - (cmp.y * tmp);
  localY = (cmp.y * sine[63-i]) - (cmp.x * tmp);
  tmp2 = localX * localY;
  tmp2 = sqrt(tmp2);
  localX *= tmp;
  localY *= tmp;
  localX /= tmp2;
  localY /= tmp2;
  rawX[i>>2] /= 5;
  rawY[i>>2] /= 5;

  delay_ms(9);
 }


 for(i=0; i<64; i++)
 {
  if(rawX[i] < minX)
   minX = rawX[i];
  if(rawX[i] > maxX)
   maxX = rawX[i];
  if(rawY[i] < minY)
   minY = rawY[i];
  if(rawY[i] > maxY)
   maxY = rawY[i];
 }


 tmp = 0;
 posX = 64;
 posY = 48;
 for(x=0; x<128; x++)
 {
  for(y=0; y<96; y++)
  {

   tmp2 = 0;
   for(i=0; i<64; i++)
   {

    if(rawX[i] > x);
   }
  }
 }
}

int main(void)
{
 struct heading result;




 u08 ir=0;
 u08 i=0;

 x = 64;
 y = 48;
 initialize();
 motor_init();
 servo_init();
 set_motor_power(0,0);
 set_motor_power(1,0);
 set_motor_power(2,0);
 set_motor_power(3,0);
 compass_init();
 sonar_init();

 calCompass();
 while(1)
 {
  clear_screen();
  result = compass();


  result.x -= compZero.x;
  result.y -= compZero.y;

  print_string("x ");
  print_int(result.x);
  print_string(" y ");
  print_int(result.y);



  next_line();
# 365 "map.c"
  print_int(sizeof(int));
  delay_ms(200);



 }
}
