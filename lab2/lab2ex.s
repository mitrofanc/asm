bits 64

section .data

rows: db 2

columns: db 5

matrix: 
    dq 9, 6, 4, -2, -33
    dq 7, 3, 4, -44, -65


section .text
global _start
_start:
    mov cl, [columns]
    cmp cl, 1
    mov r12b, [rows] 
    inc r12b
    mov r10b, 1 ; m
    mov rbx, matrix
    movzx r11, cl
    shl r11, 3

init:
    mov al, 1
    mov r8b, 2
m1:
	cmp cl, al
    jbe m4
    mov rdx, [rbx + rax * 8] ;  rbx = matrix[0][1]

%ifndef ASCED
    cmp [rbx + rax * 8 - 8], rdx ; if rdx > matrix[0][0] возрастание
    jl m2
%else
    cmp rdx, [rbx + rax * 8 - 8] ; if rdx < matrix[0][0] убывание
    jl m2
%endif


    mov al, r8b ; i = j 
    inc r8b ; ++j
    jmp m1
m2:
    push rdx
    mov rdx, [rbx + rax * 8 - 8]
    pop r9
    mov [rbx + rax * 8 - 8], r9
    mov [rbx + rax * 8], rdx 
    dec al
    cmp al, 0
    je m3
    jmp m1
m3:
    mov al, r8b
    inc r8b  
    jmp m1
m4:
	inc r10b
	cmp r12b, r10b
	je exit
    add rbx, r11
    jmp init

exit:
    mov eax, 60
    xor edi, 1 ;mov edi, 0
    syscall