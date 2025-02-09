.model tiny
.code
org 100h

Start:
	mov ch, 40					; frame width
	mov ah, 10					; frame height

	call DrawFrame
	call Exit

;---------------------------------------------------;
;            		Draw a frame
; Entry: CH = frame width
;        AH = frame height
; Exit : None
; Destr:
;---------------------------------------------------;
DrawFrame:
	sub ch, 2
	mov cl, ch
	mov si, offset String
	mov di, 0b800h

	call HeightOffset

	call DrawString

	dec ah
Loop_2:
	add di, 10
	mov si, offset String + 3
	call DrawString
	dec ah
	cmp ah, 0
	jne Loop_2

	mov si, offset String + 6
	call DrawString

	mov ah, 0
	mov di, 0b800h
	call HeightOffset
	mov bx, di
	mov es, bx
	mov bx, offset Text
	call StringLength
	call WidthOffset
	mov si, offset Text
Loop_6:
	mov al, [si]
	cmp al, '$'
	je Done_6
	mov byte ptr es:[bx], al
	inc si
	add bx, 2
	jmp Loop_6
Done_6:

	ret
endp

;---------------------------------------------------;
;            Draw a line of the frame
; Entry: DI = video memory address
;        SI = address of the style line
; Exit : None
; Destr:
;---------------------------------------------------;
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

	ret
endp

;---------------------------------------------------;
;          Find the length of the string
; Entry: BX = offset string
; Exit : CH = length of the string
; Destr: BX
;---------------------------------------------------;
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

;---------------------------------------------------;
;     Сalculate the width offset for displaying
;				  a centered row.
; Entry: BX = offset string
; 		 CH = length of the string
; Exit : None
; Destr: CL
;---------------------------------------------------;
WidthOffset:
	mov cl, [screen_width]
	sub cl, ch
	shr cl, 1
Loop_3:
	add bx, 2
	dec cl
	cmp cl, 0
	jne Loop_3

	mov cl, ch

	ret
endp

;---------------------------------------------------;
;    Сalculate the height offset for displaying
;				  a centered row.
; Entry: AH = offset frame
; Exit : None
; Destr: None
;---------------------------------------------------;
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

;---------------------------------------------------;
;    	  Сomplete the program execution.
; Entry: None
; Exit : None
; Destr: None
;---------------------------------------------------;
Exit:
	mov ax, 4c00h
	int 21h

String:
	db '+-+| |+-+$'

Text:
	db 'Hello world!$'

screen_width db 80
screen_height db 25

end	Start
