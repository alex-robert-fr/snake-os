use16
;; SETUP ------------------------
org 0x7c00
jmp setup_game
;; CONSTANTS
VIDMEM      equ 0x0B800
SCREENW     equ 80
SCREENH     equ 25
WINCOND     equ 10
BGCOLOR     equ 0x1020
APPLECOLOR  equ 0x4020
SNAKECOLOR  equ 0x2020
TIMER			  equ 0x046C ;; Clock in BIOS
SNAKEXARRAY equ 0x1000
SNAKEYARRAY equ 0x2000

;; VARIABLES
playerX: dw 40
playerY: dw 12
appleX:  dw 16
appleY:  dw 8
direction: db 4
snakeLength: dw 1

;; LOGIC ------------------------
setup_game:
	;; Set video mode - VGA mode 0x03 (80x25 text mode, 16 colors)
	mov ax, 0x0003
	int 0x10





;; Bootsector padding
times 510 - ($-$$) db 0

dw 0x0AA55
