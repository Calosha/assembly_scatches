.setcpu "65816"
.segment "CODE"
    LDA #$00 ; Init counter
loop:
    INC A ; +1
    STA $9000 ; Write accumulator to LED 373

    LDX #$FF ; Init X index
    
outer_delay:
    LDY #$FF ; Init Y index
inner_delay:
    DEY ; y--
    BNE inner_delay ; if Z flag is 0 branch to inner_delay else continue (Z flag is 1 when previous operation is 0)
    DEX ; x--
    BNE outer_delay ; if Z flag is 0 branch to outer_delay else continue
    JMP loop ; Once nested x y loop is done jump back to the begining
