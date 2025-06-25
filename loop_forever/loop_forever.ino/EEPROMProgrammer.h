#ifndef EEPROMPROGRAMMER_H
#define EEPROMPROGRAMMER_H

#include <Arduino.h>

class EEPROMProgrammer {
  private:
    const int DATA_PINS[8] = {2, 3, 4, 5, 6, 7, 8, 9};
    const int SHIFT_DATA = 11;
    const int SHIFT_CLK = 13;
    const int SHIFT_LATCH = 10;
    const int CE_PIN = A0;
    const int OE_PIN = A1;
    const int WE_PIN = A2;

    void setDataPinsMode(uint8_t mode);
    void shiftOut(uint16_t address);
    void writeEnable();
    void readEnable();
    void setAddress(uint16_t address);

  public:
    EEPROMProgrammer();
    void begin();
    void writeByte(uint16_t address, uint8_t data);
    uint8_t readByte(uint16_t address);
    void verifyByte(uint16_t address, uint8_t expected);
};

#endif // EEPROMPROGRAMMER_H