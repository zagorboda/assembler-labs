stseg segment para stack "stack"
	db 64 dup ("stack")
stseg ends


dseg segment para public "data"
	number dw 0
    array dw 10 dup("?")
    count dw ?
    iter dw 0
    change_elem dw 0
    first_elem_positive db 0
    second_elem_positive db 0

    input_arr_size db "Enter array size (from 1 up to 10): $"
    input_number_prompt db "Enter numbers from -32767 to 32767 $"
    input_number db "Enter number $"
	msg_overflow db "Overflow$"
    error db 0
    invalid_array_size db 'Invalid array size, must be in range from 1 to 10.$'
    msg_bad db "Bad input$"
    output_message db "Result = $"
	dump db 7, ?, 7 dup('?')
	first_char db 0	
	x dw 1	
	l db 0
    index dw 0

    sum dw 0

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

lea dx, input_arr_size
mov ah, 9
int 21H

call read_int_proc
cmp error, 1 ; check for invalid input (if put after next lines will print several error messages)
je ending

cmp number, 0 ; array max size
jle invalid_array_size_main

cmp number, 10
jg invalid_array_size_main


mov count, bx
mov cx, count

mov si,0 

lea dx, input_number_prompt
mov ah, 9
int 21H

mov dl, 10 ; print newline
mov ah, 02h
int 21h

mov dl, 13
mov ah, 02h
int 21h ;---

read_array:
    lea dx, input_number
    mov ah, 9
    int 21H

    push cx

    xor bx, bx ; print element index
    mov bx, si
    sub bx, count
    add bx, cx
    inc bx
    mov number, bx
    call print_int_proc

    mov al, ' '
    int 29h
    mov al, ':'
    int 29h
    mov al, ' '
    int 29h

    call read_int_proc
    pop cx
    cmp error, 1
    je ending
    mov array[si], bx

    add si, 2
    loop read_array

mov si, 0
xor ax, ax
xor dx, dx
mov cx, count
sum_of_array:
    mov ax, array[si]

    add sum, ax
    add dx, ax
    jo call_overflow_main

    add si, 2

    loop sum_of_array       ; } while(--cx);

    ; xor dx, dx
    ; mov cx,count      
    ; dec cx               ; outer loop iteration count
    ; mov si, 0
    mov number, dx
    call print_int
    jmp ending

; nextcomp_sum:

;     mov ax, array[si]

;     add sum, ax
;     add dx, ax

;     add si, 2

;     loop nextcomp_sum       ; } while(--cx);



; mov number, dx
; call print_int
; jmp ending

call_overflow_main:
    call overflow_proc
    jmp ending

invalid_array_size_main:
    lea dx, invalid_array_size
    mov ah, 9
    int 21H
    jmp ending

; array_size_less:
;     lea dx, invalid_array_size
;     mov ah, 9
;     int 21H
;     jmp ending

ending:
    RET
    MAIN ENDP


read_int_proc:

    ; lea dx, input_message
    ; mov ah, 9
    ; int 21h

    xor ax, ax
    xor bx, bx
    xor cx, cx
    xor dx, dx

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
        je check_loop

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
        jo call_overflow

        add bx, ax
        jo call_overflow

        cmp bx, 32767
        jo call_overflow
        
        inc di
        dec cx
        jne convert_loop

        cmp first_char, 1
        je neg_bx
        jmp ending_read_int
        neg_bx:
            neg bx

        mov number, bx
        jmp ending_read_int

    bad_input_label:
        call bad_input_proc
        jmp ending_read_int

    call_overflow:
        call overflow_proc
        jmp ending_read_int

    ending_read_int:
        mov number, bx
        mov first_char, 0
        ret


print_array_proc:
        mov cl,l
        mov si,0
    print:
        ; xor ax, ax
        mov iter, cx
        mov bx, array[si]
        or bx, bx
        jns m1
        mov al, '-'
        int 29h
        neg bx
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
            ; ret
        ; Mov ax,array[si]  
        ; Add al,30h
        ; Mov ah,0eh
        ; Int  10h 
        ; MOV AH,2
        ; xor dx, dx
        mov ax, ' '
        INT 29H
        mov cx, iter
        add si, 2
        Loop print


print_int_proc:
    print_int:
        ; xor ax, ax
        mov bx, number
        or bx, bx
        jns m1_int
        mov al, '-'
        int 29h
        neg bx
        m1_int:
            mov ax, bx
            xor cx, cx
            mov bx, 10
        m2_int:
            xor dx, dx
            div bx
            add dl, '0'
            push dx
            inc cx
            test ax, ax
            jnz m2_int
        m3_int:
            pop ax
            int 29h
            loop m3_int
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


overflow_proc:
    mov error, 1
    lea dx, msg_overflow
    mov ah, 9
    int 21H
    ret

bad_input_proc:
    mov error, 1
    lea dx, msg_bad
    mov ah, 9
    int 21H
    ret


cseg ends
end main