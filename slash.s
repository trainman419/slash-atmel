	.file	"slash.c"
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
.global	serv5
	.type	serv5, @function
serv5:
/* prologue: frame size=0 */
	push r17
/* prologue end (size=1) */
	ldi r22,lo8(0)
	ldi r23,hi8(0)
	ldi r24,lo8(5)
	ldi r25,hi8(5)
	call set_servo_position
	ldi r17,lo8(0)
.L23:
	subi r17,lo8(-(1))
.L24:
	ldi r24,lo8(4)
	ldi r25,hi8(4)
	call delay_ms
	mov r22,r17
	clr r23
	ldi r24,lo8(5)
	ldi r25,hi8(5)
	call set_servo_position
	cpi r17,lo8(-6)
	brlo .L23
	ldi r17,lo8(0)
	rjmp .L24
/* epilogue: frame size=0 */
/* epilogue: noreturn */
/* epilogue end (size=0) */
/* function serv5 size 23 (22) */
	.size	serv5, .-serv5
.global	serv4
	.type	serv4, @function
serv4:
/* prologue: frame size=0 */
	push r17
/* prologue end (size=1) */
	ldi r22,lo8(0)
	ldi r23,hi8(0)
	ldi r24,lo8(4)
	ldi r25,hi8(4)
	call set_servo_position
	ldi r17,lo8(0)
.L30:
	subi r17,lo8(-(1))
.L31:
	ldi r24,lo8(3)
	ldi r25,hi8(3)
	call delay_ms
	mov r22,r17
	clr r23
	ldi r24,lo8(4)
	ldi r25,hi8(4)
	call set_servo_position
	cpi r17,lo8(-6)
	brlo .L30
	ldi r17,lo8(0)
	rjmp .L31
/* epilogue: frame size=0 */
/* epilogue: noreturn */
/* epilogue end (size=0) */
/* function serv4 size 23 (22) */
	.size	serv4, .-serv4
.global	serv3
	.type	serv3, @function
serv3:
/* prologue: frame size=0 */
	push r17
/* prologue end (size=1) */
	ldi r22,lo8(0)
	ldi r23,hi8(0)
	ldi r24,lo8(3)
	ldi r25,hi8(3)
	call set_servo_position
	ldi r17,lo8(0)
.L37:
	subi r17,lo8(-(1))
.L38:
	ldi r24,lo8(2)
	ldi r25,hi8(2)
	call delay_ms
	mov r22,r17
	clr r23
	ldi r24,lo8(3)
	ldi r25,hi8(3)
	call set_servo_position
	cpi r17,lo8(-6)
	brlo .L37
	ldi r17,lo8(0)
	rjmp .L38
/* epilogue: frame size=0 */
/* epilogue: noreturn */
/* epilogue end (size=0) */
/* function serv3 size 23 (22) */
	.size	serv3, .-serv3
.global	serv2
	.type	serv2, @function
serv2:
/* prologue: frame size=0 */
	push r17
/* prologue end (size=1) */
	ldi r22,lo8(0)
	ldi r23,hi8(0)
	ldi r24,lo8(2)
	ldi r25,hi8(2)
	call set_servo_position
	ldi r17,lo8(0)
.L44:
	subi r17,lo8(-(1))
.L45:
	ldi r24,lo8(1)
	ldi r25,hi8(1)
	call delay_ms
	mov r22,r17
	clr r23
	ldi r24,lo8(2)
	ldi r25,hi8(2)
	call set_servo_position
	cpi r17,lo8(-6)
	brlo .L44
	ldi r17,lo8(0)
	rjmp .L45
/* epilogue: frame size=0 */
/* epilogue: noreturn */
/* epilogue end (size=0) */
/* function serv2 size 23 (22) */
	.size	serv2, .-serv2
.global	serv
	.type	serv, @function
serv:
/* prologue: frame size=0 */
	push r17
/* prologue end (size=1) */
	lds r24,current_pid
	clr r25
	sbrc r24,7
	com r25
	ldi r22,lo8(0)
	ldi r23,hi8(0)
	adiw r24,2
	call set_servo_position
	ldi r17,lo8(0)
.L51:
	subi r17,lo8(-(1))
.L52:
	lds r24,current_pid
	clr r25
	sbrc r24,7
	com r25
	adiw r24,2
	call delay_ms
	mov r22,r17
	clr r23
	lds r24,current_pid
	clr r25
	sbrc r24,7
	com r25
	adiw r24,2
	call set_servo_position
	cpi r17,lo8(-6)
	brlo .L51
	ldi r17,lo8(0)
	rjmp .L52
/* epilogue: frame size=0 */
/* epilogue: noreturn */
/* epilogue end (size=0) */
/* function serv size 35 (34) */
	.size	serv, .-serv
	.data
.LC0:
	.string	"Waiting"
	.text
.global	main
	.type	main, @function
main:
/* prologue: frame size=0 */
	push r16
	push r17
/* prologue end (size=2) */
	call initialize
	call servo_init
	call compass_init
	ldi r22,lo8(120)
	ldi r23,hi8(120)
	ldi r24,lo8(0)
	ldi r25,hi8(0)
	call set_servo_position
	ldi r22,lo8(120)
	ldi r23,hi8(120)
	ldi r24,lo8(1)
	ldi r25,hi8(1)
	call set_servo_position
	ldi r22,lo8(120)
	ldi r23,hi8(120)
	ldi r24,lo8(2)
	ldi r25,hi8(2)
	call set_servo_position
	ldi r22,lo8(120)
	ldi r23,hi8(120)
	ldi r24,lo8(3)
	ldi r25,hi8(3)
	call set_servo_position
	ldi r22,lo8(120)
	ldi r23,hi8(120)
	ldi r24,lo8(4)
	ldi r25,hi8(4)
	call set_servo_position
	ldi r22,lo8(120)
	ldi r23,hi8(120)
	ldi r24,lo8(5)
	ldi r25,hi8(5)
	call set_servo_position
	rjmp .L58
.L59:
	call knob
	mov r16,r24
	clr r17
	movw r22,r16
	ldi r24,lo8(0)
	ldi r25,hi8(0)
	call set_servo_position
	call clear_screen
	ldi r24,lo8(.LC0)
	ldi r25,hi8(.LC0)
	call print_string
	call next_line
	movw r24,r16
	call print_int
	ldi r24,lo8(40)
	ldi r25,hi8(40)
	call delay_ms
.L58:
	call get_sw1
	or r24,r25
	breq .L59
	call system_init
	ldi r24,lo8(gs(serv))
	ldi r25,hi8(gs(serv))
	call system
	ldi r24,lo8(gs(serv))
	ldi r25,hi8(gs(serv))
	call system
	ldi r24,lo8(gs(serv))
	ldi r25,hi8(gs(serv))
	call system
	call serv
.L61:
	rjmp .L61
/* epilogue: frame size=0 */
/* epilogue: noreturn */
/* epilogue end (size=0) */
/* function main size 90 (88) */
	.size	main, .-main
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
	brlo .L66
	movw r24,r28
	rjmp .L68
.L66:
	cpi r24,8
	cpc r25,__zero_reg__
	brlo .L68
	sbiw r28,51
	brlo .L68
	ldi r24,lo8(0)
	ldi r25,hi8(0)
.L68:
/* epilogue: frame size=0 */
	pop r29
	pop r28
	pop r17
	ret
/* epilogue end (size=4) */
/* function distance size 28 (21) */
	.size	distance, .-distance
/* File "slash.c": code  334 = 0x014e ( 305), prologues  16, epilogues  13 */
