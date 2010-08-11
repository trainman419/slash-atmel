;HM55B compass module driver
;compile with avr-gcc for ATmega32 @ 16Mhz
;Maximum clock rate 5Mhz, target 4Mhz

;SCK:  PB7  , pin 3
;MIso: PB6  , pin 2
;MOSI: PB5  , pin 1
;EN:   PB4  , pin 4

.text

.global compass_init

compass_init:
;	ldi r18,0b10110000  ;load r18
	in r18,0x17        ; read current direction register
	sbr r18,0b10110000 ; set up output pins
	cbr r18,0b01000000 ; set up input pins
	out 0x17,r18       ; set output register 

	in r18,0x16        ; read current input state
	cbr r18,0b11100000 ; set clock and out low, no pull-up on input
	sbr r18,0b00010000 ; set enable high
	out 0x18,r18       ; write to output/pullup register
	
	cbr r18,0b00010000 ; set enable low
	mov r19,r18        ; copy
	sbr r19,0b10000000 ; set clock high
	sbr r18,0b00000000 ; set nothing
	ldi r20,4          ; set to 4 for use as loop counter

loop1:                 ; enable low, toggle clock 4 times ; initialization pulse
	out 0x18,r19       ; clock high
	dec r20            ; decrement loop counter
	nop                ; synchronize
	out 0x18,r18       ; clock low
	brne loop1  ;brne ; repeat loop if(r20!=0)
	
	cbr r18,0b11100000 ; set clock and out low, no pull-up on input
	sbr r18,0b00010000 ; set enable high
	out 0x18,r18       ; set output
	
;debuggin
;	rjmp loop2
	ret                ; end of function, return

.global compass

compass:
;debuggin
;	ldi r18, 0b11111111
;	ldi r19, 0b00000000
;	ldi r20, 0b10110000
;	out 0x17, r20
;fast_loop:
;	out 0x18, r18
;	nop
;	nop
;	nop
;	out 0x18, r19
;	jmp fast_loop
;
;end debuggin
	;setup direction register
	in r18,0x17        ; read current direction register
	sbr r18,0b10110000 ; set up output pins
	cbr r18,0b01000000 ; set up input pins
	out 0x17,r18       ; set output register 
	
	;start of get compass routine
	in r18,0x16        ; read state of input register
	cbr r18,0b11110000 ; clear all signal bits
	sbr r18,0b00010000 ; set enable high
	mov r0,r18         ; copy to r0
	cbr r18,0b00010000 ; set enable low
	mov r19,r18        ; copy to r19
	mov r20,r18        ; copy to r20
	mov r21,r18        ; copy to r21
	sbr r18,0b10100000 ; set clock and out high
	ldi r23,0          ; set r23 to 0 , x msb
	ldi r24,0          ; set r24 to 0 , y lsb

start_measure:	
	;this and loop2 send start measurement command, 1000
	out 0x18,r18       ; output high, clock high
	sbr r19,0b00100000 ; set output high
	sbr r20,0b10000000 ; set clock high
	out 0x18,r19       ; output high, clock low
;debuggin
;	rjmp debug1
	
	ldi r22, 3         ; set counter to 3
	nop
loop2:
	out 0x18,r20       ; clock high, output low
	dec r22            ;  decrement loop counter
	nop                ;  synchronize
	out 0x18,r21       ; clock low, output low
	brne loop2         ;  repeat loop if(r22!=0)   two cycles
	
	ldi r25,0          ; set r25 to 0 , y msb
	out 0x18,r0        ; enable high
;debuggin
;	rjmp start_measure
;	ret
	
	ldi r22,255
	ldi r26,255
debug1:
	;long ass-delay for debugging
	nop
	nop
	nop
	nop
	dec r26
	brne debug1
	ldi r26, 255
	dec r22
	brne debug1
	;end debug delay

	nop                ;
	nop                ;
	nop                ;
	ldi r26,0          ;
	
start_read:
	;loops 3 and 4 send the read sequence 1100
	;start by sending pulse to EN
	out 0x18,r12		;output low, clock low, enable low
	nop
	nop
	nop
	out 0x18,r0        ; enable high
	nop
	nop
	nop
	out 0x18,r21		;output low, clock low, enable low
	nop
	nop
	nop
	ldi r22,2          ;
loop3:
	out 0x18,r18       ;output high, clock high
	dec r22            ;
	nop                ;
	out 0x18,r19       ;output high, clock low
	brne loop3         ;
	
	ldi r22,2          ;
loop4:
	out 0x18,r20       ;output low, clock high
	dec r22            ;
	nop                ;
	out 0x18,r21       ;output low, clock low
	brne loop4         ;
	
;debuggin
;	rjmp start_read

wait:
	ldi r22,8          ;
	out 0x18,r20       ;clock high
	ldi r27,0          ;
	nop                ;
	nop                ;
read:
	out 0x18,r21       ;clock low
	sbic 0x16,6        ;two or three cycles?
	add r27,r22        ;
	out 0x18,r20       ;clock high
	lsr r22            ;
	brne read          ;
	
	cpi r27,0b00001100 ;
;	out 0x18,r0        ;
	nop                ;
	nop                ;
;debuggin
;	out 0x18,r0        ;
;	mov r22,r0         ;
;	mov r24,r27        ;
	brne start_read
	
	ldi r23,0          ;
	ldi r22,4          ;
input1:
	out 0x18,r21       ;clock low
	sbic 0x16,6        ;
	add r23,r22        ;
	out 0x18,r20       ;clock high
	lsr r22            ;
	brne input1        ;
	
	ldi r22,128        ;
input2:
	out 0x18,r21       ;clock low
	sbic 0x16,6        ;
	add r26,r22        ;
	out 0x18,r20       ;clock high
	lsr r22            ;
	brne input2        ;
	
	ldi r22,4          ;
input3:
	out 0x18,r21       ;clock low
	sbic 0x16,6        ;
	add r25,r22        ;
	out 0x18,r20       ;clock high
	lsr r22            ;
	brne input3        ;
	
	ldi r22,128        ;
input4:
	out 0x18,r21       ;clock low
	sbic 0x16,6        ;
	add r24,r22        ;
	out 0x18,r20       ;clock high
	lsr r22            ;
	brne input4        ;
	
	mov r22,r26        ;
	out 0x18,r0        ;clock low
	
;	ldi r25, 1         ;y msb
;	ldi r24, 2         ;y lsb
;	ldi r23, 4         ;x msb
;	ldi r22, 8         ;x lsb

	;fix sign bits
	sbrc r23,2
	ori r23,0b11111000
	
	sbrc r25,2
	ori r25,0b11111000

;debuggin
;	jmp start_measure
	ret

