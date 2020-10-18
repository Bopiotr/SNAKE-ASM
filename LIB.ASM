
; funkcje uzywane w snake'u
; Created by Piotr Babiarz


tryb_graf:			;przelaczenie na tryb graficzny
	mov 	ah,0h
	mov 	al,13h
	int 	10h
	xor 	ax,ax
ret


tryb_tekst:			;przelaczenie na tryb tekstowy
	mov 	ah,0h
	mov 	al,03h
	int 	10h
ret


getchar:			;czeka do momentu wcisniecia dowolnego klawisza
	xor 	ah,ah
	int 	16h
ret

;wyjscie z programu
exit:
	call 	tryb_tekst
	mov 	ax,4c00h
	int 	21h
ret


draw_dot:			;rusuje piksel, w di i si wspolrzedne piksela w bl kolor
	push 	ax
	push 	di
	push 	es
	mov 	ax,320 		;obliczanie numeru piksela
	mul 	si		;pierw wsp Y*320

	add 	di,ax		;dodanie Y*320 do X, daje nam numer piksela

	mov 	ax,0a000h
	mov 	es,ax
	mov 	byte[es:di],bl

	pop 	es
	pop 	di
	pop 	ax
ret

delay:
	pusha
	mov 	ax,20
	mov 	bx, 1000
	mul 	bx
	mov 	cx,dx
	mov 	dx,ax
	mov 	ah,86h
	int 	15h
	popa
ret

follow: 			;cx rejetr wynikowy
	push 	ax
	push 	di
	push 	es

	mov 	ax,320  	;obliczanie numeru piksela
	mul 	si		;pierw wsp Y*320

	add 	di,ax		;dodanie Y*320 do X, daje nam numer piksela


	sub 	di,320		;piksel z gory
	mov 	ax,0a000h
	mov 	es,ax
	mov 	cx,1 		 
	cmp 	byte[es:di],15
	je 	ef
	add 	di,320

	add 	di,320		;piksel z dolu
	mov 	ax,0a000h
	mov 	es,ax
	mov 	cx,3 		 
	cmp 	byte[es:di],15
	je 		ef
	sub 	di,320

	inc 	di		; piksel z prawej
	mov 	cx, 2
	cmp 	byte[es:di],15
	je 	ef

	sub 	di,2    	; piksel z lewej
	mov 	cx,4
	cmp 	byte[es:di],15
	je 	ef

	ef:
	pop 	es
	pop 	di
	pop 	ax
ret


fflush:	
	push	ax
	push	es
	mov	ax, 0000h
	mov	es, ax

	mov	word[es:041ah], 041eh
	mov	word[es:041ch], 041eh	; Clears keyboard buffer
	pop	es
	pop	ax
ret

IS_END:
	push 	di
	push 	es
	push 	ax
	mov 	ax,320  	;obliczanie numeru piksela
	mul 	si		;pierw wsp Y*320
	add 	di,ax		;dodanie Y*320 do X, daje nam numer piksela
	mov 	ax,0a000h
	mov 	es,ax

	cmp 	byte[es:di],5
	jb	C1
	xor 	ax,ax		; ustawia Z = 1
	jmp 	IS_END_E
C1:
	add 	ax,10		; ustawia Z = 0
IS_END_E:
	pop 	ax
	pop 	es
	pop 	di
ret

NEW_QUAD:
	push	bx
	push	di
	push	si
	
	mov	di,word[kwadrat]
	mov	si,word[kwadrat+2]
	mov	bl,0
	call	DRAW_QUAD
RANDOM:	
	call	RAND		; losuje dwie wspolrzedne, trafiaja do di i si
	
	mov	bl,3
	call	DRAW_QUAD
	
	mov	word[kwadrat],di
	mov	word[kwadrat+2],si
END_NEW_QUAD:
	pop	si
	pop	di
	pop	bx
ret

DRAW_QUAD:
	push	cx
	push	di
	push	si
	mov	cx,3
DRAW_1:
	push 	cx
	push 	di
	mov 	cx,3
DRAW_2:
	call	draw_dot
	inc 	di
	loop 	DRAW_2
	
	pop	di
	inc 	si
	pop	cx
	loop	DRAW_1
END_DRAW_QUAD:
	pop	si
	pop	di
	pop 	cx
ret


RAND:
	push	ax
	push	cx
	
	
	mov 	ah, 00h  ; interrupts to get system time        
	int 	1ah
	
	mov 	ax,dx
	xor	dx,dx
	mov 	cx,313 
	div 	cx
	mov 	di,dx
	add	di,2
	
	mov 	ah, 00h  ; interrupts to get system time        
	int 	1ah
	
	mov 	ax,dx
	mov 	cx,193
	xor	dx,dx
	div 	cx
	mov 	si,dx
	add	si,2
		
IS_EMPTY_SPACE:	
	push	si
	push	di
	
	mov 	ax,320  	;obliczanie numeru piksela
	mul 	si		;pierw wsp Y*320
	add 	di,ax		;dodanie Y*320 do X, daje nam numer piksela
	mov 	ax,0a000h
	mov 	es,ax
	
	mov	cx,3 		; licznik loop EMPTY_1
EMPTY_1:
	push 	cx
	push	di
	mov	cx,3    	; licznik loop EMPTY_2
EMPTY_2:
	cmp 	byte[es:di],0
	jne	REPEAT	
	inc 	di
	loop 	EMPTY_2
	
	pop	di
	pop 	cx
	add	di,320	
	loop	EMPTY_1
	jmp	END_RAND
REPEAT:
	pop	di
	pop 	cx
	pop	di
	pop	si
	pop	cx
	pop	ax
	jmp 	RAND
END_RAND:
	pop	di
	pop	si
	pop	cx
	pop	ax
ret

CHECKING_POINT:
	push 	di
	push 	es
	push 	ax
	mov 	ax,320  	;obliczanie numeru piksela
	mul 	si		;pierw wsp Y*320
	add 	di,ax		;dodanie Y*320 do X, daje nam numer piksela
	mov 	ax,0a000h
	mov 	es,ax

	cmp 	byte[es:di],3
	jne 	END_CHECKING_POINT
	add	word[addsize],5
	call	NEW_QUAD
	
END_CHECKING_POINT:
	pop 	ax
	pop 	es
	pop 	di
ret


SECTION .data

kwadrat dw 15,30
