;===============================================
; Zero Page Usage Map
;===============================================
string_ptr   = $00    ; String pointer (2 bytes: $00-$01)
; $02-$FF available for future use

;===============================================
; RAM Variables (outside zero page)
;===============================================
; lcd_char_count: .res 1    ; Position counter for 16x2 LCD (0-31)


.setcpu "65816"

.segment "RODATA"
    email_string:
        .byte "alexey.chernyuk@gmail.com",0
.segment "CODE"


    ; stack init
    LDX #$FF 
    TXS ; 65816 reserves page1 for stack so txs will get $01FF that reflects in black space for stack in memory map

    ; display init
    JSR lcd_init

    ; Show email address
    LDA #< email_string ; load low byte into A
    LDX #> email_string ; load high byte into X


    JSR show_string

    
    JMP forever ; Go to forever loop

forever:
    NOP
    JMP forever

;===============================================
; Functions
;===============================================

; Delay with minimum one loop of 1542 cycles ~830us * value of LDA set before execution
delay:
    PHY ; Save Y to avoid conflicts
    PHX ; Save X to avoid conflicts
    TAX ; transfer A --> X
outer_loop:
    LDY #$FF ; Init Y index
inner_loop:
    DEY ; y--
    BNE inner_loop ; if Z flag is 0 branch to inner_delay else continue (Z flag is 1 when previous operation is 0)
    DEX ; x--
    BNE outer_loop ; if Z flag is 0 branch to outer_delay else continue
    PLY ; restore Y
    PLX ; restore X
    RTS ; return

; Show single character
show_char:
    PHA ; Save character ( push accumulator into stack)
    LDA #$01 ; 842us
    JSR delay ; Wait before write
    PLA ; restore character (pull accumulator from stack)
    STA $6001 ; Put character on data bus (no E pulse yet)
    STA $6003 ; Pulse E to latch character data (RS=1)(E=1)
    STA $6001 ; Clear E=0 to complete pulse (RS=1)(E=0)
    LDA #$01 ; 842us
    JSR delay ; Wait after write LCD needs some time to finish writing
    RTS ; Return to caller

; Send command to LCD
send_command:
    STA $6000 ; Put command on bus (no E pulse yet)
    STA $6002 ; Pulse E to latch a command (RS=0)(E=1)
    NOP ; 2x0.54 microsecond delay jic
    STA $6000 ; Clear E=0 to complete pulse (RS=0, E=0)
    NOP ; 2x0.54 microsecond delay jic
    RTS
    

; Show string
show_string:
    STA string_ptr
    STX string_ptr+1
    SEP #$20 ; FORCE 8-bit accumulator mode
    .a8 ; Tell ASSEMBLER accumulator is 8-bit
    LDY #0 ; start at the first character
loop:
    LDA (string_ptr), Y
    BEQ done
    
    JSR show_char         ; Show actual character
    
    INY
    JMP loop
done:
    ; Now show the Y index as a number
    TYA           ; Transfer Y to A
    JSR write_to_led ; Display the index
    RTS

; Show binary digit on 373 latch with led
write_to_led:
    STA $9000 ; Write accumulator to LED 373
    RTS

; Initialize display
lcd_init:
    LDA #$3C ; this is 60 times loop of 255 2 (255*6)+2 = 1534 cycles for inner loop (~49.9 ms delay) req 40ms
    JSR delay

    ; First sequence 
    ; TODO: abstract to send command subroutine
    LDA #$30
    JSR send_command


    LDA #$05 ; this is 5 times loop of 255 2 (255*6)+2 +8(outerloop overhead) = 1542 cycles for inner loop (~6.2ms delay) req 4.2ms
    JSR delay

    ; Second sequence 
    LDA #$30
    JSR send_command

    LDA #$01 ; 1542 cycles for inner loop (~842us delay) req 100us
    JSR delay
    
    ; Third sequence
    LDA #$30
    JSR send_command

    LDA #$01 ; 1542 cycles for inner loop (~842us delay) req 37us for function set
    JSR delay

    ; what is 38? function set 2 line 5x8 dots and 8bit mode
    LDA #$38
    JSR send_command
    
    LDA #$01 ; 1542 cycles for inner loop (~842us delay) req 37us for display off
    JSR delay

    ; Display off
    LDA #$08
    JSR send_command

    LDA #$01 ; 1542 cycles for inner loop (~842us delay) req 37 us after Display off command
    JSR delay

    ; Display clear
    LDA #$01
    JSR send_command

    LDA #$05 ; 1542 cycles for inner loop (~2.5ms delay) req 1.52
    JSR delay
    
    ; Entry mode set (I/D=1: Cursor moves right (increment))
    LDA #$06 
    JSR send_command
    
    LDA #$01 ; 1542 cycles for inner loop (~842us delay) req 37us for Display ON/OFF Control
    JSR delay

    LDA #$0C ;  Display ON/OFF Control:Display ON /Cursor OFF/ Blink OFF
    JSR send_command
    
    ; TODO: Delete me or not
    LDA #$01 ; 1542 cycles for inner loop (~842us delay) req 37us between letters ( move to show letter function)
    JSR delay

    RTS ; return
