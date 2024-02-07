use16
;; SETUP ------------------------
org 0x7c00
jmp setup_game
;; CONSTANTS
VIDMEM      equ 0x0B800
SCREENW     equ 80
SCREENH     equ 25
WINCOND     equ 10
BGCOLOR     equ 0x1020 ; 0x01 ; 0 = BG ; 1 = FG
APPLECOLOR  equ 0x4020
SNAKECOLOR  equ 0x2020
TIMER			  equ 0x046C ; Clock in BIOS
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
	
	;; Set up video memory
	mov ax, VIDMEM
	mov es, ax			; ES:DI <- video memory (0B800:0000 or B8000)

	;; Set 1st snake segment "head"
	mov ax, [playerX]
	mov word [SNAKEXARRAY], ax
	mov ax, [playerY]
	mov word [SNAKEYARRAY], ax

;; Game loop
game_loop:
	;; Clear screen every loop iteration
	mov ax, BGCOLOR
	xor di, di
	mov cx, SCREENW*SCREENH
	rep stosw							; mov [ES:DI], AX & inc di

	;; Draw snake
	xor bx, bx						; Array index
	mov cx, [snakeLength]	; Loop counter
	mov ax, SNAKECOLOR
	.snake_loop:
		imul di, [SNAKEYARRAY+bx], SCREENW*2	; Y positiom of snake segment, 2 bytes per character
		imul dx, [SNAKEXARRAY+bx], 2	; X positiom of snake segment, 2 bytes per character
		add di, dx
		stosw
		inc bx
		inc bx
	loop .snake_loop

	;; Draw apple
	imul di, [appleY], SCREENW*2
	imul dx, [appleX], 2
	add di, dx
	mov ax, APPLECOLOR
	stosw


jmp game_loop
;; Bootsector padding
times 510 - ($-$$) db 0

dw 0x0AA55
