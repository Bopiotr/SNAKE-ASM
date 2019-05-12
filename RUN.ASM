org 100h

PREAPARE: 					; narysowanie weza i otoczki 
	mov		word[ogon],10
	mov		word[ogon+2],180
	mov		word[glowa],60
	mov		word[glowa+2],180
	call	tryb_graf
	mov		bl,6			; bl -kolor kropki
	mov 	cx,320
	call	NEW_QUAD
UD:
	mov		si,0
	mov 	di,cx
	sub		di,1
	call	draw_dot
	mov 	si,1
	call	draw_dot
	mov 	si,199
	call	draw_dot
	mov		si,198
	call	draw_dot
	loop 	UD
	
	mov		cx,200
LR:
	mov		di,0
	mov		si,cx
	sub		si,1
	call	draw_dot
	mov		di,1
	call	draw_dot
	mov		di,319
	call    draw_dot
	mov		di,318
	call	draw_dot
	loop	LR
DRAW_SNAKE:	
	mov		bl,15			;wspolrzednie ogona:
	mov		di,word[ogon] 	;x
	mov 	si,word[ogon+2]	;y

DRAW_LINE:					; rysuje poczatkowego weza
	call 	draw_dot		; od ogona do glowy, w poziomie
	cmp 	di,word[glowa]	; skok gdy gotowy
	jnb 	GO_SNAKE
	inc 	di
	jmp 	DRAW_LINE

GO_SNAKE:
	mov 	bh,2			; bh - kierunek ruchu glowy weza(2 to prawo)
	xor 	bl,bl

MAIN:
	push 	bx
	cmp		word[addsize],0
	je		TAIL
	sub		word[addsize],1
	jmp		NEXT
TAIL:	
	mov 	di,word[ogon]	; zamolowuje ogon
	mov 	si,word[ogon+2]
	mov 	bl,0
	call 	draw_dot

	call 	follow			; sprawdza w ktora strone ma podazac ogon
	cmp 	cx,2			; ustawia odpowiednia wartosc w cx
	je 		RIGHT_O
	jb 		UP_O

	cmp 	cx,3
	je 		DOWN_O
	ja 		LEFT_O

RIGHT_O:					; przesuniecie ogona w prawo
	inc 	word[ogon]				
	jmp 	NEXT

UP_O:						; przesuniecie ogona do gory
	sub 	word[ogon+2],1
	jmp 	NEXT

LEFT_O:						; przesuniecie ogona w lewo
	sub 	word[ogon],1
	jmp 	NEXT

DOWN_O:						; przesuniecie ogona do dolu
	add 	word[ogon+2],1
	jmp 	NEXT

NEXT:						; rysowanie glowy
	mov 	di,word[glowa]
	mov 	si,word[glowa+2]
	mov 	bl,15
	call 	draw_dot
	pop 	bx
	cmp 	bh,2
	je 		RIGHT_G
	jb 		UP_G

	cmp 	bh,3
	je 		DOWN_G
	ja 		LEFT_G

RIGHT_G:					; przesuniecie glowy w prawo
	inc 	word[glowa]				
	jmp 	KEYS

UP_G:						; przesuniecie glowy do gory
	sub 	word[glowa+2],1
	jmp 	KEYS

LEFT_G:						; przesuniecie glowy w lewo
	sub 	word[glowa],1
	jmp 	KEYS

DOWN_G:						; przesuniecie glowy do dolu
	add 	word[glowa+2],1
	jmp 	KEYS



KEYS:
	mov 	di,word[glowa]
	mov 	si,word[glowa+2]
	
	call	IS_END
	je near	STOP
	
	call	CHECKING_POINT
	
	cmp 	bl,0
	je 		CLICKS
	pop 	ax
	jmp 	SEARCHING_KEY

CLICKS:
	call 	fflush 			; czyszczenie buffora klawiatury
	call 	delay			; spowolnienie programu
							; pierszsze przerwanie 16h
	mov 	ah,01h 			; ustawia scancode i Ascii(jesli istnieje)
	int 	16h         	; klawisza w buforze, jesli buf pusty ustawia ZF
							; ah-scan code, al - ACII					
	je 		MAIN

SEARCHING_KEY:
	cmp 	ah,72			; wcisnieta strzalka do gory
	je 		UP_CLICK

	cmp 	ah,77			; wcisnieta strzalka w prawo
	je near	RIGHT_CLICK

	cmp 	ah,80			; wcisnieta strzalka do dolu
	je 		DOWN_CLICK

	cmp 	ah,75			; wcisnieta strzalka w lewo
	je near LEFT_CLICK

	cmp 	ah,1 			; koniec jesli 'esc'
	je near END
	jmp 	MAIN

UP_CLICK:					; begin up_click
	cmp 	bl,128
	je		EUP				; akcja na wciniecie strzalki do gory
	cmp 	bh,1
	je 		MAIN
	cmp 	bh,3
	je 		MAIN

	push 	ax
	xor 	dx,dx
	mov 	ax,word[glowa]
	mov 	cx,2 
	div 	cx
	pop 	ax

	cmp 	dx,0
	je 		EUP
	push 	ax
	mov 	bl,128
	jmp 	MAIN

EUP:
	mov 	bl,0
	mov 	bh,1
	jmp 	MAIN			; end of up_click

DOWN_CLICK:					; akcja na wciniecie strzalki do dolu

	cmp 	bl,128			; sprawdzanie czy to dodatkowa iteracja
	je		EDO
	cmp 	bh,3			; sprawdzanie czy wąż nie jest już skierowany
	je		MAIN			; w tym kierunku 
	cmp 	bh,1
	je 		MAIN

	push 	ax				; zabezpieczenie aby waz byl rysowany tylko
	xor 	dx,dx			; w liniach parzystych
	mov 	ax,word[glowa]	
	mov 	cx,2 
	div 	cx
	pop 	ax

	cmp 	dx,0			; jesli jest aktualnie na nieparzystym pikselu
	je 		EDO				; wykonuje dodatkowa iteracje programu 
	push 	ax				; zapamietujac wcisniety klawisz wraca do tego miejsca
	mov 	bl,128			; ustawia bl na 128 co znaczy ze kolejna iteracja programu
	jmp 	MAIN			; wykona sie tylko aby przesunac weza o 1 piksel

EDO:						; ustawia bl=0 i zmienia kierunek rysowania weza 
	mov 	bl,0
	mov 	bh,3
	jmp 	MAIN			; end of down_click

RIGHT_CLICK:				; akcja na wciniecie strzalki w prawo
	cmp 	bl,128
	je 		ERI
	cmp 	bh,2
	je 		MAIN
	cmp 	bh,4
	je 		MAIN


	push 	ax
	xor 	dx,dx
	mov 	ax,word[glowa+2]
	mov 	cx,2 
	div		cx
	pop 	ax

	cmp 	dx,0
	je 		ERI
	push 	ax
	mov 	bl,128
	jmp 	MAIN

ERI:
	mov 	bl,0
	mov 	bh,2
	jmp 	MAIN			; end of right_click


LEFT_CLICK:					; akcja na wciniecie strzalki w lewo
	cmp 	bl,128
	je 		ELE

	cmp 	bh,4
	je 		MAIN
	cmp 	bh,2
	je 		MAIN

	push 	ax
	xor 	dx,dx
	mov 	ax,word[glowa+2]
	mov 	cx,2 
	div 	cx
	pop 	ax

	cmp 	dx,0
	je 		ELE
	push 	ax
	mov 	bl,128
	jmp 	MAIN
ELE:
	mov 	bl,0
	mov 	bh,4
	jmp 	MAIN

STOP:
	call	fflush
	call	getchar
	jmp		PREAPARE

END:
	call getchar				;zakonczenie programu i wyjscie
	call exit

SECTION .data

%include "lib.asm"

glowa dw 0,0
ogon dw 0,0
addsize dw 0