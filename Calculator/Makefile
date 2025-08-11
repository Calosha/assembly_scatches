CC = ca65
LD = ld65

calc.bin: calc.o
	$(LD) -C simple.cfg -o $@ $<

calc.o: calc.s
	$(CC) -o $@ $<

clean:
	rm -f *.o *.bin

.PHONY: clean
