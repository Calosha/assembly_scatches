.setcpu "65816"
.segment "RODATA"
.segment "CODE"

    ; stack init
    LDX #$FF
    TXS    

    ; display init
    JSR lcd_init

    LDA #$61 ; a
    JSR show_char

    LDA #$6C ; l  
    JSR show_char

    LDA #$65 ; e
    JSR show_char

    LDA #$78 ; x
    JSR show_char

    LDA #$65 ; e
    JSR show_char

    LDA #$79 ; y
    JSR show_char

    LDA #$2E ; dot
    JSR show_char

    LDA #$63 ; c
    JSR show_char

    LDA #$68 ; h
    JSR show_char

    LDA #$65 ; e
    JSR show_char

    LDA #$72 ; r
    JSR show_char

    LDA #$6E ; n
    JSR show_char

    LDA #$79 ; y
    JSR show_char

    LDA #$75 ; u
    JSR show_char

    LDA #$6B ; k
    JSR show_char
    
    LDA #$40 ; @
    JSR show_char

    LDA #$67 ; g
    JSR show_char

    LDA #$2A ; m
    JSR show_char

    LDA #$61 ; a
    JSR show_char

    LDA #$69 ; i
    JSR show_char

    LDA #$6C ; l  
    JSR show_char

    LDA #$2E ; dot
    JSR show_char

    LDA #$63 ; c
    JSR show_char

    LDA #$6F ; o
    JSR show_char

    LDA #$2A ; m
    JSR show_char

    JMP forever ; Go to forever loop

forever:
    NOP
    JMP forever

; Functions:

; Delay with minimum one loop of 1542 cycles ~830us * value of LDA set before execution
delay:
    TAX ; transfer A --> X
outer_loop:
    LDY #$FF ; Init Y index
inner_loop:
    DEY ; y--
    BNE inner_loop ; if Z flag is 0 branch to inner_delay else continue (Z flag is 1 when previous operation is 0)
    DEX ; x--
    BNE outer_loop ; if Z flag is 0 branch to outer_delay else continue
    RTS ; return

; Show single character
show_char:
    PHA ; Save character ( push accumulator into stack)
    LDA #$01 ; 842us
    JSR delay ; Wait before write
    PLA ; restore character (pull accumulator from stack)
    STA $6001 ; Write the character
    RTS ; Return to caller

; Initialize display
lcd_init:
    LDA #$3C ; this is 60 times loop of 255 2 (255*6)+2 = 1534 cycles for inner loop (~49.9 ms delay) req 40ms
    JSR delay

    ; First sequence 
    LDA #$30
    STA $6000
    NOP ; 2x0.54 microsecond delay jic

    LDA #$05 ; this is 5 times loop of 255 2 (255*6)+2 +8(outerloop overhead) = 1542 cycles for inner loop (~6.2ms delay) req 4.2ms
    JSR delay

    ; Second sequence 
    LDA #$30
    STA $6000
    NOP

    LDA #$01 ; 1542 cycles for inner loop (~842us delay) req 100us
    JSR delay
    
    ; Third sequence
    LDA #$30
    STA $6000
    NOP

    LDA #$01 ; 1542 cycles for inner loop (~842us delay) req 37us for function set
    JSR delay

    ; what is 38? function set 2 line 5x8 dots
    LDA #$38
    STA $6000
    NOP
    
    LDA #$01 ; 1542 cycles for inner loop (~842us delay) req 37us for display off
    JSR delay

    ; Display off
    LDA #$08
    STA $6000
    NOP

    LDA #$01 ; 1542 cycles for inner loop (~842us delay) req 37 us after Display off command
    JSR delay

    ; Display clear
    LDA #$01
    STA $6000
    NOP

    LDA #$05 ; 1542 cycles for inner loop (~2.5ms delay) req 1.52
    JSR delay
    
    ; Entry mode set (I/D=1: Cursor moves right (increment))
    LDA #$06 
    STA $6000
    NOP
    
    LDA #$01 ; 1542 cycles for inner loop (~842us delay) req 37us for Display ON/OFF Control
    JSR delay

    LDA #$0C ;  Display ON/OFF Control:Display ON /Cursor OFF/ Blink OFF
    STA $6000
    NOP
  
    LDA #$01 ; 1542 cycles for inner loop (~842us delay) req 37us between letters ( move to show letter function)
    JSR delay

    RTS ; return
