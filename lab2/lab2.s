bits 64

section .data
rows:	dd 4
columns:dd 8         
matrix: db 8, 7, 121, -9, 126, 123, 4, -120  
		db 100, 110, -3, 1, 9, -99, 90, 111
		db 121, 0, -99, 80, -23, 0, 56, 70
		db -1, -22, -100, -50, -99, -9, -2, -80

section .text
global _start

_start:
	mov rbx, matrix
	mov r14d, [rows]
	mov r15d, 0			; текущая строка 

row_loop:
	cmp r15d, r14d		; текущая строка >= число строк
	jae end

	mov r11d, [columns]
	mov r8d, r11d		; gap (изначально = числу элементов)
	mov r9d, 1 			; swapped 
	
comb_sort_loop:
    ; пересчитываем gap, если он больше 1
    cmp r8d, 1
    jle .gap_update_skip
    mov eax, r8d
    imul eax, 10 
    xor edx, edx
    mov r10d, 13         ; eax = gap * 10
    div r10d             ; eax = (gap * 10) / 13
    cmp eax, 1
    jge .set_gap_new
    mov eax, 1
.set_gap_new:
    mov r8d, eax
.gap_update_skip:
    ; swapped = 0 (пока не произошло перестановки)
    xor r9d, r9d

    ; внутренний цикл: сравниваем элементы, отстоящие на gap друг от друга
    mov ecx, r11d         ; ecx = columns
    sub ecx, r8d          ; ecx = columns - gap (количество сравнений для данного gap)
    mov rdi, 0            ; rdi = i = 0

.inner_loop:
    cmp rdi, rcx
    jge .comb_loop_end

    ; адрес элемента (i + gap)
    mov r10, rdi
    add r10d, r8d         ; r10d = i + gap

    ; загружаем значения в r12b и r13b
    mov rax, rdi
    mov r12b, [rbx + rax]   ; r12b = mas[i]
    mov r13b, [rbx + r10]   ; r13b = mas[i + gap]

    ; сравниваем r12b и r13b
    cmp r12b, r13b
    %if ASC=0	
    	jle .no_swap
    %else
		jge .no_swap
	%endif
    
    ; если нужно, меняем их местами
    mov [rbx + rax], r13b
    mov [rbx + r10], r12b
    mov r9d, 1              ; swapped = 1
.no_swap:
    inc rdi
    jmp .inner_loop

.comb_loop_end:
    ; продолжаем, если gap > 1 или если были обмены
    cmp r8d, 1
    jg comb_sort_loop
    cmp r9d, 1
    je comb_sort_loop

    add rbx, r11		; сдвиг строки на следующую
    inc r15d
    jmp row_loop

end:
    mov eax, 60         
    xor edi, edi
    syscall
