BITS 64

; ==========================
; Définition des constantes
; ==========================
%define SYSCALL_WRITE 0x1     ; syscall write
%define STDOUT        0x1     ; fichier de sortie = stdout
%define SYSCALL_EXIT  0x3C    ; syscall exit (60 décimal)

global _start

section .text

print_loop:
    xor r12, r12              ; i = 0

.loop:
    cmp r12, 0xA              ; tant que i < 10
    je .done                  ; si i == 10, sortir de la boucle

    mov rax, r12              ; rax = i
    add al, '0'               ; convertir chiffre → caractère ASCII
    mov [output], al          ; écrire le caractère dans le output

    ; write(1, output, 2)
    mov rax, SYSCALL_WRITE    ; syscall write
    mov rdi, STDOUT           ; STDOUT = 1
    mov rsi, output           ; adresse du output
    mov rdx, 2                ; longueur à écrire
    syscall

    inc r12                   ; i++
    jmp .loop                 ; recommencer

.done:
    ret

_start:
    call print_loop

    ; Sortie du programme : exit(0)
    mov rax, SYSCALL_EXIT
    xor rdi, rdi
    syscall

; ========================
; Sections mémoire
; ========================

section .data
output: db "0", 0xA
output_len : equ $ - output


