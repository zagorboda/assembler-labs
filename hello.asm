.Model Small
.STACK

.DATA
	MSG1 DB "hello$"
	MSG2 DB "world!$"
.CODE
	MOV AX,@DATA
	MOV DS,AX

	mov ah,09h

	mov dx,offset MSG1
	int 21h

	mov dl,10
	mov ah,02h
	int 21h
	mov dl,13
	mov ah,02h
	int 21h
	
	mov ah,09h
	mov dx,offset MSG2
	int 21h

	mov ah,4ch
	mov al,00
	int 21h

END