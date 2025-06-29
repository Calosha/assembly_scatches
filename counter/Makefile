CC = ca65
LD = ld65

counter.bin: counter.o
	$(LD) -C simple.cfg -o $@ $<

counter.o: counter.s
	$(CC) -o $@ $<

clean:
	rm -f *.o *.bin

.PHONY: clean
