# enter the name of your program here
TRG = slash
ASM = compass.s system.S

# enter the COM port of your USB downloader here
PORT = com3

# the folder that contains the PolyBot Library
LIB = polybot_library

# these are PolyBot Library source files that your program needs
SRC = $(LIB)/delays.c $(LIB)/adc.c $(LIB)/lcd.c $(LIB)/utility.c \
		$(LIB)/servo.c serial.c

# this runs the program target below
all: download

# this target only compiles the program into .elf and .hex files
program:
	avr-gcc -mmcu=atmega32 -Os -mcall-prologues -o $(TRG).elf $(TRG).c $(ASM) $(SRC) -lm
#	avr-gcc -save-temps -mmcu=atmega32 -Os -mcall-prologues -o $(TRG).elf $(TRG).c $(ASM) $(SRC) -lm
	avr-objcopy -O ihex $(TRG).elf $(TRG).hex
	avr-size $(TRG).elf

# this target compiles the program AND downloads it to the PolyBot Board
download: program

#Linux command
#	avrdude -pm32 -P/dev/ttyUSB0 -cbutterfly -b57600 -u -U flash:w:$(TRG).hex
	avrdude -pm32 -P/dev/tty.usbserial-A30008vu -cbutterfly -b57600 -u -U flash:w:$(TRG).hex

#Windows command
#	avrdude -pm32 -P$(PORT) -cbutterfly -b57600 -u -U flash:w:$(TRG).hex

clean:
	rm $(TRG).elf
	rm $(TRG).hex
