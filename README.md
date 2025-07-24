# Collection of asm scatches for 65816 CPU

## Counter
Test program to count from 0 to 255 and display the result on the screen.

## LCD_control
Assembly for 1602A LCD power up and show some letters (code works without RAM)

## Display_driver
Driver to initialize the 1602A LCD with proper timing and subroutines
(needs RAM and stack init for JSR, RTS, PHA, PHL insrunctions)

## Compilation
```
ca65 -o counter.o counter.s
ld65 -C simple.cfg -o counter.bin counter.o
```
or
```
make
```
in the appropriate folder.

## Reference to CC65 Macro Assembler
[GitDoc](https://cc65.github.io/doc/ca65.html)
