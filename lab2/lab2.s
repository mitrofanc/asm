bits 64

section .data
n:   dd 8                 ; Количество 8-битных элементов
mas: db 8, 7, 1, 9, 6, 0, 4, 3  ; 8 элементов по 1 байту

section .text
global _start

_start:
    mov rbx, mas          ; rbx указывает на начало массива
    mov r11d, [n]         ; r11d = число элементов (n)
    mov r8d, r11d         ; r8d = gap (изначально равен n)
    mov r9d, 1            ; r9d = swapped, ставим 1, чтобы гарантировать вход в цикл

comb_sort_loop:
    ; Пересчитываем gap, если он больше 1
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
    ; Ставим swapped = 0 (пока не произошло обмена)
    xor r9d, r9d

    ; Внутренний цикл: сравниваем элементы, отстоящие на gap
    mov ecx, r11d         ; ecx = n
    sub ecx, r8d          ; ecx = n - gap
    mov rdi, 0            ; rdi = i = 0

.inner_loop:
    cmp rdi, rcx
    jge .comb_loop_end

    ; Адрес элемента (i + gap) считаем через промежуточный регистр
    mov r10, rdi
    add r10d, r8d         ; r10d = i + gap

    ; Загружаем байты в dl и bl
    ; В 64-битной адресации нельзя одновременно использовать rdi*scale + r8*scale
    ; поэтому делаем сложение в r10d, а затем обращаемся к [rbx + r10].
    mov rax, rdi
    mov r12b, [rbx + rax]   ; dl = mas[i]
    mov r13b, [rbx + r10]   ; bl = mas[i + gap]
    ;mov r12b, [rbx + rdi]
    ;mov r13b, [rbx + rdi + r8d]

    ; Сравниваем r12b и r13b
    cmp r12b, r13b
    jle .no_swap
    ; Если dl > bl, меняем их местами
    mov [rbx + rax], r13b
    mov [rbx + r10], r12b
    mov r9d, 1            ; swapped = 1
.no_swap:
    inc rdi
    jmp .inner_loop

.comb_loop_end:
    ; Продолжаем, если gap > 1 или если были обмены
    cmp r8d, 1
    jg comb_sort_loop
    cmp r9d, 1
    je comb_sort_loop

    ; Выходим из программы
    mov eax, 60           ; sys_exit
    xor edi, edi
    syscall