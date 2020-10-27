; 24 : -96
stseg segment para stack "stack"
	db 64 dup ("stack")
stseg ends

dseg segment para public "data"
    input_message db "Input number (from -32768 up to 32767, max 5 chars): $"
    l db 0
    dump db 7, ?, 7 dup('?')
	first_char db 0
	msg db "Bad input$"
    msg_overflow db "Overflow. Try another value$"
    output_message db "Result = $"
    number dw 1
dseg ends

cseg segment para public "code"
.386
main proc far
assume cs:cseg,ds:dseg,ss:stseg

push ds
mov ax,0
push ax
mov ax,dseg
mov DS,ax

; checking overwlof
; mov dx, 6500
; ; add dx, 6500
; ; jc ending
; ; neg dx
; add dx, 1
; jc ending
; sub dx, 1
; cmp dx, 32767
; jo ending

lea dx, input_message
mov ah, 9
int 21h

lea dx, dump
mov ah, 10
int 21h

mov al, 13
int 29h
mov al, 10
int 29h

lea di, dump
inc di
mov dl, [di]

mov l, dl

xor cx, cx
mov cl, l

lea   di, dump
mov   cl, l   ; having the assembler generate this 
    ;constant from the length of the string prevents bugs 
    ;if you change the string

check_first_char:
	inc di
	inc di
    mov dl, [di]

	cmp dl, 0
    je print_loop

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

    mov first_char, 1
    jmp check_loop
first_char_plus:
    inc di
    dec cl

    mov first_char, 2
    jmp check_loop

check_loop:
    mov dl, [di]
    cmp dl, '0'
    jl bad_input_label
    cmp dl, '9'
    jg bad_input_label

    inc di
    dec cl
    jne check_loop

	mov dl, 10
	mov ah, 02h
	int 21h
	mov dl, 13
	mov ah, 02h
	int 21h

    mov cl, l
    lea di, dump
	inc di
	inc di
    xor ax,ax
    xor bx,bx
    xor dx,dx

    cmp first_char, 0
    jg first_char_inc
    jmp convert_loop

first_char_inc:
    inc di
    dec cx 

convert_loop:
    mov dl, byte ptr [di]
    sub dx, '0'

    push cx
    push dx
    push bx
    call power_proc
    pop bx
    pop dx
    pop cx
    
    mul dx
    ; jc call_overflow
    jo call_overflow

    add bx, ax
    ; jc call_overflow

    ; add bx, 1
    ; jc call_overflow
    ; sub bx, 1
    cmp bx, 32767
    jo call_overflow

    ; cmp dx, 32767
    ; jg call_overflow

    ; mov bx, ax
    ; jo call_overflow
    ; xor bx, bx
    ; jo call_overflow
    ; jc call_overflow
    
    inc di
    dec cx
    jne convert_loop

    mov number, bx
    ; xor dx, dx
    ; mov dx, number

    ; cmp dx, 32767
    ; jo call_overflow

    ; add dx, 32767
    ; jc call_overflow
    ; sub dx, 32767

    ; jc call_overflow
    ; add dx, 32767
    ; jnc first_char_definition
    ; sub dx, 32767
    ; jmp call_overflow
    ; jo call_overflow

first_char_definition:
    cmp first_char, 1
    je math_op_minus
    cmp first_char, 2
    je math_op_plus
    cmp first_char, 0
    je math_op_plus
    jmp print_loop

bad_input_label:
    call bad_input_proc
    jmp ending

math_op_minus:
    neg bx
    sub bx, 96
    jo call_overflow
    jmp print_loop

math_op_plus:
    ; cmp bx, 32767
    ; jo call_overflow
    sub bx, 96
    jo call_overflow
    
    ; jo call_overflow
    jmp print_loop

call_overflow:
    call overflow_proc
    jmp ending

print_loop:
    mov dx, bx

    ; lea dx, dump
    ; mov ah, 9
    ; int 21h

    lea dx, output_message
    mov ah, 9
    int 21h

    cmp bx, 0
    jl print_minus_sign_neg
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

ending:
    RET
    MAIN ENDP

bad_input_proc:
    lea dx, msg
    mov ah, 9
    int 21H
    ret

overflow_proc:
    lea dx, msg_overflow
    mov ah, 9
    int 21H
    ret

power_proc:
    xor bx, bx
    mov bx, 10
    xor ax, ax
    mov ax, 1
    
    dec cx
    je power_proc_print_loop
    power_proc_power:
        mul bx
        dec cl
        jne power_proc_power

    power_proc_print_loop:
        ret

cseg ends
end main