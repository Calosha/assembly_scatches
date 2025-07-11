CC = ca65
LD = ld65

dspl_dvr.bin: dspl_dvr.o
	$(LD) -C simple.cfg -o $@ $<

dspl_dvr.o: dspl_dvr.s
	$(CC) -o $@ $<

clean:
	rm -f *.o *.bin

.PHONY: clean
