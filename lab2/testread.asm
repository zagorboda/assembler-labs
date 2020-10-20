STSEG SEGMENT PARA STACK "STACK"
	DB 64 DUP ("STACK")
STSEG ENDS

DSEG SEGMENT PARA PUBLIC "DATA"
	dump db 6, ?, 6 dup('?')
	l db 0
	is_negative db 0
	msg db "Bad input$"
    number dw 0
DSEG ENDS

CSEG SEGMENT PARA PUBLIC "CODE"
MAIN PROC FAR
ASSUME CS:CSEG,DS:DSEG,SS:STSEG

PUSH DS
MOV AX,0
PUSH AX
MOV AX,DSEG
MOV DS,AX

lea dx, dump
mov ah, 10
int 21h

lea di, dump
inc di
mov dl, [di]

; mov ah, 2
; int 21h

; mov l, 0

mov l, dl

; mov ah, 2
; int 21h

xor cx, cx
mov cl, l



; loop1:
; 	mov dl, cl
; 	mov ah, 2
; 	int 21h

; 	dec cx
; 	jne loop1



lea   di, dump
mov   cl, l   ; having the assembler generate this 
    ;constant from the length of the string prevents bugs 
    ;if you change the string
check_first_char:
	inc di
	inc di
    mov dl, [di]
    ; int 21h
    ; cmp dl, NULL_TERMINATOR

	; mov ah, 2
    ; int 21h

	cmp dl, 0
    je ending
    cmp dl, '-'
    je first_char_minus
    cmp dl, '+'
    je first_char_plus
    mov dl, [di]
    cmp dl, '0'
    jl bad_input_label
    cmp dl, '9'
    jg bad_input_label
    jmp check_loop
first_char_minus:
    inc di
    dec cl

    ; mov ax, cx
    ; mov ah, 2
    ; int 21h

    mov is_negative, 1
    jmp check_loop
first_char_plus:
    inc di
    dec cl

    ; mov ax, cx
    ; mov ah, 2
    ; int 21h

    jmp check_loop
    mov is_negative, 0
; pop ax
check_loop:
    mov dl, [di]
    cmp dl, '0'
    jl bad_input_label
    cmp dl, '9'
    jg bad_input_label
    inc di
    dec cl

    ; mov ax, cx
    ; mov ah, 2
    ; int 21h

    jne check_loop

	MOV dl, 10
	MOV ah, 02h
	INT 21h
	MOV dl, 13
	MOV ah, 02h
	INT 21h

    mov cl, l
    lea di, dump
	inc di
	inc di
    xor ax,ax
    xor bx,bx
    xor dx,dx
    ; xor cx,cx
    jmp print_loop

print_loop:
    mov bl, byte ptr [di]
    ; mov ah, 02h
    ; int 21h

    ; sub dl, "0"
    ; mov cl, byte [dump]
    sub bx, '0'
    ; mov dh, 0

    push cx
    push bx
    push dx
    call power_proc
    pop dx
    pop bx
    pop cx

    push dx
    mul bx
    pop dx
    add dx, ax

    ; mov ax, [dump]

    inc di
    dec cx
    jne print_loop
    jmp ending

bad_input_label:
    call bad_input_proc
    ; cmp trigger, 0
    jmp ending

ending:
    ; neg dx
    ; xor ax, ax
    ; sub ax, dx
    RET
    MAIN ENDP

bad_input_proc:
    LEA DX, msg
    MOV AH, 9
    INT 21H
    ret

power_proc:
    ; mov bl, l
    ; sub bl, cl
    ; mov cl, bl
    xor bx, bx
    mov bx, 10
    xor ax, ax
    mov ax, 1
    
    dec cx
    je power_proc_ending
    power:
        mul bx
        dec cl
        jne power

    power_proc_ending:
        ret

; digit_proc:

; lea bx, dump
; or bx, bx
; jns m1
; mov al, '-'
; int 29h
; neg bx
; m1:
;     mov ax, bx
;     xor cx, cx
;     mov bx, 10
; m2:
;     xor dx, dx
;     div bx
;     add dl, '0'
;     push dx
;     inc cx
;     test ax, ax
;     jnz m2
; m3:
;     pop ax
;     int 29h
;     loop m3
;     ret

CSEG ENDS
END MAIN