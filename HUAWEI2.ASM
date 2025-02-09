.model tiny
.code
org 100h

Start:
	mov ch, 40					; ширина рамки
	mov ah, 10					; высота рамки
	call DrawFrame
	call Exit					; завершение программы

DrawFrame:
	sub ch, 2
	mov cl, ch
	mov si, offset String		; адрес строки
	mov di, 0b800h				; адрес начала печати
	call DrawString				; вызов функции, печатающей одну строку

	dec ah
Loop_2:							; цикл для печати строк (внутренность рамки)
	add di, 10					; смещение адреса начала печати для перевода на новую строку
	mov si, offset String + 3	; смещение для печати второй тройки символов из строки
	call DrawString				; вызов функции, печатающей одну строку
	dec ah						; счетчик цикла
	cmp ah, 0					; проверка условия выхода из цикла
	jne Loop_2

	mov si, offset String + 6	; смещение для печати третьей тройки символов из строки
	call DrawString				; вызов функции, печатающей одну строку

	ret
endp

DrawString:
	mov dx, es					; сохранить сегмент, в котором находится строка

	mov al, [si]				; записать букву в al

	mov bx, di					;\
	mov es, bx					; запись сегмента видеопамяти в es
	mov bx, 0					;/

	mov es:[bx], al				; запись в видеопамять первого символа в строке

	mov es, dx					;\
	inc si						; получение новой буквы из строки
	mov al, [si]				;/

	mov bx, di					;\
	mov es, bx					; запись сегмента видеопамяти в es
	mov bx, 0					;/

Loop_1:							; цикл для печати строки
	add bx, 2					; смещение для печати новой буквы
	mov byte ptr es:[bx], al	; печать буквы
	dec ch
	cmp ch, 0					; проверка условия выхода из цикла
	jne Loop_1

	mov ch, cl

	mov es, dx					;\
	inc si						; получение новой буквы из строки
	mov al, [si]				;/

	push bx
	mov bx, di					;\
	mov es, bx					; запись сегмента видеопамяти в es
	pop bx

	add bx, 2
	mov byte ptr es:[bx], al	; запись последнего сивола в строке

	ret
endp

Exit:
	mov ax, 4c00h
	int 21h

String:
	db '+-+| |+-+$'

end	Start


