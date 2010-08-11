/* map.c
 * a mapping program for my robot
 * NOTES:
 * sizeof(int) = 2;
 */
#include "polybot_library/globals.h"
#include <avr/io.h>
#include <avr/interrupt.h>
#include <util/delay.h>

#include <math.h>

#define MIN_POWER 30

/* occupancy grid: 128 by 96 bits */
u08 grid[1536];
u08 x;
u08 y;

/* from compass.s */
struct heading
{
	int x;
	int y;
};

/* from compass.s */
struct heading compass();

/* from compass.s */
void compass_init();

/* sine table */
static int sine[64] = {0,6,13,19,25,31,38,44,50,56,62,68,74,80,86,92,98,104,
109,115,121,126,132,137,142,147,152,157,162,167,172,177,181,185,190,194,198,
202,206,209,213,216,220,223,226,229,231,234,237,239,241,243,245,247,248,250,
251,252,253,254,255,255,256,256
};

/* inverse of sine */
/* static int cosine[64] = {256,256,256,255,255,254,253,252,251,250,248,247,245,
243,241,239,237,234,231,229,226,223,220,216,213,209,206,202,198,194,190,185,
181,177,172,167,162,157,152,147,142,137,132,126,121,115,109,104,98,92,86,80,
74,68,62,56,50,44,38,31,25,19,13,0
}; */

/* read data from the sonar */
u16 getSonar(u08 addr)
{
	while(!(UCSRA & (1<<UDRE)) ) /* not ready to transmit */
	{
		;/* wait */
	}
	UDR = addr;
	while(!(UCSRA & (1<<UDRE)) ) /* not ready to transmit */
	{
		;/* wait */
	}
	UDR = 84;

	u08 low, high;
	u16 result;
	while(!(UCSRA & (1<<RXC)) )
	{
		; /* wait */
	}
	high = UDR;
	while(!(UCSRA & (1<<RXC)) )
	{
		; /* wait */
	}
	low = UDR;
	result = high;
	result = result << 8;
	result |= low;
	return result;
}

/* initializes the USART for communicating with the sonars */
void sonar_init() {
	/* USART init code */
	UCSRB = 0x18; /* RX and TX enable, no interrupts */
	UCSRC = 0x8E; /* no parity, 1 stop, 8bit */
	UBRRH = 0x00;
	UBRRL = 0x67;
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
	/* ir always reads below 25 when we are close */
	if (ir < 25)
	{
		/* sonar gives anomalous readings when very close */
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

/* sweep the servo and take distance readings */
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

/* set a bit in the occupancy grid (128 x 96) *
 * index function: y*16 + x/8 */
void set_grid(u08 x, u08 y)
{
	u16 index = y<<4;
	index += x>>3;
	grid[index] |= 1<<(x&7);
}

/* clear a bit in the occupancy grid (128 x 96) */
void clear_grid(u08 x, u08 y)
{
	u16 index = y<<4;
	index += x>>3;
	grid[index] &= ~(1<<(x&7));
}

/* get a bit from the occupancy grid (128 x 96) */
u08 get_grid(u08 x, u08 y)
{
	u16 index = y<<4;
	index += x>>3;
	return (grid[index]&(1<<(x&7)));
}

/* calibrate compass ( I _think_ it could use a little calibration) */
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
	/* test calibration results
	 * x: -3, y: 5
	 * x: -4, y: 7
	 * x: -4, y: 6
	 * x: -5, y: 6
	 * x: -8, y: 8
	 */
	/* i = sine[i];
	i = sine[i];*/
}

/* scan the sonar, localize, and add data to the map */
/* clear a bit in the occupancy grid (128 x 96) */
/* map resolution: 5cm/grid */
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

	/* zero servo */
	set_servo_position(0,0);

	/* make compass reading, apply calibration */
	cmp = compass();
	cmp.x -= compZero.x;
	cmp.y -= compZero.y;

	/* sweep sonar, step = 4 */
	for(i=0; i<255; i+=4)
	{
		tmp = distance(0);
		set_servo_position(0,i+4);

		localX = (cmp.x * sine[63-i]) - (cmp.y * tmp);
		localY = (cmp.y * sine[63-i]) - (cmp.x * tmp);
		tmp2 = localX * localY;
		tmp2 = sqrt(tmp2);
		localX *= tmp; /* multiply before divide */
		localY *= tmp; /* for more precision */
		localX /= tmp2;
		localY /= tmp2;
		rawX[i>>2] /= 5; /* 5cm grid */
		rawY[i>>2] /= 5;

		delay_ms(9);
	}

	/* find min and max X and Y */
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

	/* for each grid location */
	tmp = 0; /* maximum observed error metric */
	posX = 64;    /* X of maximum observed error metric */
	posY = 48;    /* Y of maximum observed error metric */
	for(x=0; x<128; x++)
	{
		for(y=0; y<96; y++)
		{
			/* compute error metric */
			tmp2 = 0;
			for(i=0; i<64; i++)
			{
				/* basic error metric */
				if(rawX[i] > x);
			}
		}
	}
}

int main(void)
{
	struct heading result;
	/*u08 k=0;
	u08 b=0;
	u08 choice=0;
	u08 button=0;*/
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

		/* use calibration data */
		result.x -= compZero.x;
		result.y -= compZero.y;

		print_string("x ");     /*  2 */
		print_int(result.x);    /*  3 */
		print_string(" y ");    /*  3 */
		print_int(result.y);    /*  3 */
		/* print_string(" s ");  */ /*  3 */
		/* print_int(getSonar(0)); */ /*  3 */
					 /*  =17 */
		next_line();
		/* print_string("a "); */ /*  2 */
		/* print_int(IR(0)); */ /*  3 */
		/* print_string(" b "); */ /*  3 */
		/* print_int(analog(1)); */ /*  3 */
		/* print_string(" c "); */ /*  3 */
		/* print_int(analog(2)); */ /*  3 */
		/* print_int(i++); */ /*  =17 */
		/* print_int(distance(0));
		print_string(" "); */
		print_int(sizeof(int));
		delay_ms(200);
		/* print_int(i);
		i=sweep(); */

	}
}
