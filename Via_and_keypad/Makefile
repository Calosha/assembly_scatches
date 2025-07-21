CC = ca65
LD = ld65

via_key.bin: via_key.o
	$(LD) -C simple.cfg -o $@ $<

via_key.o: via_key.s
	$(CC) -o $@ $<

clean:
	rm -f *.o *.bin

.PHONY: clean
