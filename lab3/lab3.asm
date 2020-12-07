;24
stseg segment para stack "stack"
	db 64 dup ("stack")
stseg ends

dseg segment para public "data"
	input_message db "Input number (from -32768 up to 32767): $"
	msg_overflow db "Overflow. Try another value$"
    output_message db "Result = $"
	dump db 7, ?, 7 dup('?')
	first_char db 0
	number dw 1	
	x dw 1	
	l db 0
	msg db "Bad input$"
	nominator dw ?
	denominator dw ?
    ten dw 10
    temp db 2
    result_is_positive db 0
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
    je check_x_value

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

	mov dl, 10 ; print newline
	mov ah, 02h
	int 21h

	mov dl, 13
	mov ah, 02h
	int 21h ;---

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
	jmp check_x_value
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

bad_input_label:
    call bad_input_proc
    jmp ending

call_overflow:
    call overflow_proc
    jmp ending



check_x_value:
	mov x, bx
	; xor bx, bx
	; mov bx, x

    cmp first_char, 1
    je x_le_0

	cmp x, 4
	jg x_greater_4

    cmp x, 2
    jge x_ge_2__x_le_4

	jmp x_le_0


x_greater_4:
	mov ax, x
	mov bx, x
	mul bx
    jo call_overflow
	mul bx
    jo call_overflow
	sub ax, 1
    jo call_overflow

	mov nominator, ax

	mov ax, x
	mov bx, x
	mul bx
    jo call_overflow
	add ax, 1
    jo call_overflow

	mov denominator, ax

    mov ax, nominator
    mov bx, denominator

    call divide_2_numbers_proc

    jmp ending

x_ge_2__x_le_4:
	mov ax, x
	mov bx, x
	mul bx
    jo call_overflow
	sub ax, 1
    jo call_overflow

	mov nominator, ax

	mov ax, x
	mov bx, 2
	mul bx
    jo call_overflow
	add ax, 5
    jo call_overflow

	mov denominator, ax

    mov ax, nominator
    mov bx, denominator

    call divide_2_numbers_proc

    jmp ending

x_g_0__x_l_2:
	mov ax, x
	mov bx, x
	mul bx
    jo call_overflow
    mov bx, 4
	mul bx
    jo call_overflow

	mov nominator, ax

	mov ax, x
	add ax, 1
    jo call_overflow

	mov denominator, ax

    mov ax, nominator
    mov bx, denominator

    call divide_2_numbers_proc

    jmp ending

x_le_0:
	mov ax, x
    neg ax
    add ax, 3

	mov nominator, ax

	mov denominator, 1

    mov ax, nominator
    mov bx, denominator

    call divide_2_numbers_proc

    jmp ending

; print_loop:
; 	mov bx, nominator
;     ; or bx, bx
;     ; jns m1
;     ; mov al, '-'
;     ; neg bx
;     ; int 29h
;     m1:
;         mov ax, bx
;         xor cx, cx
;         mov bx, 10
;     m2:
;         xor dx, dx
;         div bx
;         add dl, '0'
;         push dx
;         inc cx
;         test ax, ax
;         jnz m2
;     m3:
;         pop ax
;         int 29h
;         loop m3
;         ret


    ; mov dx, nominator

    ; ; lea dx, dump
    ; ; mov ah, 9
    ; ; int 21h

    ; lea dx, output_message
    ; mov ah, 9
    ; int 21h

    ; cmp bx, 0
    ; jl print_minus_sign_neg
    ; cmp first_char, 1
    ; je print_minus_sign
    ; jmp m1
    ; print_minus_sign_neg:
    ;     mov al, '-'
    ;     int 29h
    ;     neg bx
    ;     jmp m1
    ; print_minus_sign:
    ;     mov al, '-'
    ;     int 29h
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

ending:
    RET
    MAIN ENDP

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

print_number_proc:
    mov bx, ax
    ; or bx, bx
    ; jns m1
    ; mov al, '-'
    ; int 29h
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
        ret

print_digit_proc:
    mov dl, temp
    add dl, '0'
    mov ah, 2
    int 21h
    ; MOV ah, 1
    ; INT 21H
    ret

overflow_proc:
    lea dx, msg_overflow
    mov ah, 9
    int 21H
    ret

bad_input_proc:
    lea dx, msg
    mov ah, 9
    int 21H
    ret

divide_2_numbers_proc:
    mov cx, 5
    or ax, ax
    jns first_result_positive_label
    neg ax 
    jmp first_result_negative_label

    ; check if result positive or negative, convert negative number to positive
    first_result_positive_label:
        or bx, bx
        jns result_is_positive_label
        neg bx 
        jmp result_is_negative_label

    first_result_negative_label:
        or bx, bx
        jns result_is_negative_label
        neg bx
        jmp result_is_positive_label

    result_is_positive_label:
        mov result_is_positive, 1
        jmp math_label

    result_is_negative_label:
        mov result_is_positive, 0
        push ax
        mov al, '-'
        int 29h
        pop ax


    math_label:

    xor dx,dx
    div bx ; значення в ax дылиться на значення в bx

    push ax
    push bx
    push cx
    push dx
    call print_number_proc
    mov al, '.'
    int 29h
    pop dx
    pop cx
    pop bx
    pop ax

    divide_loop:
        mov ax, dx ; перемыщуем остачу з dx в ax
        mul ten ; множим остачу на 10
        xor dx,dx 
        div bx ; дылим отримане число на потрыбне

        mov temp, al

        push ax
        push dx
        call print_digit_proc
        pop dx
        pop ax

        dec cx
        jne divide_loop
    ret

cseg ends
end main