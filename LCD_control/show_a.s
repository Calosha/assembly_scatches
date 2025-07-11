.setcpu "65816"
.segment "CODE"
    ; stack init
    LDX #$FF
    TXS

    LDX #$FF ; Init X index
    
outer_delay_0:
    LDY #$FF ; Init Y index
inner_delay_0:
    DEY ; y--
    BNE inner_delay_0 ; if Z flag is 0 branch to inner_delay else continue (Z flag is 1 when previous operation is 0)
    DEX ; x--
    BNE outer_delay_0 ; if Z flag is 0 branch to outer_delay else continue

    ; First sequence 
    LDA #$30
    STA $6000
    NOP
    LDX #$FF ; Init X index

outer_delay_1:
    LDY #$FF ; Init Y index
inner_delay_1:
    DEY ; y--
    BNE inner_delay_1 ; if Z flag is 0 branch to inner_delay else continue (Z flag is 1 when previous operation is 0)
    DEX ; x--
    BNE outer_delay_1 ; if Z flag is 0 branch to outer_delay else continue

    ; Second sequence 
    LDA #$30
    STA $6000
    NOP
    LDX #$FF ; Init X index

outer_delay_2:
    LDY #$FF ; Init Y index
inner_delay_2:
    DEY ; y--
    BNE inner_delay_2 ; if Z flag is 0 branch to inner_delay else continue (Z flag is 1 when previous operation is 0)
    DEX ; x--
    BNE outer_delay_2 ; if Z flag is 0 branch to outer_delay else continue

    ; Third sequence
    LDA #$30
    STA $6000
    NOP
    LDX #$FF ; Init X index

outer_delay_3:
    LDY #$FF ; Init Y index
inner_delay_3:
    DEY ; y--
    BNE inner_delay_3 ; if Z flag is 0 branch to inner_delay else continue (Z flag is 1 when previous operation is 0)
    DEX ; x--
    BNE outer_delay_3 ; if Z flag is 0 branch to outer_delay else continue

    ; what is 38? function set 2 line 5x8 dots
    LDA #$38
    STA $6000
    NOP
    LDX #$FF ; Init X index

outer_delay_4:
    LDY #$FF ; Init Y index
inner_delay_4:
    DEY ; y--
    BNE inner_delay_4 ; if Z flag is 0 branch to inner_delay else continue (Z flag is 1 when previous operation is 0)
    DEX ; x--
    BNE outer_delay_4 ; if Z flag is 0 branch to outer_delay else continue

    ; Display off
    LDA #$08
    STA $6000
    NOP
    LDX #$FF ; Init X index

outer_delay_5:
    LDY #$FF ; Init Y index
inner_delay_5:
    DEY ; y--
    BNE inner_delay_5 ; if Z flag is 0 branch to inner_delay else continue (Z flag is 1 when previous operation is 0)
    DEX ; x--
    BNE outer_delay_5 ; if Z flag is 0 branch to outer_delay else continue

    ; Display clear
    LDA #$01
    STA $6000
    NOP
    LDX #$FF ; Init X index

outer_delay_6:
    LDY #$FF ; Init Y index
inner_delay_6:
    DEY ; y--
    BNE inner_delay_6 ; if Z flag is 0 branch to inner_delay else continue (Z flag is 1 when previous operation is 0)
    DEX ; x--
    BNE outer_delay_6 ; if Z flag is 0 branch to outer_delay else continue

    ; 
    LDA #$06
    STA $6000
    NOP
    LDX #$FF ; Init X index

outer_delay_7:
    LDY #$FF ; Init Y index
inner_delay_7:
    DEY ; y--
    BNE inner_delay_7 ; if Z flag is 0 branch to inner_delay else continue (Z flag is 1 when previous operation is 0)
    DEX ; x--
    BNE outer_delay_7 ; if Z flag is 0 branch to outer_delay else continue

    LDA #$0C
    STA $6000
    NOP
    LDX #$FF ; Init X index

outer_delay_8:
    LDY #$FF ; Init Y index
inner_delay_8:
    DEY ; y--
    BNE inner_delay_8 ; if Z flag is 0 branch to inner_delay else continue (Z flag is 1 when previous operation is 0)
    DEX ; x--
    BNE outer_delay_8 ; if Z flag is 0 branch to outer_delay else continue

    

    LDA #$43 ; C
    STA $6001
    LDX #$FF

outer_delay_9:
   LDY #$FF
inner_delay_9:
   DEY
   BNE inner_delay_9
   DEX
   BNE outer_delay_9

    LDA #$53 ; S  
    STA $6001
    LDX #$FF

outer_delay_10:
   LDY #$FF
inner_delay_10:
   DEY
   BNE inner_delay_10
   DEX
   BNE outer_delay_10

    LDA #$43 ; C
    STA $6001
    LDX #$FF

outer_delay_11:
   LDY #$FF
inner_delay_11:
   DEY
   BNE inner_delay_11
   DEX
   BNE outer_delay_11

    LDA #$49 ; I
    STA $6001
    LDX #$FF

outer_delay_12:
   LDY #$FF
inner_delay_12:
   DEY
   BNE inner_delay_12
   DEX
   BNE outer_delay_12

    LDA #$20 ; Space
    STA $6001
    LDX #$FF

outer_delay_13:
   LDY #$FF
inner_delay_13:
   DEY
   BNE inner_delay_13
   DEX
   BNE outer_delay_13

    LDA #$34 ; 4
    STA $6001
    LDX #$FF

outer_delay_14:
   LDY #$FF
inner_delay_14:
   DEY
   BNE inner_delay_14
   DEX
   BNE outer_delay_14

    LDA #$39 ; 9
    STA $6001
    LDX #$FF

outer_delay_15:
   LDY #$FF
inner_delay_15:
   DEY
   BNE inner_delay_15
   DEX
   BNE outer_delay_15

    LDA #$39 ; 9
    STA $6001
    
    LDX #$FF
outer_delay_16:
    LDY #$FF
inner_delay_16:
    DEY
    BNE inner_delay_16
    DEX
    BNE outer_delay_16
    
    JSR show_t
    JSR show_r
    JMP forever

forever:
    NOP
    JMP forever

show_t:
    ; subroutine code here
    
    LDA #$54 ; T
    STA $6001
    ; Add delay like everywhere else
    LDX #$FF
outer_delay_t:
    LDY #$FF
inner_delay_t:
    DEY
    BNE inner_delay_t
    DEX
    BNE outer_delay_t
    
    RTS ; Return to caller

show_r:
    ; subroutine code here
    
    LDA #$52 ; R
    STA $6001
    ; Add delay like everywhere else  
    LDX #$FF
outer_delay_r:
    LDY #$FF
inner_delay_r:
    DEY
    BNE inner_delay_r
    DEX
    BNE outer_delay_r
    RTS ; Return to caller
