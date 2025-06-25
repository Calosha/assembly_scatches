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
    // Reset vectors
  programmer.writeByte(0x7FFC, 0x00);  // Low byte
  delay(15);
  programmer.writeByte(0x7FFD, 0x80);  // High byte → points to $8000(cpu)$0000(rom)
  delay(15);
  
  
  Serial.println("Simple test: Just NOPs and JMP and LDA 01010 and STA in ROM range");
  Serial.println("A15 should stay HIGH (all activity in ROM)");
  Serial.println("RWB should go low for STA instruction");
}