# Collection of asm scatches for 65816 CPU

## Counter
Test program to count from 0 to 255 and display the result on the screen.

## LCD_Display
Assembly for 1602A LCD power up and show some letters (code works without RAM)


## Compilation
```
ca65 -o counter.o counter.s
ld65 -C simple.cfg -o counter.bin counter.o
```
or
```
make
```
in the appropriate folder
