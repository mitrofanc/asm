bits 64
section .data
    usage_msg   db "Usage: program_name output_filename", 10, 0 
    error_open  db "Error opening output file", 10, 0

    prompt_x    db "Enter value for x: ", 0
    prompt_acc  db "Enter accuracy: ", 0
    prompt_stfunc db "Calculating by C func:", 0
    prompt_taylor db "Calculating by Taylor:", 0

    fmt_answer  db "%s %f", 10, 0
    fmt_scan    db "%f", 0        
    fmt_write   db "%f", 10, 0    
    fmt_file    db "%d %f", 10, 0
    mode_w      db "w", 0         

section .bss
    file_name     resb 256        
    x             resd 1          
    accuracy      resd 1          
    result_sinh   resq 1          
    prev_sum      resd 1          
    term          resd 1          

section .text
    global main
    extern  printf, scanf, strcpy
    extern  fopen, fprintf, fclose
    extern  exit
    extern  sinhf, fabsf

main:
    sub     rsp, 8
    mov     rax, rdi        ; rdi == argc
    cmp     rax, 2          ; проверка, что 2 аргумента 
    jne     .usage

    ;    rsi == argv (указатель на массив указателей)
    lea     rdi, [rel file_name] ; destination
    mov     rsi, [rsi + 8]  ; rsi = argv[1] (source)
    call    strcpy               ; strcpy(argv[1], file_name)

    lea     rdi, [rel prompt_x]
    xor     eax, eax        
    call    printf          ; printf(prompt_x)

    lea     rdi, [rel fmt_scan]  ; %f 
    lea     rsi, [rel x]     
    xor     eax, eax
    call    scanf                ; scanf("%f", x)

    lea     rdi, [rel prompt_acc]
    xor     eax, eax
    call    printf               ; printf(prompt_acc)

    lea     rdi, [rel fmt_scan]
    lea     rsi, [rel accuracy]
    xor     eax, eax
    call    scanf                ; scanf("%f", accuracy)

    
    lea     rdi, [rel file_name]
    lea     rsi, [rel mode_w]
    call    fopen
    test    rax, rax
    jne     .file_ok

    ; не удалось открыть
    lea     rdi, [rel error_open]
    xor     eax, eax
    call    printf               ; printf(error_open)
    mov     rdi, 1
    call    exit

.file_ok:
    mov     rbx, rax        ; rbx = FILE*
    
    ; 1 способ: sinhf(x)
    movss   xmm0, [rel x]   
    call    sinhf           
    movss   [rel result_sinh], xmm0

    lea     rdi, [rel fmt_answer]    ; формат "%s %f\n"
    lea     rsi, [rel prompt_stfunc]
    movss   xmm0, [rel result_sinh]  ; загружаем float результат
    cvtss2sd xmm0, xmm0              ; float->double              
    mov     rax, 1
    call    printf                   ; printf("%s %f\n", prompt_str, result)

    ; 2 сопосб: ряд Тейлора
    ;    sinh(x) = sum( x^(2n+1)/(2n+1)!)
    ;    a_(n+1) = a_n * x^2 / ((2n+2)(2n+3))

    ; инициализация
    movss   xmm0, [rel x]       ; первый член ряда = x
    movss   [rel term], xmm0
    movss   [rel prev_sum], xmm0

    ; записываем первое приближение (n=0)
    mov     rdi, rbx
    lea     rsi, [rel fmt_file]
    mov     rdx, 0
    movss   xmm0, [rel prev_sum]
    cvtss2sd xmm0, xmm0
    mov     rax, 1
    call    fprintf

    xor     r12, r12          ; n = 0

.loop:
    ; term *= x^2 
    movss   xmm1, [rel term]
    movss   xmm2, [rel x]
    mulss   xmm1, xmm2
    mulss   xmm1, xmm2

    ; denom = (2n+2)*(2n+3)
    mov     r13, r12     ; r13 = n
    shl     r13, 1       ; r13 = 2n
    add     r13, 2       ; r13 = 2n + 2
    cvtsi2ss xmm3, r13   ; int->float

    mov     r14, r12     ; r14 = n
    shl     r14, 1       ; r14 = 2n
    add     r14, 3       ; r14 = 2n + 3 
    cvtsi2ss xmm4, r14   ; int->float  

    mulss   xmm3, xmm4   ; denom = r13 * r14

    ; term = xmm1 / denom
    divss   xmm1, xmm3
    movss   [rel term], xmm1 

    ; sum = prev_sum + term 
    movss   xmm5, [rel prev_sum]
    addss   xmm5, xmm1       ; xmm5 = prev_sum + term = sum

    ; diff = |sum - prev_sum|
    movss   xmm0, xmm5
    subss   xmm0, [rel prev_sum]
    call    fabsf            ; float в xmm0

    ; сравниваем diff и accuracy
    ucomiss xmm0, [rel accuracy]
    ja      .continue   ; если diff > accuracy

    ; else: последнее приближение
    lea     rdi, [rel fmt_answer]    ; формат "%s %f\n"
    lea     rsi, [rel prompt_taylor]
    movss   xmm0, xmm5               ; загружаем float результат
    cvtss2sd xmm0, xmm0              ; float->double              
    mov     rax, 1
    call    printf                   ; printf("%s %f\n", prompt_str, result)
    jmp     .cleanup

.continue:
    ; печатаем текущее приближение
    inc     r12              ; корректировка n
    mov     rdi, rbx
    lea     rsi, [rel fmt_file]
    mov     rdx, r12
    movss   xmm0, [rel term]
    cvtss2sd xmm0, xmm0
    mov     rax, 1
    call    fprintf

    ; готовим к следующей итерации
    movss   [rel prev_sum], xmm5
    ;inc     r12
    jmp     .loop

.cleanup:
    ; закрываем файл и выходим
    mov     rdi, rbx
    call    fclose

    mov     rdi, 0
    call    exit

.usage:
    ; подсказка по использованию
    lea     rdi, [rel usage_msg]  ; str
    xor     eax, eax              ; args = 0
    call    printf
    mov     rdi, 1
    call    exit
