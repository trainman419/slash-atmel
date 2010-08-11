//Global defines

#ifndef GLOBALS_H
#define GLOBALS_H

// Define CPU speed (16MHz) for delay loop computations
#define F_CPU 16000000UL

// Datatypes
typedef unsigned char u08;
typedef signed char s08;
typedef unsigned int u16;
typedef signed int s16;

// Bit manipulation macros
#define sbi(a, b) ((a) |= 1 << (b))       //sets bit B in variable A
#define cbi(a, b) ((a) &= ~(1 << (b)))    //clears bit B in variable A
#define tbi(a, b) ((a) ^= 1 << (b))       //toggles bit B in variable A

#endif
