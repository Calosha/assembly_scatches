.setcpu "65816"
;===============================================
; Zero Page Usage Map
;===============================================
string_ptr   = $00    ; String pointer (2 bytes: $00-$01)
tmp          = $02    ; general purpose temp
key_found    = $03    ; flag to stop the scan
keypad_row   = $04    ; store keypad row value
keypad_col   = $05    ; store keypad column value
; $05-$FF available for future use

;===============================================
; RAM Variables uninitialized
;===============================================
.segment "BSS"

lcd_char_count: .res 1    ; Position counter for 16x2 LCD (0-31)


.segment "RODATA"
    ;===============================================
    ; Config:
    ;===============================================
    ; LCD
    LCD_BASE = $6000

    LCD_INST = LCD_BASE+$0
    LCD_INST_E = LCD_BASE+$2

    LCD_DATA = LCD_BASE+$1
    LCD_DATA_E = LCD_BASE+$3

    ; VIA
    VIA_BASE = $A000
    VIA_PORTB = VIA_BASE+$0
    VIA_PORTA = VIA_BASE+$1  
    VIA_DDRB = VIA_BASE+$2
    VIA_DDRA = VIA_BASE+$3

    ; LED
    LED_BASE = $9000

    email_string:
        .byte "Zaychick sladkiy marmeladniy!",0
    ; maps position of 1 in the binary sting to its sequential value
    POS_TO_SEQ:
        .byte 0, 0, 1, 0, 2, 0, 0, 0, 3  ; indices 0-8

    KEYPAD_MAP:
        .byte "E", ".", "0", "/"
        .byte "*", "3", "2", "1"
        .byte "+", "6", "5", "4"
        .byte "-", "9", "8", "7"
.segment "CODE"

    ; stack init
    LDX #$FF 
    TXS ; 65816 reserves page1 for stack so txs will get $01FF that reflects in black space for stack in memory map

    ; display init
    JSR lcd_init
    ; keypad init
    JSR keypad_init

    ; Show email address
    LDA #< email_string ; load low byte into A
    LDX #> email_string ; load high byte into X

    JSR show_string

    JSR test_pa_pins

main_loop:
    JSR keyboard_scan
    JMP main_loop
    
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
    STA LCD_DATA ; Put character on data bus (no E pulse yet)
    STA LCD_DATA_E ; Pulse E to latch character data (RS=1)(E=1)
    STA LCD_DATA ; Clear E=0 to complete pulse (RS=1)(E=0)
    LDA #$01 ; 842us
    JSR delay ; Wait after write LCD needs some time to finish writing
    
    ; change line if there are alredy 16 chars shown on LCD
    INC lcd_char_count ; Character is written account for it
    LDA lcd_char_count
    AND #$0F ; mod 16
    BEQ lcd_move_to_line_2

    RTS ; Return to caller

; Send command to LCD
send_command:
    STA LCD_INST ; Put command on bus (no E pulse yet)
    STA LCD_INST_E ; Pulse E to latch a command (RS=0)(E=1)
    NOP ; 2x0.54 microsecond delay jic
    STA LCD_INST ; Clear E=0 to complete pulse (RS=0, E=0)
    LDA #$01 ; 1542 cycles for inner loop (~842us delay) req 100us (moved the most common delay here)
    JSR delay
    RTS
    

; Show string
show_string:
    STA string_ptr
    STX string_ptr+1
    LDY #0 ; start at the first character
st_loop:
    LDA (string_ptr), Y
    BEQ done
    
    JSR show_char         ; Show actual character
    
    INY
    JMP st_loop
done:
    ; Now show the Y index as a number
    TYA           ; Transfer Y to A
    JSR write_to_led ; Display the index
    RTS

; Show binary digit on 373 latch with led
write_to_led:
    STA LED_BASE ; Write accumulator to LED 373
    RTS

; Initialize display
lcd_init:
    LDA #$3C ; this is 60 times loop of 255 2 (255*6)+2 = 1534 cycles for inner loop (~49.9 ms delay) req 40ms
    JSR delay

    ; First sequence 
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

    ; what is 38? function set 2 line 5x8 dots and 8bit mode
    LDA #$38
    JSR send_command
    

    ; Display off
    LDA #$08
    JSR send_command

    ; Display clear
    LDA #$01
    JSR send_command

    LDA #$05 ; 1542 cycles for inner loop (~2.5ms delay) req 1.52
    JSR delay
    
    ; Entry mode set (I/D=1: Cursor moves right (increment))
    LDA #$06 
    JSR send_command

    LDA #$0C ;  Display ON/OFF Control:Display ON /Cursor OFF/ Blink OFF
    JSR send_command
    
    STZ lcd_char_count

    RTS ; return

lcd_move_to_line_2:
    LDA #$C0 ; line 2 position 0
    JSR send_command
    ; TODO: try to clear display one more time to get rid of trailing blackbox
    RTS

; Initialize VIA for keyboard
keypad_init:
    LDA #$0F ; 8 PA pins and 0-3 are output (1)
    STA VIA_DDRA ; set direction

    STZ VIA_DDRB ; set all pinst to input

    LDA #$0F 
    STA VIA_PORTA ; all output pins are high
    RTS ; return 

test_pa_pins:
    LDA #$05        ; 0101 = PA1 and PA0 HIGH
    STA VIA_PORTA
    
    LDA VIA_PORTA
    AND #$0F
    CMP #$05        ; Check if reads back as 5
    BEQ pa_ok
    
    LDA #$FF        ; Error
    JSR write_to_led
    RTS
    
pa_ok:
    LDA #$05        ; Success - show 5 on LED
    JSR write_to_led
    RTS

; Scan the keypad
keyboard_scan:
    STZ key_found ; Reset the flag
    CLC
    LDY #4
    LDA #$FE
kb_loop:
    STA VIA_PORTA ; load bits from port A
    ; Check column here
    JSR check_column
    PHA ; push row pattern to stack
    LDA key_found ; check the flag from check_column
    BNE key_was_found ; Exit if key found
    PLA; if not done restore row value
    ROL A ; rotate left (read more on it)
    DEY ; Y--
    BEQ done_scan ; if Y is zero then we are done
    JMP kb_loop ; otherwise jump back to loop
key_was_found:
    PLA ;restore the a value and go to done_scan
done_scan:
    RTS ; retrun when done
    
check_column:
    PHA ; save row value to stack
    LDA VIA_PORTB ; load bits from port b
    AND #$0F ; mask upper 4 bits (not connected)
    CMP #$0F
    BEQ no_key_pressed
    STA keypad_col
    ; key pressed
    ASL A ; shift 4 bits to high position of the byte
    ASL A
    ASL A
    ASL A

    STA tmp ; transfer to temp

    PLA ; load row back to A
    AND #$0F ; mask to get only the low 4 bits of row
    STA keypad_row
    ORA tmp ; cobine row with column

    ;  show on led
    JSR write_to_led
    JSR get_keypad_key_value
    JSR show_char
    LDA #$01
    STA key_found ; Save the fact that key is found to stop scaning
    RTS ; key detected nothing else to do
no_key_pressed:
    PLA ; restore A
    RTS

get_keypad_key_value:
    STZ tmp ; clean temp jic
    LDA keypad_col ; load back 4 bits of col position
    EOR #$0F ; invert col
    TAX ; load to x
    LDA POS_TO_SEQ, X  ; get sequential column position back into A
    STA tmp ; now temp stores sequential column value
    LDA keypad_row ; load back 4 bits of row position
    EOR #$0F ; invert row
    TAX ; load to x
    LDA POS_TO_SEQ, X  ; get sequential row position back into A
    ASL A ; multily by 4
    ASL A
    CLC; clear carry flag befor addition
    ADC tmp ; (row * 4) + column
    TAX; load a to index x
    LDA KEYPAD_MAP, X ; get ascii value of the pressed key
    RTS ; A holds the ascii value lets get out



