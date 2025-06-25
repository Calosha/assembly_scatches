#ifndef CONFIG_H
#define CONFIG_H

// Pin definitions for the shift register
#define SHIFT_LATCH_PIN 10
#define SHIFT_DATA_PIN  11
#define SHIFT_CLOCK_PIN 13

// Pin definitions for AT28C256 EEPROM
// Control
#define ROM_CE 14 // Chip Enable 
#define ROM_OE 15 // Output Enable
#define ROM_WE 16 // Write Enable

// Data
const int ROM_DATA_PINS[8] = {2,3,4,5,6,7,8,9};

#endif // CONFIG_H
// TODO: Pick either const or preprocessor. Or maybe both are fine?