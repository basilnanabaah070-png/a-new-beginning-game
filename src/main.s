; A NEW BEGINNING - NES visual-novel prototype
; Build with ca65 + ld65.

.segment "HEADER"
.byte "N","E","S",$1A
.byte 2                    ; 32 KB PRG
.byte 1                    ; 8 KB CHR
.byte $00                  ; mapper 0, horizontal mirroring
.byte $00
.res 8, $00

.segment "ZEROPAGE"
ptr:            .res 2
nmi_ready:      .res 1
pad1:           .res 1
pad1_new:       .res 1
choice:         .res 1
scene:          .res 1
maya_affection: .res 1
sophia_affection:.res 1
trust:          .res 1
jealousy:       .res 1
honesty:        .res 1

.segment "BSS"
message_buffer: .res 64

.segment "CODE"

reset:
    sei
    cld
    ldx #$40
    stx $4017
    ldx #$ff
    txs
    inx
    stx $2000
    stx $2001
    stx $4010
    jsr wait_vblank
    jsr clear_ram
    jsr init_ppu
    lda #$01
    sta scene
    jsr title_screen

main_loop:
    jsr read_controller
    lda scene
    cmp #$01
    beq scene_intro
    cmp #$02
    beq scene_rooftop
    cmp #$03
    beq scene_invitations
    cmp #$04
    beq scene_mystery
    cmp #$05
    beq scene_final
    jmp main_loop

scene_intro:
    jsr show_intro
    lda pad1_new
    and #$10              ; A
    beq main_loop
    inc scene
    jmp main_loop

scene_rooftop:
    jsr show_rooftop
    lda pad1_new
    and #$10
    beq main_loop
    inc maya_affection
    inc maya_affection
    inc trust
    inc scene
    jmp main_loop

scene_invitations:
    jsr show_invitations
    lda pad1_new
    and #$01              ; right: Sophia
    beq check_maya_choice
    inc sophia_affection
    inc sophia_affection
    inc sophia_affection
    inc honesty
    lda #$04
    sta scene
    jmp main_loop
check_maya_choice:
    lda pad1_new
    and #$02              ; left: Maya
    beq main_loop
    inc maya_affection
    inc maya_affection
    inc maya_affection
    inc honesty
    lda #$04
    sta scene
    jmp main_loop

scene_mystery:
    jsr show_mystery
    lda pad1_new
    and #$10
    beq main_loop
    inc trust
    inc honesty
    inc investigation
    lda #$05
    sta scene
    jmp main_loop

scene_final:
    jsr show_final
    lda pad1_new
    and #$01
    bne choose_sophia
    lda pad1_new
    and #$02
    bne choose_maya
    lda pad1_new
    and #$10
    beq main_loop
    jmp ending_neither
choose_sophia:
    lda sophia_affection
    cmp #$03
    bcc ending_neither
    jmp ending_sophia
choose_maya:
    lda maya_affection
    cmp #$03
    bcc ending_neither
    jmp ending_maya

; ---------------- PPU ----------------
init_ppu:
    lda #%10001000
    sta $2000
    lda #%00011110
    sta $2001
    jsr clear_nametable
    rts

wait_vblank:
    bit $2002
wait_vblank_loop:
    bit $2002
    bpl wait_vblank_loop
    rts

clear_nametable:
    jsr wait_vblank
    lda #$20
    sta $2006
    lda #$00
    sta $2006
    ldx #$00
    ldy #$10
clear_loop:
    lda #$00
    sta $2007
    dex
    bne clear_loop
    dey
    bne clear_loop
    rts

clear_ram:
    lda #$00
    tax
clear_ram_loop:
    sta $0000,x
    sta $0100,x
    sta $0200,x
    sta $0300,x
    sta $0400,x
    sta $0500,x
    sta $0600,x
    sta $0700,x
    inx
    bne clear_ram_loop
    rts

; Draw a zero-terminated tile string at the supplied nametable address.
; A minimal placeholder font is included below; projects can replace CHARS.
draw_string:
    ldy #$00
draw_loop:
    lda (ptr),y
    beq draw_done
    sta $2007
    iny
    bne draw_loop
draw_done:
    rts

show_text:
    jsr clear_nametable
    lda #$20
    sta $2006
    lda #$40
    sta $2006
    lda #<title_text
    sta ptr
    lda #>title_text
    sta ptr+1
    jsr draw_string
    rts

; ---------------- scenes ----------------
title_screen:
    jsr show_text
    rts

show_intro:
    jsr clear_nametable
    jsr point_2040
    lda #<intro_text
    sta ptr
    lda #>intro_text
    sta ptr+1
    jsr draw_string
    rts

show_rooftop:
    jsr clear_nametable
    jsr point_2040
    lda #<rooftop_text
    sta ptr
    lda #>rooftop_text
    sta ptr+1
    jsr draw_string
    rts

show_invitations:
    jsr clear_nametable
    jsr point_2040
    lda #<invite_text
    sta ptr
    lda #>invite_text
    sta ptr+1
    jsr draw_string
    rts

show_mystery:
    jsr clear_nametable
    jsr point_2040
    lda #<mystery_text
    sta ptr
    lda #>mystery_text
    sta ptr+1
    jsr draw_string
    rts

show_final:
    jsr clear_nametable
    jsr point_2040
    lda #<final_text
    sta ptr
    lda #>final_text
    sta ptr+1
    jsr draw_string
    rts

point_2040:
    lda #$20
    sta $2006
    lda #$40
    sta $2006
    rts

; ---------------- controller ----------------
read_controller:
    lda pad1
    sta pad1_new
    lda #$01
    sta $4016
    lda #$00
    sta $4016
    ldx #$08
read_pad_loop:
    lda $4016
    lsr a
    rol pad1
    dex
    bne read_pad_loop
    lda pad1
    eor pad1_new
    and pad1
    sta pad1_new
    rts

; ---------------- endings ----------------
ending_maya:
    jsr clear_nametable
    jsr point_2040
    lda #<maya_end
    sta ptr
    lda #>maya_end
    sta ptr+1
    jsr draw_string
    jmp ending_wait
ending_sophia:
    jsr clear_nametable
    jsr point_2040
    lda #<sophia_end
    sta ptr
    lda #>sophia_end
    sta ptr+1
    jsr draw_string
    jmp ending_wait
ending_neither:
    jsr clear_nametable
    jsr point_2040
    lda #<neither_end
    sta ptr
    lda #>neither_end
    sta ptr+1
    jsr draw_string
ending_wait:
    jsr read_controller
    lda pad1_new
    and #$10
    beq ending_wait
    jmp reset

.segment "RODATA"
title_text:   .byte "A NEW BEGINNING",0
intro_text:   .byte "DANIEL MOVES TO A NEW CITY. MAYA HELPS WITH HIS BAGS. PRESS A.",0
rooftop_text: .byte "MAYA INVITES DANIEL TO DINNER ON THE ROOFTOP. PRESS A.",0
invite_text:  .byte "TWO INVITATIONS. LEFT: MAYA  RIGHT: SOPHIA",0
mystery_text: .byte "ALEX REVEALS A PHOTO. THE TRUTH BEGAN FIVE YEARS AGO. PRESS A.",0
final_text:   .byte "THE TRUTH IS OUT. LEFT: MAYA RIGHT: SOPHIA A: NEITHER",0
maya_end:     .byte "ENDING: A NEW BEGINNING - DANIEL CHOOSES MAYA.",0
sophia_end:   .byte "ENDING: SECOND CHANCE - DANIEL CHOOSES SOPHIA.",0
neither_end:  .byte "ENDING: A NEW PATH - DANIEL CHOOSES HONESTY.",0

.segment "VECTORS"
.word nmi
.word reset
.word irq

.segment "CHARS"
; Blank 8 KB placeholder CHR-ROM. Replace with a font/tileset.
.res 8192, $00

.segment "CODE"
nmi:
    rti
irq:
    rti
