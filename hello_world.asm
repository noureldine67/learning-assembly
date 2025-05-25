BITS 64

global _start ; Point d’entrée du programme (équivalent à main() en C)

section .text
_start:
  ; write(STDOUT_FILENO, msg, msglen)
  mov rax, 0x1        ; syscall numéro 1 = sys_write
  mov rdi, 0x1        ; 1er argument : descripteur de fichier (1 = stdout)
  mov rsi, msg        ; 2e argument : adresse du message à écrire
  mov rdx, msglen     ; 3e argument : longueur du message
  syscall             ; Appel système (write)

  ; exit(EXIT_SUCCESS)
  mov rax, 0x3C       ; syscall numéro 60 = sys_exit
  mov rdi, 0          ; Code de retour (0 = succès)
  syscall             ; Appel système (exit)


section .rodata
  msg: db "Hello, World!", 10   ; Chaîne "Hello, World!" suivie d’un saut de ligne (\n)
  msglen: equ $ - msg           ; Taille de la chaîne (calculée à l’assemblage)
                                ; $ = adresse courante → msglen = 14 octets ici
