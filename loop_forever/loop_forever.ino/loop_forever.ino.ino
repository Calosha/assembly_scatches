// TODO: write protection to make sure that our programmer is writeEnabled when using write operation
// TODO: play with binary operations and uint8 to see hex, mask, & , >> stuff
#include <Arduino.h>
#include "EEPROMProgrammer.h"

EEPROMProgrammer programmer;

void setup() {
  // Start serial monitor on port 9600
  Serial.begin(9600);
  // Setup shift registers
  programmer.begin();
  //programSimpleTest();  // Added semicolon
  //setResetVector();
  // programSimpleTestOneWrite();
  programBinaryCounter();
  verifyROM();          // Added semicolon
}

void programSimpleTest() { // validated and working
  Serial.println("Programming simple test ROM...");
  
  // Even simpler: Just infinite loop with NOP instructions
  programmer.writeByte(0x0000, 0x18); // Clear carry flag
  delay(15);
  programmer.writeByte(0x0001, 0xFB); // Exchange carry with emulation
  // programmer.writeByte(0x0001, 0xEA); // NOP
  delay(15);
  programmer.writeByte(0x0002, 0xEA); // NOP
  delay(15);
  programmer.writeByte(0x0003, 0xEA); // NOP
  delay(15);
  programmer.writeByte(0x0004, 0xEA); // NOP
  delay(15);
  programmer.writeByte(0x0005, 0xEA); // NOP
  delay(15);
  programmer.writeByte(0x0006, 0x4C); // JMP
  delay(15);
  programmer.writeByte(0x0007, 0x00); // Low byte
  delay(15);
  programmer.writeByte(0x0008, 0x80); // High byte jump back to 8000 or rom 0000
  delay(15);
  
  // Reset vectors (same as above)
  programmer.writeByte(0x7FFC, 0x00);  // Low byte
  delay(15);
  programmer.writeByte(0x7FFD, 0x80);  // High byte → points to $E000
  delay(15);
  
  Serial.println("Simple test: Just NOPs and JMP in ROM range");
  Serial.println("A15 should stay HIGH (all activity in ROM)");
  Serial.println("A0-A2 should show address activity");
}

void programSimpleTestOneWrite() { // validated and working
  Serial.println("Programming simple test ROM...");
  
  // Even simpler: Just infinite loop with NOP instructions
  // programmer.writeByte(0x0000, 0x18); // Clear carry flag
  programmer.writeByte(0x0000, 0xEA); // NOP
  delay(15);
  // programmer.writeByte(0x0001, 0xFB); // Exchange carry with emulation
  programmer.writeByte(0x0001, 0xEA); // NOP
  delay(15);
  programmer.writeByte(0x0002, 0xEA); // NOP
  delay(15);
  programmer.writeByte(0x0003, 0xA9); // LDA immediate (8-bit)
  delay(15);
  programmer.writeByte(0x0004, 0xAA); // Load value 0xAA (10101010)
  delay(15);
  programmer.writeByte(0x0005, 0x8D); // STA absolute (3 bytes total)
  delay(15);
  programmer.writeByte(0x0006, 0x00); // low byte for STA $9000
  delay(15);
  programmer.writeByte(0x0007, 0x90); // high byte for STA $9000
  delay(15);
  programmer.writeByte(0x0008, 0x4C); // JMP
  delay(15);
  programmer.writeByte(0x0009, 0x00); // Low byte
  delay(15);
  programmer.writeByte(0x000A, 0x80); // High byte jump back to 8000 or rom 0000
  delay(15);
  
  
  Serial.println("Simple test: Just NOPs and JMP and LDA 01010 and STA in ROM range");
  Serial.println("A15 should stay HIGH (all activity in ROM)");
  Serial.println("RWB should go low for STA instruction");
}

void programBinaryCounter() {
  Serial.println("Programming 8-bit binary counter...");
  
  // LDA #$00 - Load accumulator with 0
  programmer.writeByte(0x0000, 0xA9); // LDA immediate
  delay(15);
  programmer.writeByte(0x0001, 0x00); // Load value 0x00
  delay(15);
  
  // loop: INC A - Increment accumulator  
  programmer.writeByte(0x0002, 0x1A); // INC A
  delay(15);
  
  // STA $9000 - Store to LEDs
  programmer.writeByte(0x0003, 0x8D); // STA absolute
  delay(15);
  programmer.writeByte(0x0004, 0x00); // Low byte of $9000
  delay(15);
  programmer.writeByte(0x0005, 0x90); // High byte of $9000
  delay(15);
  
  // LDX #$FF - Load X with 255 for outer delay
  programmer.writeByte(0x0006, 0xA2); // LDX immediate
  delay(15);
  programmer.writeByte(0x0007, 0xFF); // Load value 0xFF
  delay(15);
  
  // outer_delay: LDY #$FF - Load Y with 255 for inner delay
  programmer.writeByte(0x0008, 0xA0); // LDY immediate
  delay(15);
  programmer.writeByte(0x0009, 0xFF); // Load value 0xFF
  delay(15);
  
  // inner_delay: DEY - Decrement Y
  programmer.writeByte(0x000A, 0x88); // DEY
  delay(15);
  
  // BNE inner_delay - Branch back to 0x000A
  programmer.writeByte(0x000B, 0xD0); // BNE relative
  delay(15);
  programmer.writeByte(0x000C, 0xFD); // Offset -3 (0x000A - 0x000D = -3)
  delay(15);
  
  // DEX - Decrement X
  programmer.writeByte(0x000D, 0xCA); // DEX
  delay(15);
  
  // BNE outer_delay - Branch back to 0x0008
  programmer.writeByte(0x000E, 0xD0); // BNE relative
  delay(15);
  programmer.writeByte(0x000F, 0xF8); // Offset -8 (0x0008 - 0x0010 = -8)
  delay(15);
  
  // JMP loop - Jump back to 0x0002
  programmer.writeByte(0x0010, 0x4C); // JMP absolute
  delay(15);
  programmer.writeByte(0x0011, 0x02); // Low byte of $0002
  delay(15);
  programmer.writeByte(0x0012, 0x00); // High byte of $0002
  delay(15);
  
  
  Serial.println("Binary counter programmed!");
  Serial.println("Should count 0-255 in binary on LEDs with ~177ms delay");
  Serial.println("Counter will wrap around from 255 back to 0");
}

void setResetVector(){
    // Reset vectors (same as above)
  programmer.writeByte(0x7FFC, 0x00);  // Low byte
  delay(15);
  programmer.writeByte(0x7FFD, 0xC0);  // High byte → points to $E000
  delay(15);
}

// Verification function to read back and confirm programming
void verifyROM() {
  Serial.println("Verifying ROM contents...");
  
  Serial.println("Program area:");
  for(int i = 0; i < 19; i++) {
    Serial.print("Address ");
    Serial.print(i, HEX);
    Serial.print(": ");
    Serial.println(programmer.readByte(i), HEX);
  }
  
  Serial.println("Reset vectors:");
  Serial.print("Address 7FFC: ");
  Serial.println(programmer.readByte(0x7FFC), HEX);
  Serial.print("Address 7FFD: ");
  Serial.println(programmer.readByte(0x7FFD), HEX);
  Serial.print("Address C000: ");
  Serial.println(programmer.readByte(0xC000), HEX);
  Serial.print("Address 4000: ");
  Serial.println(programmer.readByte(0x4000), HEX);
  Serial.print("Address 4001: ");
  Serial.println(programmer.readByte(0x4001), HEX);
  Serial.print("Address 4002: ");
  Serial.println(programmer.readByte(0x4002), HEX);
  Serial.print("Address 7FFF: ");
  Serial.println(programmer.readByte(0x7FFF), HEX);
}

void loop() {
  while(1); // Infinite loop - do nothing
}