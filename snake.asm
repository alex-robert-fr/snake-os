use16
;; SETUP ------------------------
org 0x7c00
jmp setup_game
;; CONSTANTS

;; VARIABLES


;; LOGIC ------------------------
setup_game:





;; Bootsector padding
times 510 - ($-$$) db 0

dw 0x0AA55
