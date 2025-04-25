bits    64

section .data

size      equ 10                    ; размер чанка для чтения
size_out  equ size*2
namelen   equ 1024                  ; максимальная длина имени файла

; Список ошибок
errlist:
    times   2   dq err255
    dq        err2
    times  10   dq err255
    dq        err13
    times   3   dq err255
    dq        err17
    times   3   dq err255
    dq        err21
    times  14   dq err255
    dq        err36
    times 113   dq err255
    dq        err150
    dq        err151
    times 154   dq err255

fdr:      dd -1                    ; дескриптор для чтения файла

msg1:     db "Input filename for read",10
msg1len   equ $-msg1

err2:     db "No such file or directory!",10
err13:    db "Permission denied!",10
err17:    db "File exists!",10
err21:    db "Is a directory!",10
err36:    db "File name too long!",10
err150:   db "Program does not require parameters!",10
err151:   db "Error reading filename!",10
err255:   db "Unknown error!",10

filename: times namelen db 0       ; имя входного файла

decbuf:   times 16     db 0        ; временный буфер для itoa

section .text
global _start

_start:
    ; Проверка на то, что нет аргументов
    cmp     qword [rsp], 1        ; argc == 1?
    je      .ask_name
    mov     ebx, 150              ; "Program does not require parameters!"
    jmp     .error_exit

.ask_name:
    ; Запрос имени файла
    mov     eax, 1                ; sys_write
    mov     edi, 1                ; stdout
    mov     rsi, msg1
    mov     edx, msg1len
    syscall

    ; Чтение имени
    xor     eax, eax              ; sys_read
    xor     edi, edi              ; stdin
    mov     rsi, filename
    mov     edx, namelen
    syscall
    or      eax, eax              ; проверка прочитанного
    jle     .err_read_name
    cmp     eax, namelen
    jl      .name_ok
.err_read_name:
    mov     ebx, 151              ; "Error reading filename!"
    jmp     .error_exit

.name_ok:
    ; Завершаем строку нулём и открываем файл
    mov     byte [filename + rax - 1], 0  ; ставим 0-байт в конце имени файла
    mov     eax, 2                ; sys_open
    mov     rdi, filename
    xor     esi, esi              ; O_RDONLY
    syscall
    or      eax, eax              ; проверка открытия файла
    jge     .opened
    mov     ebx, eax
    neg     ebx
    jmp     .error_exit

.opened:
    mov     [fdr], eax            ; сохраняем fdr
    mov     edi, [fdr]            ; передаём в work
    call    work
    mov     ebx, eax
    neg     ebx

.error_exit:
    or      ebx, ebx
    je      .close_file
    ; Вывод сообщения об ошибке
    mov     eax, 1                ; sys_write
    mov     edi, 2                ; stderr
    mov     rsi, [errlist + rbx*8]
    xor     edx, edx
.err_len:
    inc     edx
    cmp     byte [rsi + rdx - 1], 10
    jne     .err_len
    syscall

.close_file:
    ; Закрытие файла
    cmp     dword [fdr], -1
    je      .exit
    mov     eax, 3                ; sys_close
    mov     edi, [fdr]
    syscall

.exit:
    mov     edi, ebx
    mov     eax, 60               ; sys_exit
    syscall

bufin   equ size
bufout  equ size_out + bufin
fr      equ bufout + 4
l       equ fr + 4

work:
    push    rbp
    mov     rbp, rsp
    sub     rsp, l               
    push    rbx

    mov     [rbp-fr], edi         ; сохранение дескриптора
    mov     dword [rbp-l], 0      ; длина слова = 0

.read_chunk:
    xor     eax, eax              ; sys_read
    mov     edi, [rbp-fr]
    lea     rsi, [rbp-bufin]
    mov     edx, size
    syscall
    or      eax, eax
    jle     .done_work            ; EOF или ошибка

    mov     r10, rax              ; число прочитанных байт
    lea     rsi, [rbp-bufin]
    lea     rdi, [rbp-bufout]

.process:
    cmp     r10, 0                
    je      .out                  ; закончились байты, на выход

    mov     al, [rsi]             ; читаем символ
    inc     rsi                   ; продвигаемся по строке
    dec     r10                   ; уменьшаем число оставшихся байт

    cmp     al, 10                ; если \n
    je      .new_line

    mov     ebx, [rbp-l]          ; ebx = длина слова

    ; Проверка на разделители
    cmp     al, ' '
    je      .sep
    cmp     al, 9                 ; \t
    je      .sep

    ; Обычный символ
    mov     [rdi], al             ; копируем символ 
    inc     rdi                   ; продвигаем курсор
    inc     ebx                   ; длина + 1
    mov     [rbp-l], ebx          ; увеличиваем длину слова 
    jmp     .process

.new_line:
    mov     ebx, [rbp-l]          ; ebx = длина слова
    test    ebx, ebx
    jz      .empty_word

    ; Пробел перед длиной слова
    mov     byte [rdi], ' '
    inc     rdi

    ; itoa(ebx) → decbuf
    lea     r8, [decbuf]
    xor     rcx, rcx
    mov     eax, ebx
    
.c_loop_nl:
    xor     edx, edx
    mov     ebx, 10
    div     ebx                  ; edx = eax % 10
    add     dl, '0'              ; перевод в ascii
    mov     [r8], dl
    inc     r8
    inc     rcx                  ; увеличиваем количество считанных цифр 
    cmp     eax, 0
    jne     .c_loop_nl
.c_done_nl:
    dec     r8                   ; r8 на последнюю цифру
.rev_nl:
    mov     al, [r8]             ; запись числа с конца
    mov     [rdi], al
    inc     rdi
    dec     r8
    dec     rcx
    jnz     .rev_nl

    mov     dword [rbp-l], 0      ; сброс длины слова
.empty_word:
    mov     byte [rdi], 10        ; записываем \n
    inc     rdi
    jmp     .process

.sep:
    ; Конец слова
    test    ebx, ebx
    jz      .after_sep            ; если слово пустое — дальше

    ; Пробел перед длиной слова
    mov     byte [rdi], ' '
    inc     rdi

    ; itoa(ebx) → decbuf, перевод числа в символ через запись в буфер
    lea     r8, [decbuf]
    xor     rcx, rcx              ; счетчик цифр
    mov     eax, ebx              ; длина слова

.c_loop:
    xor     edx, edx
    mov     ebx, 10
    div     ebx                   ; edx = eax % 10
    add     dl, '0'               ; перевод в ascii
    mov     [r8], dl
    inc     r8
    inc     rcx                   ; увеличиваем количество считанных цифр 
    cmp     eax, 0
    jne     .c_loop
.c_done:
    dec     r8                    ; r8 на последнюю цифру
.rev:
    mov     al, [r8]              ; запись числа с конца
    mov     [rdi], al
    inc     rdi
    dec     r8
    dec     rcx
    jnz     .rev

    ; Пробел после числа
    mov     byte [rdi], ' '
    inc     rdi

    ; Сброс длины слова
    mov     dword [rbp-l], 0      ; если оборвали слово чанком, то длина остается ненулевой, и при чтении следующего чанка вначале не будет ставится пробел

.after_sep:
    cmp     al, 10
    jne     .process
    ; Если был перевод строки
    mov     byte [rdi], 10
    inc     rdi
    jmp .process

.out:
    ; Запись bufout в stdout
    lea     rsi, [rbp-bufout]
    mov     rdx, rdi
    sub     rdx, rsi              ; количество символов 
    mov     eax, 1                ; sys_write
    mov     edi, 1                ; stdout
    syscall
    jmp     .read_chunk

.done_work:
    pop rbx                   
    leave                         
    ret
