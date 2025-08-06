.setcpu "65816"
;===============================================
; Zero Page Usage Map
;===============================================
string_ptr   = $00    ; String pointer (2 bytes: $00-$01)
tmp          = $02    ; general purpose temp
key_found    = $03    ; flag to stop the scan
keypad_row   = $04    ; store keypad row value
keypad_col   = $05    ; store keypad column value
; $06-$FF available for future use

;===============================================
; RAM Variables uninitialized
;===============================================
.segment "BSS"
;===============================================
; LCD
;===============================================
lcd_char_count: .res 1    ; Position counter for 16x2 LCD (0-31)
lcd_curr_char: .res 1

;===============================================
; Keyboard
;===============================================
last_key_pressed: .res 1
new_key_flag: .res 1

;===============================================
; Calculator
;===============================================
calculator_state: .res 1  ; 0=entering first operand, 1=entering second operand, 2=showing result
first_operand: .res 1
second_operand: .res 1
operator: .res 1
result: .res 1
input_buffer: .res 1

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
    VIA_IER = VIA_BASE+$E

    ; LED
    LED_BASE = $9000

    email_string:
        .byte "CSCI499 Capstone Alexey Chernyuk",0
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

main_loop:
    JSR keyboard_scan
    JSR calculator_check_input ; calculator
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
@outer_loop:
    LDY #$FF ; Init Y index
@inner_loop:
    DEY ; y--
    BNE @inner_loop ; if Z flag is 0 branch to inner_delay else continue (Z flag is 1 when previous operation is 0)
    DEX ; x--
    BNE @outer_loop ; if Z flag is 0 branch to outer_delay else continue
    PLY ; restore Y
    PLX ; restore X
    RTS ; return

; Test if we can read from display
read_lcd_status:
    LDA LCD_INST           ; Read LCD status
    LDA LCD_INST_E         ; Pulse E
    NOP
    RTS

; Show string
show_string:
    STA string_ptr
    STX string_ptr+1
    LDY #0 ; start at the first character
@loop:
    LDA (string_ptr), Y
    BEQ @done
    
    JSR show_char         ; Show actual character
    
    INY
    JMP @loop
@done:
    ; Now show the Y index as a number
    TYA           ; Transfer Y to A
    RTS

; Show single character
show_char:
    STA lcd_curr_char
    JSR send_data_BF
    
    ; change line if there are alredy 16 chars shown on LCD
    INC lcd_char_count ; Character is written account for it
    
    LDA lcd_char_count
    CMP #33
    BEQ lcd_start_over
    
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

send_command_BF:
    STA LCD_INST ; Put command on bus (no E pulse yet)
    STA LCD_INST_E ; Pulse E to latch a command (RS=0)(E=1)
    STA LCD_INST ; Clear E=0 to complete pulse (RS=0, E=0)
@wait_loop:
    LDA LCD_INST           ; Read LCD status
    LDA LCD_INST_E         ; Pulse E
    PHA
    LDA LCD_INST ;clear E incase we need to read again
    PLA
    BMI @wait_loop ; if highest bit is set then lcd is busy
    
    RTS ; return

send_data_BF:
    PHA
    LDA #$01 ; 1542 cycles for inner loop (~842us delay) req 100us (moved the most common delay here)
    JSR delay
    PLA
    STA LCD_DATA ; Put command on bus (no E pulse yet)
    STA LCD_DATA_E ; Pulse E to latch a command (RS=0)(E=1)
    STA LCD_DATA ; Clear E=0 to complete pulse (RS=0, E=0)
@wait_loop:
    LDA LCD_INST           ; Read LCD status
    LDA LCD_INST_E         ; Pulse E
    PHA
    LDA LCD_INST ;clear E incase we need to read again
    PLA
    BMI @wait_loop ; if highest bit is set then lcd is busy
    LDA #$01 ; 1542 cycles for inner loop (~842us delay) req 100us (moved the most common delay here)
    JSR delay
    RTS ; return

; TODO: remove showing new char from start over we need this function
lcd_start_over:
    STZ lcd_char_count  ; Reset counter to 0
    JSR lcd_clear ; clear screen
    JSR lcd_move_to_line_1 ; go back to 0,0
    LDA lcd_curr_char
    JSR show_char
    RTS

lcd_start_over_calc:
    STZ lcd_char_count  ; Reset counter to 0
    JSR lcd_clear ; clear screen
    JSR lcd_move_to_line_1 ; go back to 0,0
    RTS

lcd_move_to_line_2:
    LDA #$C0 ; line 2 position 0
    JSR send_command_BF
    RTS

lcd_move_to_line_1:
    LDA #$80 ; line 1 position 0
    JSR send_command_BF
    RTS

lcd_clear:
    LDA #$01
    JSR send_command_BF
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
    JSR send_command_BF

    ; Display off
    LDA #$08
    JSR send_command_BF

    ; Display clear
    LDA #$01
    JSR send_command_BF

    ; Entry mode set (I/D=1: Cursor moves right (increment))
    LDA #$06 
    JSR send_command_BF

    LDA #$0C ;  Display ON/OFF Control:Display ON /Cursor OFF/ Blink OFF
    JSR send_command_BF

    STZ lcd_char_count

    RTS ; return

; Initialize VIA for keyboard
keypad_init:
    LDA #$0F ; 8 PA pins and 0-3 are output (1)
    STA VIA_DDRA ; set direction

    STZ VIA_DDRB ; set all pinst to input

    LDA #$0F 
    STA VIA_PORTA ; all output pins are high

    LDA #$7F
    STA VIA_IER ; disable interrups

    RTS ; return 

; Scan the keypad
keyboard_scan:
    STZ key_found ; Reset the flag
    CLC
    LDY #4
    LDA #$FE
@loop:
    STA VIA_PORTA ; load bits from port A
    ; Check column here
    JSR check_column
    PHA ; push row pattern to stack
    LDA key_found ; check the flag from check_column
    BNE @key_was_found ; Exit if key found
    PLA; if not done restore row value
    ROL A ; rotate left (read more on it)
    DEY ; Y--
    BEQ @done ; if Y is zero then we are done
    JMP @loop ; otherwise jump back to loop
@key_was_found:
    PLA ;restore the a value and go to done_scan
@done:
    RTS ; retrun when done
    
check_column:
    PHA ; save row value to stack
    LDA VIA_PORTB ; load bits from port b
    AND #$0F ; mask upper 4 bits (not connected)
    CMP #$0F
    BEQ no_key_pressed
    ; key pressed
    STA keypad_col
    ASL A ; shift 4 bits to high position of the byte
    ASL A
    ASL A
    ASL A
    STA tmp ; save shifted column pattern for LED display
    ; wait for release
wait_release:
    LDA VIA_PORTB
    AND #$0F ; mask upper 4 bits
    CMP #$0F
    BNE wait_release
    LDA #$05 ; 1542 cycles for inner loop (~2.5ms delay)
    JSR delay ; this will block key repetition 

    PLA ; load row back to A
    AND #$0F ; mask to get only the low 4 bits of row
    STA keypad_row
    ORA tmp ; cobine row with column

    JSR get_keypad_key_value
    STA last_key_pressed

    JSR show_char
    LDA #$01
    STA key_found ; Save the fact that key is found to stop scaning
    STA new_key_flag
    RTS ; key detected nothing else to do
no_key_pressed:
    PLA ; restore A
    RTS

get_keypad_key_value:
    STZ tmp ; clean temp jic
    LDA keypad_col ; load back 4 bits of col position
    EOR #$0F ; invert col
    TAX ; load to x
    CPX #09 ; 9 will be out of bound
    BCS @invalid_key
    LDA POS_TO_SEQ, X  ; get sequential column position back into A
    STA tmp ; now temp stores sequential column value
    LDA keypad_row ; load back 4 bits of row position
    EOR #$0F ; invert row
    TAX ; load to x
    CPX #16
    BCS @invalid_key
    LDA POS_TO_SEQ, X  ; get sequential row position back into A
    ASL A ; multily by 4
    ASL A
    CLC; clear carry flag befor addition
    ADC tmp ; (row * 4) + column
    TAX; load a to index x
    LDA KEYPAD_MAP, X ; get ascii value of the pressed key
    RTS ; A holds the ascii value lets get out
@invalid_key:
    LDA #$FF ; load error black box
    JSR write_to_led ; lets see if we get here
    RTS ; return 

; Can't belive I went this far!
calculator_check_input:
    LDA new_key_flag ; execute calculator only if new key is pressed
    BNE @continue  ; Branch if key pressed
    RTS           ; Return immediately if no key
@continue:
    LDA calculator_state
    CMP #2
    BNE @begin
    ;clear screen clear state
    STZ first_operand
    STZ second_operand
    JSR lcd_start_over_calc
    STZ calculator_state ; start over
@begin:
    STZ new_key_flag
    LDA last_key_pressed
     
    CMP #$30     ; Compare with '0'
    BCC @not_digit  ; Branch if A < '0' 
    CMP #$3A     ; Compare with ':'
    BCS @not_digit  ; Branch if A >= ':'

@digit: ; Cheap local label for the flow clarity
    ; is digit
    ; Convert ascii to binary
    AND #$0F
    PHA ; save to stack 
    LDA calculator_state ; load calculator state
    BNE @load_second
    ; Check if we need to add to first or second operand
@load_first:
    PLA ; get digit back from stack
    STA first_operand
    JMP @done
@load_second:
    PLA ; get digit back from stack
    STA second_operand
    JMP @done

@not_digit:
    ; Check if it's 'E' (equals)
    CMP #'E'
    BNE @check_operator
    JMP @calculate    ; Jump to calculate if it's 'E'
    
@check_operator:
    CMP #'+'
    BEQ @operator
    CMP #'*'
    BEQ @operator
    CMP #'-'
    BEQ @operator
    CMP #'/'
    BEQ @operator
    JMP @done        ; Not a valid key
    
@operator:
    ; save operator will be used to calculate the result
    STA operator
    LDA #1 
    STA calculator_state
    JMP @done

@calculate:    
    JSR lcd_start_over_calc
    LDA #0 
    STA calculator_state
    CLC
    LDA operator
    CMP #'+'
    BNE @not_add
    JMP @do_add      ; Use JMP for long distance
@not_add:
    CMP #'*'
    BNE @not_mul
    JMP @do_mul
@not_mul:
    CMP #'-'
    BNE @not_sub
    JMP @do_sub
@not_sub:
    JMP @done        ; No valid operator
@do_add:
    CLC
    LDA first_operand
    ADC second_operand
    STA result
    JMP @show
@do_mul:
    LDA #0 ; Start with 0
    LDX second_operand
    BEQ @mul_done ; Handle multiply by 0
@mul_loop:
    CLC
    ADC first_operand
    DEX
    BNE @mul_loop
@mul_done:
    STA result
    JMP @show
@do_sub:
    SEC
    LDA first_operand
    SBC second_operand
    BCS @positive_result  ; If carry set, result is positive
    ; Negative result - show minus sign
    PHA                   ; Save negative result
    LDA #'-'
    JSR show_char
    PLA
    EOR #$FF             ; Two's complement
    CLC
    ADC #1
@positive_result:
    STA result
    JMP @show
    
@show:
    LDA result
    CMP #10
    BCC @single_digit
; Two digits - extract tens
    LDX #0      ; Counter for tens
@count_tens:
    CMP #10
    BCC @show_tens
    SEC         ; Set Carry flag (sets carry to 1)
    SBC #10     ; Subtract 10 (with borrow)
    INX         ; Count how many 10s
    JMP @count_tens
@show_tens:
    PHA         ; Save remainder (ones digit)
    TXA         ; Get tens count
    CLC
    ADC #$30    ; Convert to ASCII
    JSR show_char
    PLA         ; Restore ones digit

@single_digit:
    CLC
    ADC #$30 ; convert back to ascii
    JSR show_char
    LDA #2
    STA calculator_state

    JMP @done

@done:
    RTS

