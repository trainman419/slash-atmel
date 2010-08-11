	.file	"map.c"
	.arch atmega32
__SREG__ = 0x3f
__SP_H__ = 0x3e
__SP_L__ = 0x3d
__tmp_reg__ = 0
__zero_reg__ = 1
	.global __do_copy_data
	.global __do_clear_bss
	.text
.global	getSonar
	.type	getSonar, @function
getSonar:
/* prologue: frame size=0 */
/* prologue end (size=0) */
.L3:
	sbis 43-0x20,5
	rjmp .L3
	out 44-0x20,r24
.L5:
	sbis 43-0x20,5
	rjmp .L5
	ldi r24,lo8(84)
	out 44-0x20,r24
.L7:
	sbis 43-0x20,7
	rjmp .L7
	in r24,44-0x20
.L9:
	sbis 43-0x20,7
	rjmp .L9
	in r18,44-0x20
	clr r25
	mov r25,r24
	clr r24
	clr r19
	or r24,r18
	or r25,r19
/* epilogue: frame size=0 */
	ret
/* epilogue end (size=1) */
/* function getSonar size 20 (19) */
	.size	getSonar, .-getSonar
.global	sonar_init
	.type	sonar_init, @function
sonar_init:
/* prologue: frame size=0 */
/* prologue end (size=0) */
	ldi r24,lo8(24)
	out 42-0x20,r24
	ldi r24,lo8(-114)
	out 64-0x20,r24
	out 64-0x20,__zero_reg__
	ldi r24,lo8(103)
	out 41-0x20,r24
/* epilogue: frame size=0 */
	ret
/* epilogue end (size=1) */
/* function sonar_init size 8 (7) */
	.size	sonar_init, .-sonar_init
.global	set_grid
	.type	set_grid, @function
set_grid:
/* prologue: frame size=0 */
/* prologue end (size=0) */
	mov r30,r22
	clr r31
	ldi r20,4
1:	lsl r30
	rol r31
	dec r20
	brne 1b
	mov r25,r24
	lsr r25
	lsr r25
	lsr r25
	add r30,r25
	adc r31,__zero_reg__
	subi r30,lo8(-(grid))
	sbci r31,hi8(-(grid))
	andi r24,lo8(7)
	ldi r18,lo8(1)
	ldi r19,hi8(1)
	rjmp 2f
1:	lsl r18
	rol r19
2:	dec r24
	brpl 1b
	ld r24,Z
	or r24,r18
	st Z,r24
/* epilogue: frame size=0 */
	ret
/* epilogue end (size=1) */
/* function set_grid size 28 (27) */
	.size	set_grid, .-set_grid
.global	clear_grid
	.type	clear_grid, @function
clear_grid:
/* prologue: frame size=0 */
/* prologue end (size=0) */
	mov r30,r22
	clr r31
	ldi r21,4
1:	lsl r30
	rol r31
	dec r21
	brne 1b
	mov r25,r24
	lsr r25
	lsr r25
	lsr r25
	add r30,r25
	adc r31,__zero_reg__
	subi r30,lo8(-(grid))
	sbci r31,hi8(-(grid))
	andi r24,lo8(7)
	ldi r18,lo8(1)
	ldi r19,hi8(1)
	rjmp 2f
1:	lsl r18
	rol r19
2:	dec r24
	brpl 1b
	com r18
	ld r24,Z
	and r24,r18
	st Z,r24
/* epilogue: frame size=0 */
	ret
/* epilogue end (size=1) */
/* function clear_grid size 29 (28) */
	.size	clear_grid, .-clear_grid
.global	get_grid
	.type	get_grid, @function
get_grid:
/* prologue: frame size=0 */
/* prologue end (size=0) */
	mov r30,r22
	clr r31
	ldi r22,4
1:	lsl r30
	rol r31
	dec r22
	brne 1b
	mov r25,r24
	lsr r25
	lsr r25
	lsr r25
	subi r30,lo8(-(grid))
	sbci r31,hi8(-(grid))
	add r30,r25
	adc r31,__zero_reg__
	andi r24,lo8(7)
	ldi r18,lo8(1)
	ldi r19,hi8(1)
	rjmp 2f
1:	lsl r18
	rol r19
2:	dec r24
	brpl 1b
	ld r24,Z
	and r24,r18
	clr r25
/* epilogue: frame size=0 */
	ret
/* epilogue end (size=1) */
/* function get_grid size 28 (27) */
	.size	get_grid, .-get_grid
	.data
.LC0:
	.string	"Calibrating"
.LC1:
	.string	"Compass"
.LC2:
	.string	"x: "
.LC3:
	.string	"y: "
	.text
.global	calCompass
	.type	calCompass, @function
calCompass:
/* prologue: frame size=0 */
	ldi r26,lo8(0)
	ldi r27,hi8(0)
	ldi r30,lo8(gs(1f))
	ldi r31,hi8(gs(1f))
	jmp __prologue_saves__+16
1:
/* prologue end (size=6) */
	call compass
	movw r14,r22
	movw r16,r24
	call clear_screen
	ldi r24,lo8(.LC0)
	ldi r25,hi8(.LC0)
	call print_string
	call next_line
	ldi r24,lo8(.LC1)
	ldi r25,hi8(.LC1)
	call print_string
	ldi r22,lo8(25)
	ldi r23,hi8(25)
	ldi r24,lo8(0)
	ldi r25,hi8(0)
	call set_motor_power
	ldi r22,lo8(-25)
	ldi r23,hi8(-25)
	ldi r24,lo8(1)
	ldi r25,hi8(1)
	call set_motor_power
	movw r12,r14
	movw r28,r14
	movw r10,r16
	movw r14,r16
	ldi r16,lo8(0)
.L29:
	call clear_screen
	ldi r24,lo8(.LC0)
	ldi r25,hi8(.LC0)
	call print_string
	call next_line
	ldi r24,lo8(.LC1)
	ldi r25,hi8(.LC1)
	call print_string
	call compass
	movw r20,r24
	cp r22,r12
	cpc r23,r13
	brge .L30
	movw r12,r22
	rjmp .L32
.L30:
	cp r28,r22
	cpc r29,r23
	brge .L32
	movw r28,r22
.L32:
	cp r20,r10
	cpc r21,r11
	brge .L34
	movw r10,r20
	rjmp .L36
.L34:
	cp r14,r20
	cpc r15,r21
	brge .L36
	movw r14,r20
.L36:
	ldi r24,lo8(10)
	ldi r25,hi8(10)
	call delay_ms
	subi r16,lo8(-(1))
	cpi r16,lo8(-1)
	brne .L29
	ldi r22,lo8(0)
	ldi r23,hi8(0)
	ldi r24,lo8(0)
	ldi r25,hi8(0)
	call set_motor_power
	ldi r22,lo8(0)
	ldi r23,hi8(0)
	ldi r24,lo8(1)
	ldi r25,hi8(1)
	call set_motor_power
	movw r16,r12
	add r16,r28
	adc r17,r29
	asr r17
	ror r16
	sts (compZero)+1,r17
	sts compZero,r16
	add r14,r10
	adc r15,r11
	asr r15
	ror r14
	sts (compZero+2)+1,r15
	sts compZero+2,r14
	call clear_screen
	ldi r24,lo8(.LC2)
	ldi r25,hi8(.LC2)
	call print_string
	movw r24,r16
	call print_int
	call next_line
	ldi r24,lo8(.LC3)
	ldi r25,hi8(.LC3)
	call print_string
	movw r24,r14
	call print_int
.L39:
	call get_sw1
	or r24,r25
	breq .L39
/* epilogue: frame size=0 */
	ldi r30,10
	in r28,__SP_L__
	in r29,__SP_H__
	jmp __epilogue_restores__+16
/* epilogue end (size=5) */
/* function calCompass size 135 (124) */
	.size	calCompass, .-calCompass
.global	IR
	.type	IR, @function
IR:
/* prologue: frame size=0 */
	push r12
	push r13
	push r14
	push r15
	push r16
	push r17
/* prologue end (size=6) */
	mov r12,r24
	clr r13
	movw r24,r12
	call analog
	movw r16,r24
	ldi r24,lo8(1)
	ldi r25,hi8(1)
	call delay_ms
	movw r24,r12
	call analog
	add r16,r24
	adc r17,r25
	ldi r24,lo8(1)
	ldi r25,hi8(1)
	call delay_ms
	movw r24,r12
	call analog
	movw r14,r24
	ldi r24,lo8(1)
	ldi r25,hi8(1)
	call delay_ms
	movw r24,r12
	call analog
	add r14,r24
	adc r15,r25
	add r16,r14
	adc r17,r15
	lsr r17
	ror r16
	lsr r17
	ror r16
	subi r16,lo8(-(28))
	sbci r17,hi8(-(28))
	ldi r24,lo8(2112)
	ldi r25,hi8(2112)
	movw r22,r16
	call __udivmodhi4
	subi r22,lo8(-(-5))
	mov r24,r22
	clr r25
/* epilogue: frame size=0 */
	pop r17
	pop r16
	pop r15
	pop r14
	pop r13
	pop r12
	ret
/* epilogue end (size=7) */
/* function IR size 61 (48) */
	.size	IR, .-IR
.global	distance
	.type	distance, @function
distance:
/* prologue: frame size=0 */
	push r17
	push r28
	push r29
/* prologue end (size=3) */
	mov r17,r24
	call getSonar
	movw r28,r24
	mov r24,r17
	call IR
	clr r25
	cpi r24,25
	cpc r25,__zero_reg__
	brlo .L49
	movw r24,r28
	rjmp .L51
.L49:
	cpi r24,8
	cpc r25,__zero_reg__
	brlo .L51
	sbiw r28,51
	brlo .L51
	ldi r24,lo8(0)
	ldi r25,hi8(0)
.L51:
/* epilogue: frame size=0 */
	pop r29
	pop r28
	pop r17
	ret
/* epilogue end (size=4) */
/* function distance size 28 (21) */
	.size	distance, .-distance
.global	scan
	.type	scan, @function
scan:
/* prologue: frame size=0 */
	push r17
/* prologue end (size=1) */
	ldi r22,lo8(0)
	ldi r23,hi8(0)
	ldi r24,lo8(0)
	ldi r25,hi8(0)
	call set_servo_position
	call compass
	ldi r17,lo8(0)
.L56:
	ldi r24,lo8(0)
	call distance
	mov r22,r17
	clr r23
	subi r22,lo8(-(4))
	sbci r23,hi8(-(4))
	ldi r24,lo8(0)
	ldi r25,hi8(0)
	call set_servo_position
	ldi r24,lo8(9)
	ldi r25,hi8(9)
	call delay_ms
	subi r17,lo8(-(4))
	cpi r17,lo8(-1)
	brne .L56
	ldi r24,lo8(0)
.L59:
	subi r24,lo8(-(1))
	cpi r24,lo8(-128)
	brne .L59
/* epilogue: frame size=0 */
	pop r17
	ret
/* epilogue end (size=2) */
/* function scan size 34 (31) */
	.size	scan, .-scan
.global	sweep
	.type	sweep, @function
sweep:
/* prologue: frame size=0 */
	ldi r26,lo8(0)
	ldi r27,hi8(0)
	ldi r30,lo8(gs(1f))
	ldi r31,hi8(gs(1f))
	jmp __prologue_saves__+18
1:
/* prologue end (size=6) */
	ldi r26,lo8(-1)
	mov r12,r26
	mov r13,r26
	clr r14
	clr r15
.L66:
	mov r16,r14
	ldi r24,lo8(0)
	call distance
	movw r28,r24
	clr r17
	movw r22,r16
	ldi r24,lo8(0)
	ldi r25,hi8(0)
	call set_servo_position
	cp r28,r12
	cpc r29,r13
	brsh .L67
	movw r12,r28
	mov r11,r14
.L67:
	ldi r24,lo8(10)
	ldi r25,hi8(10)
	call delay_ms
	sec
	adc r14,__zero_reg__
	adc r15,__zero_reg__
	ldi r24,lo8(256)
	cp r14,r24
	ldi r24,hi8(256)
	cpc r15,r24
	brne .L66
	mov r24,r11
	clr r25
/* epilogue: frame size=0 */
	ldi r30,9
	in r28,__SP_L__
	in r29,__SP_H__
	jmp __epilogue_restores__+18
/* epilogue end (size=5) */
/* function sweep size 46 (35) */
	.size	sweep, .-sweep
	.data
.LC4:
	.string	"x "
.LC5:
	.string	" y "
	.text
.global	main
	.type	main, @function
main:
/* prologue: frame size=0 */
	push r14
	push r15
	push r16
	push r17
/* prologue end (size=4) */
	ldi r24,lo8(64)
	sts x,r24
	ldi r24,lo8(48)
	sts y,r24
	call initialize
	call motor_init
	call servo_init
	ldi r22,lo8(0)
	ldi r23,hi8(0)
	ldi r24,lo8(0)
	ldi r25,hi8(0)
	call set_motor_power
	ldi r22,lo8(0)
	ldi r23,hi8(0)
	ldi r24,lo8(1)
	ldi r25,hi8(1)
	call set_motor_power
	ldi r22,lo8(0)
	ldi r23,hi8(0)
	ldi r24,lo8(2)
	ldi r25,hi8(2)
	call set_motor_power
	ldi r22,lo8(0)
	ldi r23,hi8(0)
	ldi r24,lo8(3)
	ldi r25,hi8(3)
	call set_motor_power
	call compass_init
	ldi r24,lo8(24)
	out 42-0x20,r24
	ldi r24,lo8(-114)
	out 64-0x20,r24
	out 64-0x20,__zero_reg__
	ldi r24,lo8(103)
	out 41-0x20,r24
	call calCompass
.L74:
	call clear_screen
	call compass
	lds r18,compZero
	lds r19,(compZero)+1
	movw r16,r22
	sub r16,r18
	sbc r17,r19
	lds r18,compZero+2
	lds r19,(compZero+2)+1
	movw r14,r24
	sub r14,r18
	sbc r15,r19
	ldi r24,lo8(.LC4)
	ldi r25,hi8(.LC4)
	call print_string
	movw r24,r16
	call print_int
	ldi r24,lo8(.LC5)
	ldi r25,hi8(.LC5)
	call print_string
	movw r24,r14
	call print_int
	call next_line
	ldi r24,lo8(2)
	ldi r25,hi8(2)
	call print_int
	ldi r24,lo8(200)
	ldi r25,hi8(200)
	call delay_ms
	rjmp .L74
/* epilogue: frame size=0 */
/* epilogue: noreturn */
/* epilogue end (size=0) */
/* function main size 94 (90) */
	.size	main, .-main
	.comm grid,1536,1
	.comm x,1,1
	.comm y,1,1
	.comm compZero,4,1
/* File "map.c": code  511 = 0x01ff ( 457), prologues  26, epilogues  28 */
