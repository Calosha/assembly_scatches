    LDA #$00
loop:
    INC A
    STA $9000

    LDX #$FF
    
outer_delay:
    LDY #$FF
inner_delay:
    DEY
    BNE inner_delay
    DEX
    BNE outer_delay
    JMP loop
