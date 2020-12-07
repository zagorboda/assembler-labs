stseg segment para stack "stack"
	db 64 dup ("stack")
stseg ends

dseg segment para public "data"
    ten dw 10
    temp db 2
    first_result_positive db 0
    second_result_positive db 0
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

mov cx, 4

mov ax, 6486
; add ax, 100
; cmp ax, -32768
mov bx, 19

neg ax
; neg bx

or ax, ax
jns first_result_positive_label
neg ax 
jmp first_result_negative_label

; cmp ax, 0
; jge first_result_positive_label
; mov first_result_positive, 0

; check if result positive or negative
first_result_positive_label:
    or bx, bx
    jns result_is_positive_label
    neg bx 
    jmp result_is_negative_label
    ; cmp bx, 0
    ; jge result_is_positive_label
    ; jmp result_is_negative_label

first_result_negative_label:
    or bx, bx
    jns result_is_negative_label
    neg bx
    jmp result_is_positive_label
    ; cmp bx, 0
    ; jge result_is_negative_label
    ; jmp result_is_positive_label

result_is_positive_label:
    mov result_is_positive, 1
    jmp math_label

result_is_negative_label:
    mov result_is_positive, 0


math_label:

xor dx,dx 
div bx

; mov temp, 3

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
    mov ax, dx ; остача з dx в ax
    ; mov cx, 10 
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



RET
MAIN ENDP

print_digit_proc:
    mov dl, temp
    add dl, '0'
    mov ah, 2
    int 21h
    ; MOV ah, 1
    ; INT 21H
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

cseg ends
end main