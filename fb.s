                org $4000
                put equ

* use this if font data (in binary format) is loaded at a fix address ($6000 in this example)
*numglyph        equ $6000
*gwidth          equ numglyph+2
*gheight         equ gwidth+1
*font            equ gheight+1
* otherwise put font data (in source format) at the end of this source file. 
* Labels must be the same in both cases (numglyph, gwidth, gheight, font)

ptr             equ $06

* calculate a glyph size (in bytes) 
* glyphsize/glyphsize+1 = gwidth * gheight
                lda #0
                sta glyphsize
                sta glyphsize+1

                ldx gwidth
*<sym>
calcsize        lda glyphsize
                clc 
                adc gheight
                sta glyphsize
                lda #0
                adc glyphsize+1
                sta glyphsize+1
                dex 
                bne calcsize
*
* init vars
                lda #0                          ; init index of data in glyph bitmap
                sta dataindex

                lda #30                         ; init top margin
                sta line
                clc 
                adc gheight
                sta maxv

                lda #3                         ; init left margin
                sta rowcnt
                sta leftmargin
                clc
                adc gwidth
                sta maxh 

*<sym>
the_glyph
                lda #$21                       ; glyph index in A,X (A = low byte, X = hi byte)
                ldx #$0
                jsr printglyph
                rts

printglyph   
*
* calcultate base address of the glyph, put it in gindex var
* gindex = glyph size * gindexcnt/gindexcnt+1                   
                sta gindexcnt                   ; init counter with glyph #
                stx gindexcnt+1

                lda #0 
                sta gindex                      ; init result
                sta gindex+1
*<sym>
setbaseaddress
                lda gindexcnt                   ; test counter
                ora gindexcnt+1
                beq next1                       ; end of loop

                lda glyphsize                   ; get size of a glyph bitmap
                clc 
                adc gindex                      ; add it to gl
                sta gindex
                lda glyphsize+1                  
                adc gindex+1
                sta gindex+1

                lda gindexcnt
                bne notZ
                dec gindexcnt+1
*<sym>               
notZ            dec gindexcnt
                jmp setbaseaddress
*<sym>
next1
                lda gindex                      ; add font address offset
                clc
                adc #<font
                sta gindex
                lda gindex+1
                adc #>font
                sta gindex+1

* gindex now points to the first byte of the selected glyph image.
*<sym>
                lda gindex              ; set data base address
                sta dataptr
                lda gindex+1
                sta dataptr+1
*<bp>
*<sym>

                lda dataptr             ; get base address of data in pointer
                sta getbyte+1
                lda dataptr+1
                sta getbyte+2
display
getbyte         lda $FFFF               ; modified by code !

                pha                     ; save data byte

                ldx line                ; get screen address
                lda lo,x 
                sta ptr
                lda hi,x 
                sta ptr+1

                pla                     ; restore data byte

                ldy rowcnt              ; set column  
                sta (ptr),y             ; put byte on screen

                inc rowcnt              ; next column
                inc getbyte+1
                bne noinc
                inc getbyte+2
noinc
                lda rowcnt              ; colomn = leftmargin + glyph width ?
                cmp maxh
                bne display             ; no loop

                lda leftmargin          ; reset col.
                sta rowcnt
                inc line                ; nexit line 
                lda line                ; 
                cmp maxv                ; line = top margin + glyph heignt ?
                bne display             ; no : loop
                      
                rts

*<sym>
leftmargin      ds 1

*<sym>
maxh            ds 1

*<sym>
maxv            ds 1

*<sym>
rowcnt          ds 1

*<sym>
dataindex       ds 1

*<sym>
line            ds 1

*<sym>
dataptr         ds 2

*<m1>
*<sym>
gindex          hex 0000
*<sym>
gindexcnt       hex 0000

*<m2>
*<sym>
glyphsize       ds 2

        put lohi
        put font                ; here is the data, in source format.
        