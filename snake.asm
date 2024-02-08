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
UP					equ 0
DOWN				equ 1
LEFT				equ 2
RIGHT 			equ 3

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

	;; Hide cursor
	mov ah, 0x02
	mov dx, 0x2600	; DH = row, DL = col, cursor in off the visible screen
	int 0x10

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

	;; Move snake in current direction
	mov al, [direction]
	cmp al, UP
	je move_up
	cmp al, DOWN
	je move_down
	cmp al, LEFT
	je move_left
	cmp al, RIGHT
	je move_right

	jmp update_snake

	move_up:
	dec word [playerY]
	jmp update_snake

	move_down:
	inc word [playerY]
	jmp update_snake

	move_left:
	dec word [playerX]
	jmp update_snake

	move_right:
	inc word [playerX]
	jmp update_snake

	;; Update snake position from playerX/Y changes
	update_snake:
	;; Update all snake segments past the "head", iteration back to front
	imul bx, [snakeLength], 2 ; each array element = 2 bytes
	.snake_loop:
		mov ax, [SNAKEXARRAY-2+bx]
		mov word [SNAKEXARRAY+bx], ax

		dec bx
		dec bx
	jnz .snake_loop

	;; Store updated values to head of snake in arrays
	mov ax, [playerX]
	mov word [SNAKEXARRAY], ax
	mov ax, [playerY]
	mov word [SNAKEYARRAY], ax

	;; Lose conditions
	;; 1) Hit borders of screen
	cmp word [playerY], -1				; Top of screen
	je game_lost
	cmp word [playerY], SCREENH		; Bottom of screen
	je game_lost
	cmp word [playerX], -1				; Left of screen
	je game_lost
	cmp word [playerX], SCREENW		; Right of screen
	je game_lost

	;; 2) Hit part of snake
	cmp word [snakeLength], 1			; Only have starting segment
	je get_player_input

	mov bx, 2											; Array indexes, start at 2nd array element
	mov cx, [snakeLength]					; Loop counter
	check_hit_snake_loop:
		mov ax, [playerX]
		cmp ax, [SNAKEXARRAY+bx]
		jne .increment

		mov ax, [playerY]
		cmp ax, [SNAKEYARRAY+bx]
		je game_lost

		.increment:
			inc bx
			inc bx
		loop check_hit_snake_loop

	get_player_input:
		mov bl, [direction]					; Save current direction

		mov ah, 1
		int 0x16										; Get keyboard status
		jz check_apple							; If no key was pressed, move on

		xor ah,ah
		int 0x16										; Get keystroke, AH = scancode, AL = ascii char entered

		cmp al, 'w'
		je w_pressed
		cmp al, 's'
		je s_pressed
		cmp al, 'a'
		je a_pressed
		cmp al, 'd'
		je d_pressed

		jmp check_apple

		w_pressed:
			mov bl, UP
			jmp check_apple

		s_pressed:
			mov bl, DOWN
			jmp check_apple

		a_pressed:
			mov bl, LEFT
			jmp check_apple

		d_pressed:
			mov bl, RIGHT
			jmp check_apple

	;; Did player hit apple ?
	check_apple:
		mov byte [direction], bl		; Update direction

		mov ax, [playerX]
		cmp ax, [appleX]
		jne delay_loop

		mov ax, [playerY]
		cmp ax, [appleY]
		jne delay_loop

		; Hit apple, increase snake length
		inc word [snakeLength]
		cmp word [snakeLength], WINCOND


	delay_loop:
		mov bx, [TIMER]
		inc bx
		inc bx
		.delay:
			cmp [TIMER], bx
			jl .delay

jmp game_loop

;; End conditions
game_won:
	jmp reset

game_lost:
	mov dword [ES:0000], 0x1F4F1F4C	; Lo
	mov dword [ES:0004], 0x1F451F53; se

;; Reset the game
reset:
	xor ah, ah
	int 0x16

	jmp 0x0FFFF:0x0000			; Far jump to reset vector, "warm reboot"
;;	int 0x19							; Alternative reset, restarts qemu

;; Bootsector padding
times 510 - ($-$$) db 0

dw 0x0AA55
