bits 64
; res=(d*a)/(a+b*c)+(d+b)/(e-a)
section .data
res: 	dq	0
a:		dw	65532
b: 		dw	65535
c:		dd	4294967291
d:		dd	4294967292
e:		dd	4294967295
section .text
global _start
_start:

	; check denominator
	mov eax, dword[e]
	movzx ebx, word[a]
	sub eax, ebx
	jc err
	jz err

	; d*a
	mov eax, dword[d]
	mul ebx 
	mov r12d, edx ;d*a h
	mov r13d, eax ;d*a l

	; b*c
	movzx r14d, word[b]
	mov eax, dword[c] ; было movzx
	mul r14d
	mov r14d, edx ;b*c h
	mov r15d, eax ;b*c l 

	; moving b*c to the one register
	mov edx, r14d 
	shl rdx, 32 
	mov eax, r15d
	or rdx, rax ;b*c

	; a+b*c
	add rbx, rdx ;a+b*c
	jc err ; del

	; (d*a)/(a+b*c)
	mov eax, r12d
	shl rax, 32
	xor rcx, rcx
	mov ecx, r13d
	or rax, rcx ;d*a 64
	cqo ; ch
	div rbx 
	mov r12, rax ; (d*a)/(a+b*c)

	; d+b
	mov eax, dword[d]
	movzx r14, word[b]
	add rax, r14 ;d+b
	jc err
	mov r13, rax

	; e-a
	mov ebx, dword[e]
	movzx r14d, word[a]
	sub ebx, r14d ; e-a
	jc err
	mov r14, rbx

	; (d+b)/(e-a)
	mov rax, r13 ; d+b
	cqo
	div r14 ; ch
	add rax, r12
	jc err
	mov [res], rax
	mov eax, 60
	mov edi, 0
	syscall
err:
	mov eax, 60
	mov edi, 1
	syscall
