BITS 64                       ; Architecture 64 bits

; =========================
; Définition des constantes
; =========================

%define AF_UNIX 0x1           ; Domaine Unix pour les sockets
%define SOCK_STREAM 0x1       ; Type de socket orienté connexion (flux)

%define SYSCALL_SOCKET 0x29   ; Appel système socket (numéro 41)
%define SYSCALL_CONNECT 0x2A  ; Appel système connect (numéro 42)
%define SYSCALL_EXIT 0x3C     ; Appel système exit (numéro 60)

%define EXIT_SUCCESS 0x0      ; Code retour succès
%define EXIT_FAILURE 0x1      ; Code retour échec

%define SIZEOF_STRUCT_ADDR_UN 0x6E ; Taille structure sockaddr_un (110 octets)

section .text                 ; Section code exécutable

global _start                 ; Point d'entrée du programme

; =====================
; Fonction de terminaison
; =====================
die:
    mov     rax, SYSCALL_EXIT ; Prépare l'appel système exit
    mov     rdi, EXIT_FAILURE ; Code retour échec (1)
    syscall                   ; Appel système : quitte le programme

; ======================================
; Connexion à un socket Unix (serveur X11)
; ======================================
unix_socket_connect_to_X11_server:
    push    rbp               ; Sauvegarde base de pile précédente
    mov     rbp, rsp          ; Nouvelle base de pile = pile courante

    ; Création du socket
    mov     rax, SYSCALL_SOCKET  ; Appel système socket
    mov     rdi, AF_UNIX          ; Domaine Unix
    mov     rsi, SOCK_STREAM      ; Type socket : flux (connecté)
    mov     rdx, 0x0              ; Protocole automatique
    syscall                      ; Exécution appel système

    test    rax, rax              ; Test si rax < 0 (erreur)
    js      die                   ; Saut vers die si erreur (récupération négative)

    mov     rdi, rax              ; Stocke le descripteur de socket dans rdi

    ; Allocation de la structure sockaddr_un sur la pile (+2 octets)
    sub     rsp, SIZEOF_STRUCT_ADDR_UN + 0x2

    mov     WORD [rsp], AF_UNIX   ; sun_family = AF_UNIX (2 octets)

    lea     rsi, [rel sun_path]   ; rsi pointe vers la chaîne "/tmp/.X11-unix/X0"
    mov     r12, rdi              ; Sauvegarde du descripteur de socket dans r12
    lea     rdi, [rsp + 2]        ; rdi pointe vers sun_path dans sockaddr_un (juste après sun_family)

    cld                          ; Direction forward pour movsb
    mov     ecx, sun_path_len     ; Nombre d'octets à copier (longueur du chemin)
    rep     movsb                 ; Copie byte par byte du chemin dans sockaddr_un.sun_path

    ; Appel système connect
    mov     rax, SYSCALL_CONNECT  ; Prépare appel système connect
    mov     rdi, r12              ; rdi = fd socket sauvegardé
    lea     rsi, [rsp]            ; rsi = pointeur sur sockaddr_un (structure complète)
    mov     rdx, SIZEOF_STRUCT_ADDR_UN ; Taille de la structure sockaddr_un
    syscall                      ; Exécution connect

    test    rax, rax             ; Test si erreur (rax < 0)
    js      die                  ; Saut vers die si erreur

    ; Libération de la mémoire allouée sur la pile
    add     rsp, SIZEOF_STRUCT_ADDR_UN + 0x2

    pop     rbp                  ; Restauration base de pile précédente
    ret                         ; Retour vers l'appelant

; ===============
; Point d'entrée
; ===============
_start:
    call unix_socket_connect_to_X11_server ; Appelle la fonction de connexion au serveur X11

    ; Quitter proprement avec succès
    mov     rax, SYSCALL_EXIT
    mov     rdi, EXIT_SUCCESS
    syscall

; ===============
; Données en lecture seule
; ===============
section .rodata
sun_path:       db "/tmp/.X11-unix/X0", 0 ; Chemin du socket X11 (terminé par un octet nul)
sun_path_len:   equ $ - sun_path           ; Calcul automatique de la longueur de la chaîne

