	.file	"slash.c"
__SREG__ = 0x3f
__SP_H__ = 0x3e
__SP_L__ = 0x3d
__CCP__  = 0x34
__tmp_reg__ = 0
__zero_reg__ = 1
	.text
.global	wheelmon
	.type	wheelmon, @function
wheelmon:
/* prologue: function */
/* frame size = 0 */
.L2:
	call yeild
	rjmp .L2
	.size	wheelmon, .-wheelmon
.global	battery_thread
	.type	battery_thread, @function
battery_thread:
/* prologue: function */
/* frame size = 0 */
.L5:
	ldi r24,lo8(0)
	ldi r25,hi8(0)
	call analog
	sts battery,r24
	call yeild
	rjmp .L5
	.size	battery_thread, .-battery_thread
.global	IR
	.type	IR, @function
IR:
	push r11
	push r12
	push r13
	push r14
	push r15
	push r16
	push r17
/* prologue: function */
/* frame size = 0 */
	mov r11,r24
	ldi r25,lo8(0)
	call analog
	movw r14,r24
	ldi r24,lo8(1)
	ldi r25,hi8(1)
	call delay_ms
	mov r24,r11
	ldi r25,lo8(0)
	call analog
	movw r16,r24
	ldi r24,lo8(1)
	ldi r25,hi8(1)
	call delay_ms
	mov r24,r11
	ldi r25,lo8(0)
	call analog
	movw r12,r24
	ldi r24,lo8(1)
	ldi r25,hi8(1)
	call delay_ms
	mov r24,r11
	ldi r25,lo8(0)
	call analog
	add r16,r14
	adc r17,r15
	add r16,r12
	adc r17,r13
	add r16,r24
	adc r17,r25
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
	movw r24,r22
	subi r24,lo8(-(-5))
/* epilogue start */
	pop r17
	pop r16
	pop r15
	pop r14
	pop r13
	pop r12
	pop r11
	ret
	.size	IR, .-IR
	.data
.LC0:
	.string	" "
	.text
.global	thread0
	.type	thread0, @function
thread0:
	push r16
	push r17
/* prologue: function */
/* frame size = 0 */
.L15:
	call rx_byte
	tst r24
	brne .L15
	call rx_byte
	mov r17,r24
	call rx_byte
	mov r16,r24
	mov r22,r17
	cpi r17,lo8(31)
	brlo .L11
	ldi r22,lo8(30)
.L11:
	subi r22,lo8(-(120))
	ldi r24,lo8(0)
	ldi r25,hi8(0)
	ldi r23,lo8(0)
	call set_servo_position
	mov r22,r16
	subi r22,lo8(-(120))
	ldi r24,lo8(1)
	ldi r25,hi8(1)
	ldi r23,lo8(0)
	call set_servo_position
	call led_on
	call clear_screen
	ldi r24,lo8(0)
	ldi r25,hi8(0)
	call print_int
	ldi r24,lo8(.LC0)
	ldi r25,hi8(.LC0)
	call print_string
	mov r24,r17
	ldi r25,lo8(0)
	call print_int
	ldi r24,lo8(.LC0)
	ldi r25,hi8(.LC0)
	call print_string
	mov r24,r16
	clr r25
	sbrc r24,7
	com r25
	call print_int
	call led_off
	rjmp .L15
	.size	thread0, .-thread0
	.data
.LC1:
	.string	"Waiting "
.LC2:
	.string	" +"
.LC3:
	.string	" -"
.LC4:
	.string	"Waiting data"
	.text
.global	main
	.type	main, @function
main:
	push r17
/* prologue: function */
/* frame size = 0 */
	sts (lspeed)+1,__zero_reg__
	sts lspeed,__zero_reg__
	sts (rspeed)+1,__zero_reg__
	sts rspeed,__zero_reg__
	call initialize
	call servo_init
	call compass_init
	call serial_init
	ldi r24,lo8(0)
	call schedule
	ldi r24,lo8(-1)
	call priority
	call system_init
	ldi r24,lo8(gs(wheelmon))
	ldi r25,hi8(gs(wheelmon))
	ldi r22,lo8(1)
	ldi r20,lo8(0)
	call system
	ldi r24,lo8(0)
	ldi r25,hi8(0)
	ldi r22,lo8(120)
	ldi r23,hi8(120)
	call set_servo_position
	ldi r24,lo8(1)
	ldi r25,hi8(1)
	ldi r22,lo8(120)
	ldi r23,hi8(120)
	call set_servo_position
	rjmp .L23
.L20:
	call knob
	mov r17,r24
	ldi r24,lo8(0)
	ldi r25,hi8(0)
	mov r22,r17
	ldi r23,lo8(0)
	call set_servo_position
	call clear_screen
	ldi r24,lo8(.LC1)
	ldi r25,hi8(.LC1)
	call print_string
	lds r24,lspeed
	lds r25,(lspeed)+1
	call print_int
	ldi r24,lo8(.LC0)
	ldi r25,hi8(.LC0)
	call print_string
	lds r24,rspeed
	lds r25,(rspeed)+1
	call print_int
	call next_line
	mov r24,r17
	ldi r25,lo8(0)
	call print_int
	call get_sw1
	or r24,r25
	breq .L18
	ldi r24,lo8(.LC2)
	ldi r25,hi8(.LC2)
	rjmp .L22
.L18:
	ldi r24,lo8(.LC3)
	ldi r25,hi8(.LC3)
.L22:
	call print_string
.L23:
	ldi r24,lo8(40)
	ldi r25,hi8(40)
	call delay_ms
	call get_sw1
	or r24,r25
	breq .L20
	call clear_screen
	ldi r24,lo8(.LC4)
	ldi r25,hi8(.LC4)
	call print_string
	call thread0
/* epilogue start */
	pop r17
	ret
	.size	main, .-main
	.comm battery,1,1
	.comm lspeed,2,1
	.comm rspeed,2,1
.global __do_copy_data
.global __do_clear_bss
