;Operating system for ATMega32 on Polybot board
;compile with avr-gcc for ATmega32 @ 16Mhz

;SCK:  PB7  , pin 3
;MIso: PB6  , pin 2
;MOSI: PB5  , pin 1
;EN:   PB4  , pin 4

.text

.global system
.global system_init
.global yeild

;register usage:
; saved: r2-r17, r28-r29
; local: r18-r27, r30-r31
; function parameters: r25-r8, left-to-right.
;  example foo( (u16) 1025, (u08) 64); r25=2, r24=1, r23=0(empty), r22=64
; function return: 8-bit in r24, 16-bit in r25:r24, 32-bit in r25:r24:r23:r22
; X = r27:r26
; Y = r29:r28
; Z = r31:r30

;assumptions about the code is being run:
; a call stack shouldn't be more than 4 functions deep.
;  this means no recursion!
; a function should not need parameters on the stack (more than 18 bytes)
; a function should not need to use the stack to return (more than 8 bytes)
; largest observed frame size for current code is 23 bytes
;  most functions have a frame size of 0 bytes
;  biggest function might need 32 bytes total (frame and return address)
;  this means a program should only need 4*32=128 bytes of stack space!
;  perhaps allocate a little less, say 64 bytes
;   this affords a depth of about 30 calls

;per-process data structure
; store registers: 32 bytes
; store PC: 2 bytes
; store stack pointer: 2 bytes
; store SREG: 1 byte
;  run frequency: 1 byte (every N cycles, 0 for idle)
;  last run: 1 byte (N cycles ago)
;  priority: 1 byte (lower is better)
; some info about when to run again
;  function pointer?
;  priority?
; optional: PID, 1 byte
;  TOTAL: 40 bytes

#define P_SZ 40
#define STACK_SZ 96

;total space allocated per-process: 98 bytes
; not bad!

;timer usage
; use one timer for preemption, another for PWM
; using timer 0 for preemption
; letting polybot code use timer1 for PWM (servos and motors)

;PWM (integrated into OS)
; two modes: 
;  high frequency (for motors)
;   setting is %duty cycle
;  50Hz (for servos)
;   setting is servo position (1-2ms on, 19-18ms off)
; both can output to register chips on polybot board
;  perhaps specify output in terms of polybot board outputs?
;  this starts to integrate drivers into the OS, not sure how I want to do this
; looks like I need the 16-bit timer for servos, if I want 8bits of resolution
;   and I want the programmig to be relatively simple
;LOOKS LIKE THE POLYBOT IMPLEMENTATION IS VERY EFFICIENT, STICKING WITH IT

;Drivers
; should deal with input and output peripheral control
; interrupt routines should be as short as possible
;  make setup routines longer instead, if possible
; most drivers probably ought to be written in assembly

;CODE STARTS HERE

;process preemption timer interrupt (TIMER0 OVF)
.global __vector_11
.global yeild
__vector_11: 
   push r31
   push r30
   push r29
   push r28
   ; grab SREG before we change it
   in r28, 0x3f ; SREG

   ldi r31, hi8(process_table+38)
   ldi r30, lo8(process_table+38)

   ld r29, Z
   inc r29
   st Z, r29

   adiw r30, P_SZ
   ld r29, Z
   inc r29
   st Z, r29

   adiw r30, P_SZ
   ld r29, Z
   inc r29
   st Z, r29

   adiw r30, P_SZ
   ld r29, Z
   inc r29
   st Z, r29

   ; restore sreg
   out 0x3f, r28
   pop r28
   pop r29
   pop r30
   pop r31

yeild:
   cli  ;disable interrupts
;   sei  ; enable interrupts; we can afford to be interrupted here
   push r29
   push r30
   push r31
   push r0
   push r1
   ; grab SREG before we change it
   in r29, 0x3f ; SREG
   lds r31, current_pid
;   ldi r30, 37 ; size of process info structure
   ldi r30, P_SZ ; size of process info structure
   mul r31, r30
   ldi r30, lo8(process_table)
   ldi r31, hi8(process_table)
   add r30, r0
   adc r31, r1 ; index into process table now in Z
   pop r1
   pop r0
   st Z+, r0
   st Z+, r1
   st Z+, r2
   st Z+, r3
   st Z+, r4
   st Z+, r5
   st Z+, r6
   st Z+, r7
   st Z+, r8
   st Z+, r9
   st Z+, r10
   st Z+, r11
   st Z+, r12
   st Z+, r13
   st Z+, r14
   st Z+, r15
   st Z+, r16
   st Z+, r17
   st Z+, r18
   st Z+, r19
   st Z+, r20
   st Z+, r21
   st Z+, r22
   st Z+, r23
   st Z+, r24
   st Z+, r25
   st Z+, r26
   st Z+, r27
   st Z+, r28
   pop r2 ; r31
   pop r1 ; r30
   pop r0 ; r29
   st Z+, r0
   st Z+, r1
   st Z+, r2
   ; whew, that's all the registers, written to SRAM
   ; now write SREG to SRAM
   st Z+, r29
   ; now, write return address to SRAM
   pop r0
   pop r1
   st Z+, r0
   st Z+, r1
   ; now, write stack pointer to SRAM
   in r0, 0x3d ; SPL
   in r1, 0x3e ; SPH
   st Z+, r0
   st Z+, r1
   ; wheh, that's everything! ( I think :)

   ; SCHEDULER
   ; old round-robin scheduler
;   lds r30, current_pid
;   lds r31, num_pids
;   inc r30
;   cp r30, r31
;   brlt L2 ; test if next pid is less than num_pids
;   clr r30 ; 65 instructions up to here
L2:
   ; new, priority scheduler
;   next = 0;
;   priority = 255;
;   for( i=0; i<num_pids; i++ ) {
;      if( l[i] >= s[i] )
;         if( p[i] < priority ) {
;            priority = p[i];
;            next = i;
;         }
;   }
;   l[next] = 0;
;  
   lds r31, num_pids
   ldi r30, P_SZ

   ; load address of process_table into Y
   ldi r29, hi8(process_table)
   ldi r28, lo8(process_table)

   ser r18   ; priority
   clr r17   ; next
L3:
   mov r27, r31
   dec r27
   ; load s[i]
   mul r30, r27 ; reslult into r1:r0
   add r0, r28
   adc r1, r29
   mov r26, r0
   mov r27, r1
   ; X now has process base
   adiw r26, 37 ; skip past process info
   ld r23, X+ ; schedule
   ld r24, X+ ; last run
   ld r25, X+ ; priority

   cp r24, r23 ; do r24 - r23, set SREG
   brlo L4 ; r24 < r23
   cp r25, r18 ; do r25 - r18
   brsh L4 ; r25 >= r18
   
   ; actually do stuff here!
   mov r18, r25
   mov r17, r31
   dec r17


L4:
   dec r31
   brne L3 ; loop if r31 != 0

   ; next pid is r17
   mul r17, r30
   add r0, r28
   adc r1, r29
   mov r31, r1
   mov r30, r0
   adiw r30, 38 ; offset for last run
   clr r0
   st Z, r0 ; store 0 at last run-time

   mov r30, r17
   ; r30 is now next PID to run
   ; END OF SCHEDULER

   sts current_pid, r30 ; save to SRAM
   ldi r31, P_SZ
   mul r30, r31
   ldi r30, lo8(process_table)
   ldi r31, hi8(process_table)
   add r30, r0
   adc r31, r1 ; Z now has address of next process to run

   ; load process (registers and return adress)
   ld r0, Z+
   ld r1, Z+
   ld r2, Z+
   ld r3, Z+
   ld r4, Z+
   ld r5, Z+
   ld r6, Z+
   ld r7, Z+
   ld r8, Z+
   ld r9, Z+
   ld r10, Z+
   ld r11, Z+
   ld r12, Z+
   ld r13, Z+
   ld r14, Z+
   ld r15, Z+
   ld r16, Z+
   ld r17, Z+
   ld r18, Z+
   ld r19, Z+
   ld r20, Z+
   ld r21, Z+
   ld r22, Z+
   ld r23, Z+
   ld r24, Z+
   ld r25, Z+
   ld r26, Z+
   ld r27, Z+
   ; that covers the first 28 registers
   ; this is where it gets tricky

   cli ; disable interrupts before writing stack pointer
   adiw r30, 7 ; skip past r28-r31, SREG, return address
   ld r28, Z+  ; SPL from SRAM
   ld r29, Z+  ; SPH from SRAM
   out 0x3d, r28 ; SPL
   out 0x3e, r29 ; SPH
;   sei ; enable interrupts now that we're done writing the stack pointer

   sbiw r30, 4 ; skip back to return address
   ; put return address back on stack
   ; store was: pop r0, pop r1, st r0, st r1
   ld r28, Z+ ; high byte
   ld r29, Z+ ; low byte
   push r29   ; push low byte first
   push r28   ; push high byte second
   ; restore SREG and put r31 and r30 on stack
   sbiw r30, 2 ; skip back to return address
   ld r28, -Z ; pre-decrement and load SREG
   out 0x3f, r28 ; set SREG
   ld r28, -Z ; pre-decrement and load r31
   ld r29, -Z ; pre-decrement and load r30
   push r28   ; put r31 on stack
   push r29   ; put r30 on stack
   ; restore r29 and r28
   ld r29, -Z ; pre-decrement and load r29
   ld r28, -Z ; pre-decrement and load r28
   ; reset timer (OS time shouldn't counat against run time too much)
   ; TODO set TCNT0 to 0 here

   ; pop r30 and r31
   pop r30
   pop r31
   reti ; return and enable interrupts
   ; measured run-time of about 12uS; overhead of about 1.2% cpu-time

.global system_init
system_init:
   ; for now, I think I only need to initialize the globals, and set up timer
   clr r30
   sts current_pid, r30
   ldi r30, 1
   sts num_pids, r30
   ; timing done by overflow timer of timer0
   ; to enable:
   ;   set TOIE0 (bit 0) in TIMSK register
   ;   clear OCIE0 (bit 1) in TIMSK register
   ;   set TCNT0 register to 0 (reset counter)
   ;   set prescaler to /1024 (set TCCR0 bits 2-0 to 101)
   ;   disable silly output modes (set TCCR0 bits 5-4 to 00)
   ;   select normal timer mode (set TCCR0 bits 6,3 to 00)
   ;   disable force-output-compare (set TCCR0 bit 7 to 0)
   ;  summary: set TCCR0 to 00000101b
   ;
   ;  1024 * 256 = 262144 divisor
   ;  processor clock: 16MHz
   ; Final timer frequency: 61.035 Hz
   ; target frequency: 1000Hz (1mS)
   ;  need divisor: 16000
   ;  available prescalers: 1, 8, 64, 256, 1024
   ;  scale by: 256 * 64 ( prescaler 011 )
   ; Final timer frequency of 976 Hz
   ;   1.024mS per interrupt
   ;    overhead of ~128 instructions per interrupt
   ;     0.8% overhead; not bad!
   ;     at least 1.6% if have a yeild call mid-quanta
   ;   could be perfect if we interrupt at 250 instead of 256
   ;    might want to cut this to 125 (2000Hz) for better timing control
   ;  summary: set TCCR0 to 00000011b
   cli ; disable interrupts for a little bit
   clr r30
   ori r30, 0b00000011
   out 0x33, r30 ; TCCR0
   in r30, 0x39 ; TIMSK
   ori r30, 0b00000001  ; set bit 0
   andi r30, 0b11111101 ; clear bit 1
   out 0x39, r30 ; TIMSK
   sei ; don't forget to enable interrupts!
   ret

.global system ; u08 system( void (*task)(void), u08 sched, u08 pri );
; take a function pointer and run it as a new task, assuming there is a free
;  spot in the pid table
; if it returns, it should jump to a cleanup function
; it should start with an empty set of registers
; CHECKING: check if max number of rocesses has been reached, but not for 
;  stack-related problems
system:
   mov r30, r24 ; low byte of function pointer
   mov r31, r25 ; high byte of function pointer

   ; sched in r22
   ; pri in r20

   ; function pointer now in Z (I think)
   ; DEBUG
   ;icall
   ; END DEBUG

   ; r24: return value
   ldi r24, 1 ; set error value (makes ruturning easy)
   ; SUMMARY:
   ; we need to zero the register entries in the process table, set the 
   ; stack pointer, set the SREG, and set the return address
   ; we also need to increment the number of running processes
   ; then we can call yeild, and let the task switcher take over

   lds r27, num_pids
   cpi r27, 4      ; check that we're not running too many processes
   brge system_end ; return with error if we are running too many

   ldi r26, P_SZ
   mul r26, r27
   ldi r26, lo8(process_table)
   ldi r27, hi8(process_table)
   add r26, r0
   adc r27, r1 ; now address into process_table is in X
   clr r1 ; reset gcc's zero register
   ldi r25, 32 ; use r25 for counting
   ; clear register space
L1:
   st X+, r1
   dec r25
   brne L1
   ; set SREG
   ldi r25, 0b10000000 ; only I (interrupts) enabled
   st X+, r25
   ; set return address
   ; apparently, return address is push low-byte first onto the stack
   ; from task switch routine:
   ;; now, write return address to SRAM
   ;pop r0  this must be the high byte
   ;pop r1  and this must be the low byte
   ;st Z+, r0  high byte
   ;st Z+, r1  low byte
   ;
   ; this means the program structure stores high-byte first
   ; since ret and reti do (PC <- stack), no offset should be needed
   st X+, r31 ; high byte of function pointer first
   st X+, r30 ; low byte of function pointer second
   ; now for stack pointer nonsense (using Z to write to new stack)
   lds r25, num_pids
   ; multiply by STACK_SZ (2^6)
   ldi r24, STACK_SZ
   mul r24, r25 ; stack pointer offset in r1:r0
   ldi r30, 0x5f ; higest ram address (low byte)
   ldi r31, 0x08 ; highet ram address (high byte)
   sub r30, r0 ; compute low byte of new stack pointer
   sbc r31, r1 ; compute high byte of new stack pointer
   clr r1
   clr r0
   ldi r24, lo8(system_loop)
   st -Z, r24
   ldi r24, hi8(system_loop)
   st -Z, r24
   ; new stack is ready! add to program table entry
   st X+, r30 ; low-byte first!
   st X+, r31 ; high byte second
   ; I realize that this makes no sense. at this point, I don't care, as long
   ; as I can keep them straight
   st X+, r22 ; schedule
   st X+, r0  ; last run (0)
   st X+, r20 ; priority

   ; increment number of running processes (if we get an interrupt here, we're
   ;  ok!)
   inc r25
   sts num_pids, r25

   ;looks like we are ready to start our new process!
   rcall yeild

   clr r24
system_end:
   clr r1 ; a litle cleanup
   ret

; void schedule(unsigned char sched);
.global schedule
schedule:
   lds r31, current_pid
   ldi r30, P_SZ
   mul r30, r31
   ldi r30, lo8(process_table)
   ldi r31, hi8(process_table)
   add r30, r0
   adc r31, r1
   adiw r30, 37 ; offset to schedule
   st Z, r24 ; parameter in r24
   ret

; void priority(unsigned char pri)
.global priority
priority:
   lds r31, current_pid
   ldi r30, P_SZ
   mul r30, r31
   ldi r30, lo8(process_table)
   ldi r31, hi8(process_table)
   add r30, r0
   adc r31, r1
   adiw r30, 39 ; offset to schedule
   st Z, r24
   ret

; placeholder for system cleanup routine
system_loop:
   rcall yeild
   rjmp system_loop

   .section .bss
; global OS variables
.global process_table
   .type process_table, @object
;   .size process_table, 148 ; space for 4 processes @P_SZ bytes each
   .size process_table, P_SZ*4 ; space for 4 processes @P_SZ bytes each
process_table:
;   .skip 148,0 ; layout: r0-r31, SREG, RET, SP
   .skip P_SZ*4,0 ; layout: r0-r31, SREG, RET, SP
.global current_pid
   .type current_pid, @object
   .size current_pid, 1
current_pid:
   .skip 1,0
.global num_pids
   .type num_pids, @object
   .size num_pids, 1
num_pids:
   .skip 1,0
