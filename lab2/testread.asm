; 24 : -96
STSEG SEGMENT PARA STACK "STACK"
	DB 64 DUP ("STACK")
STSEG ENDS

DSEG SEGMENT PARA PUBLIC "DATA"
    dump db 6, ?, 6 dup('?')
	l db 0
	first_char db 0
	msg db "Bad input$"
    msg_overflow db "Overflow after math operation$"
    number dw 1
DSEG ENDS

CSEG SEGMENT PARA PUBLIC "CODE"
.386
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

    mov first_char, 1
    jmp check_loop
first_char_plus:
    inc di
    dec cl

    ; mov ax, cx
    ; mov ah, 2
    ; int 21h

    mov first_char, 2
    jmp check_loop
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
    cmp first_char, 0
    jg first_char_inc
    jmp print_loop

first_char_inc:
    inc di
    dec cx 

print_loop:
    mov bl, byte ptr [di]
    ; mov ah, 02h
    ; int 21h

    ; sub dl, "0"
    ; mov cl, byte [dump]
    sub bx, '0'
    ; sub dl, '0'
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
    jo call_overflow
    jc call_overflow
    ; mov number, dx
    ; sub dx, ax
    ; mov ax, [dump]
    
    inc di
    dec cx
    jne print_loop
    mov number, dx
    xor dx, dx
    mov dx, number
    ; cmp dx,
    ; cmp dx, 32767
    ; jg call_overflow
    add dx, 32767
    ; jo call_overflow
    jc call_overflow
    sub dx, 32767
    ; sub dx, 1
    ; jc call_overflow
    ; jg call_overflow
    ; mov ax, dx
    ; sub dx, 96
    ; add dx, 32000
    cmp first_char, 1
    je math_op_minus
    cmp first_char, 2
    je math_op_plus
    cmp first_char, 0
    je math_op_plus
    jmp ending


; jmp ending

bad_input_label:
    call bad_input_proc
    ; cmp trigger, 0
    jmp ending

math_op_minus:

    add dx, 96
    jmp ending

math_op_plus:
    cmp dx, 32767
    jg call_overflow
    sub dx, 96
    jo call_overflow
    
    jo call_overflow
    jmp ending

call_overflow:
    call overflow_proc
    jmp end_end

ending:

    ; mov bx, number
    mov bx, dx
    cmp bx, 0
    jl print_minus_sign_neg
    ; or bx, bx
    ; jns m1
    cmp first_char, 1
    je print_minus_sign
    jmp m1
    print_minus_sign_neg:
        mov al, '-'
        int 29h
        neg bx
        jmp m1
    print_minus_sign:
        mov al, '-'
        int 29h
        ; neg bx
    m1:
        mov ax, bx
        xor cx, cx
        mov bx, 10
    m2:
        xor dx, dx
        div bx
        add dl, '0'
        push dx
        inc cx
        test ax, ax
        jnz m2
    m3:
        pop ax
        int 29h
        loop m3

;     ; neg dx
;     ; xor ax, ax
;     ; sub ax, dx

end_end:
    RET
    MAIN ENDP

bad_input_proc:
    LEA DX, msg
    MOV AH, 9
    INT 21H
    ret

overflow_proc:
    LEA DX, msg_overflow
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
    power_proc_power:
        mul bx
        dec cl
        jne power_proc_power

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