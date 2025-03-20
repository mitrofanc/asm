bits 64
; res=(d*a)/(a+b*c)+(d+b)/(e-a)
section .data
res: 	dq	0
a:		dw	40
b: 		dw	10
c:		dd	1
d:		dd	2
e:		dd	50
section .text
global _start
_start:
	mov eax, dword[e]
	movzx ebx, word[a]
	sub eax, ebx
	jz err
	mov eax, dword[d]
	mul ebx
	mov r12d, edx ;d*a h
	mov r13d, eax ;d*a l
	movzx r14d, word[b]
	movzx eax, word[c]
	mul r14d
	mov r14d, edx ;b*c h
	mov r15d, eax ;b*c l 
	xor rdx, rdx ; todo delete
	mov edx, r14d 
	shl rdx, 32 
	xor rax, rax
	mov eax, r15d
	or rdx, rax ;b*c
	add rbx, rdx ;a+b*c
	xor rax, rax
	mov eax, r12d
	shl rax, 32
	xor rcx, rcx
	mov ecx, r13d
	or rax, rcx ;d*a 64
	xor rdx, rdx
	div rbx 
	mov r12, rax ; (d*a)/(a+b*c)
	
	xor rax, rax
	mov eax, dword[d]
	movzx r14, word[b]
	add rax, r14 ;d+b
	mov r13, rax
	mov ebx, dword[e]
	movzx r14d, word[a]
	sub  ebx, r14d ; e-a
	xor rdx, rdx
	mov rax, r13
	div r14d
	sub r12, rax
	mov [res], r12
	mov eax, 60
	mov edi, 0
	syscall
err:
	mov eax, 60
	mov edi, 1
	syscall
	
