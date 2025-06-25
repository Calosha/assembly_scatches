.setcpu "65816"
.org $8000
start:
    lda #$01
    jmp start

.org $FFFC  
.word start
