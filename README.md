# Collection of asm scatches for 65816 CPU

## Counter
Test program to count from 0 to 255 and display the result on the screen.


## Compilation
```
ca65 -o counter.o counter.s
ld65 -C simple.cfg -o counter.bin counter.o
```
