bits 64
global invert_colors_nasm

section .text
; void invert_colors_nasm(struct Image *img)       ; RDI = &Image
; Image {
;     int width; 0
;     int heihgt; 4
;     png_byte *r; 8
;     png_byte *g; 16
;     png_byte *b; 24
; }

invert_colors_nasm:
    push    rbx

    mov     eax, dword [rdi]        ; width
    mov     ebx, dword [rdi + 4]    ; height

    test    eax, eax
    jle     .end
    test    ebx, ebx
    jle     .end

    movsxd  rax, eax
    movsxd  rbx, ebx
    mul     rbx                     ; rcx = width * height
    mov     rcx, rax
    jrcxz   .end

    mov     rsi, [rdi + 8]          ; r
    mov     rdx, [rdi + 16]         ; g
    mov     r8 , [rdi + 24]         ; b
    test    rsi, rsi
    jz      .end
    test    rdx, rdx
    jz      .end
    test    r8 , r8
    jz      .end

.loop:
    ; r
    mov     al, [rsi]
    xor     al, 0xFF
    mov     [rsi], al

    ; g
    mov     al, [rdx]
    xor     al, 0xFF
    mov     [rdx], al

    ; b
    mov     al, [r8]
    xor     al, 0xFF
    mov     [r8], al

    inc     rsi
    inc     rdx
    inc     r8
    loop .loop

.end:
    pop     rbx
    ret
