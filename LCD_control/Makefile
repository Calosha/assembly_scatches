CC = ca65
LD = ld65

show_a.bin: show_a.o
	$(LD) -C simple.cfg -o $@ $<

show_a.o: show_a.s
	$(CC) -o $@ $<

clean:
	rm -f *.o *.bin

.PHONY: clean
