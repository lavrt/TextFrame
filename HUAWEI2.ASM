.model tiny
.code
org 100h

Start:
	mov ch, 40					; frame width
	mov ah, 10					; frame height

	mov di, 0081h
FindParam:
	mov al, 2Ch
	repz scasb
	dec di
	push di
	mov si, di

ScanParams:
	lodsb
	cmp al, 0Dh
	je ParamsEnded
	cmp al, 2Ch
	jne ScanParams

	dec si
	mov byte ptr [si], '$'
	mov di, si
	inc di
	jmp FindParam

ParamsEnded:
	dec si
	mov byte ptr [si], '$'

	mov bx, 0b800h
  	mov es, bx
	mov bx, 0

	pop si; Обработка стилевой строки

	pop di
	call atoi
	mov ah, cl

	pop di
	push ax
	call atoi
	pop ax
	mov ch, cl

	call DrawFrame
	call Exit

;---------------------------------------------------
; ASCII to integer (ATOI)
; Entry: DI = address of the string
; Exit : CL = integer
; Destr: DH, AX
;---------------------------------------------------
Atoi:
	mov dh, 0
	mov ax, 0
	mov cl, 0
Loop_8:
	mov byte ptr al, [di]
	cmp al, '$'
	je Loop_7
	cmp dh, 0
	je Loop_9
	mov ah, cl
	shl cl, 3
	shl ah, 1
	add cl, ah
Loop_9:
	mov dh, 1
	inc di
	sub al, '0'
	add cl, al
	jmp Loop_8
Loop_7:
	ret
endp

;---------------------------------------------------
; Draw a frame
; Entry: CH = frame width
;        AH = frame height
; Exit : None
; Destr:
;---------------------------------------------------
DrawFrame:
	sub ch, 2
	mov cl, ch
	;mov si, offset String
	mov di, 0b800h

	call HeightOffset

	call DrawString
	add si, 3
	dec ah
Loop_2:
	add di, 10

	call DrawString
	dec ah
	cmp ah, 0
	jne Loop_2

	add si, 3
	call DrawString

	mov ah, 0
	mov di, 0b800h
	call HeightOffset
	mov bx, di
	mov es, bx
	mov bx, offset Text
	call StringLength
	call WidthOffset
	mov bp, offset Text
Loop_6:
	mov al, [bp]
	cmp al, '$'
	je Done_6
	mov byte ptr es:[bx], al
	inc bp
	add bx, 2
	jmp Loop_6
Done_6:

	ret
endp

;---------------------------------------------------
; Draw a line of the frame
; Entry: DI = video memory address
;        SI = address of the style line
; Exit : None
; Destr:
;---------------------------------------------------
DrawString:
	mov dx, es

	mov al, [si]

	mov bx, di
	mov es, bx
	mov bx, 0

	call WidthOffset

	mov es:[bx], al

	mov es, dx
	inc si
	mov al, [si]

	push bx
	mov bx, di
	mov es, bx
	pop bx

Loop_1:
	add bx, 2
	mov byte ptr es:[bx], al
	dec ch
	cmp ch, 0
	jne Loop_1

	mov ch, cl

	mov es, dx
	inc si
	mov al, [si]

	push bx
	mov bx, di
	mov es, bx
	pop bx

	add bx, 2
	mov byte ptr es:[bx], al

	sub si, 2

	ret
endp

;---------------------------------------------------
; Find the length of the string
; Entry: BX = offset string
; Exit : CH = length of the string
; Destr: BX
;---------------------------------------------------
StringLength:
	mov ch, 0

Loop_5:
	cmp byte ptr [bx], '$'
	je Done_5
	inc ch
	inc bx
	jmp Loop_5

Done_5:
	mov bx, 0
	ret
endp

;---------------------------------------------------
; Сalculate the width offset for displaying a centered row
; Entry: BX = offset string
; 		 CH = length of the string
; Exit : None
; Destr: CL
;---------------------------------------------------
WidthOffset:
	mov cl, [screen_width]
	sub cl, ch
	shr cl, 1
Loop_3:
	add bx, 2
	dec cl
	cmp cl, 0 ; test cl cl
	jne Loop_3

	mov cl, ch

	ret
endp

;---------------------------------------------------
; Сalculate the height offset for displaying a centered row
; Entry: AH = offset frame
; Exit : None
; Destr: None
;---------------------------------------------------
HeightOffset:
	push ax
	mov al, ah
	mov ah, [screen_height]
	sub ah, al
	shr ah, 1
Loop_4:
	add di, 10
	dec ah
	cmp ah, 0
	jne Loop_4

	pop ax

	ret
endp

;---------------------------------------------------
; Сomplete the program execution.
; Entry: None
; Exit : None
; Destr: None
;---------------------------------------------------
Exit:
	mov ax, 4c00h
	int 21h

String:
	db '+-+| |+-+$'

Text:
	db 'Hello Vova!$'

screen_width db 80
screen_height db 25

end	Start
