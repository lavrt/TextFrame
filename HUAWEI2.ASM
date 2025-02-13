		.model 	tiny
		.code
		org 	100h

Start:
		mov		di, 0081h
FindParam:
		mov 	al, 2Ch
		repz 	scasb
		dec 	di
		push 	di
		mov 	si, di
ScanParams:
		lodsb
		cmp 	al, 0Dh
		je 		ParamsEnded
		cmp 	al, 2Ch
		jne 	ScanParams
		dec 	si
		mov 	byte ptr [si], '$'
		mov 	di, si
		inc 	di
		jmp 	FindParam
ParamsEnded:
		dec 	si
		mov 	byte ptr [si], '$'
		mov 	bx, 0b800h
		mov 	es, bx
		mov 	bx, 0

		pop 	bp 		; text

		pop		di   	; style
		call	atoi
		cmp		cl, 0
		jne		SkipReceivingString
		pop 	si
SkipReceivingString:
		cmp		cl, 1
		je		LineSwitch_1
		cmp		cl, 2
		je		LineSwitch_2
		cmp		cl, 3
		je		LineSwitch_3
		jmp		EndOfLineSwitch
LineSwitch_1:
		mov 	si, offset Style_1
		jmp		EndOfLineSwitch
LineSwitch_2:
		mov 	si, offset Style_2
		jmp		EndOfLineSwitch
LineSwitch_3:
		mov 	si, offset Style_3
		jmp		EndOfLineSwitch
EndOfLineSwitch:

		pop 	di		; color
		call 	atoi
		mov 	dl, cl

		pop 	di		; frame height
		call 	atoi
		mov 	ah, cl

		pop 	di		; frame width
		push 	ax
		call 	atoi
		pop 	ax
		mov 	ch, cl

		call 	DrawFrame
		call 	Exit

;---------------------------------------------------
; ASCII to integer (ATOI)
; Entry: DI = address of the string
; Exit : CL = integer
; Destr: DH, AX
;---------------------------------------------------
Atoi:
		mov 	dh, 0
		mov 	ax, 0
		mov 	cl, 0
Loop_8:
		mov 	byte ptr al, [di]
		cmp 	al, '$'
		je 		Loop_7
		cmp 	dh, 0
		je 		Loop_9
		mov 	ah, cl
		shl 	cl, 3
		shl 	ah, 1
		add 	cl, ah
Loop_9:
		mov 	dh, 1
		inc 	di
		sub 	al, '0'
		add 	cl, al
		jmp 	Loop_8
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
		sub 	ch, 2
		mov 	cl, ch
		mov 	di, 0b800h

		call 	HeightOffset

		call 	DrawString
		add 	si, 3
		dec 	ah
Loop_2:
		add 	di, 10

		call 	DrawString
		dec 	ah
		cmp 	ah, 0
		jne 	Loop_2

		add 	si, 3
		call 	DrawString

		mov 	ah, 0
		mov 	di, 0b800h
		call 	HeightOffset
		mov 	bx, di
		mov 	es, bx
		mov 	bx, bp
		call 	StringLength
		call 	WidthOffset
Loop_6:
		mov 	al, [bp]
		cmp 	al, '$'
		je 		Loop_10
		mov 	byte ptr es:[bx], al
		inc 	bp
		add 	bx, 2
		jmp 	Loop_6
Loop_10:
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
		push 	ax
		mov 	al, dl
		mov 	dx, es

		mov 	ah, [si]

		mov 	bx, di
		mov 	es, bx
		mov 	bx, 0

		call 	WidthOffset

		mov 	byte ptr es:[bx], ah
		mov 	byte ptr es:[bx+1], al

		mov 	es, dx
		inc 	si
		mov 	ah, [si]

		push 	bx
		mov 	bx, di
		mov 	es, bx
		pop 	bx

Loop_1:
		add 	bx, 2
		mov 	byte ptr es:[bx], ah
		mov 	byte ptr es:[bx+1], al
		dec 	ch
		cmp 	ch, 0
		jne 	Loop_1

		mov 	ch, cl

		mov 	es, dx
		inc 	si
		mov 	ah, [si]

		push	bx
		mov 	bx, di
		mov 	es, bx
		pop 	bx

		add 	bx, 2
		mov 	byte ptr es:[bx], ah
		mov 	byte ptr es:[bx+1], al

		sub 	si, 2

		mov 	dl, al
		pop 	ax
		ret
		endp

;---------------------------------------------------
; Find the length of the string
; Entry: BX = offset string
; Exit : CH = length of the string
; Destr: BX
;---------------------------------------------------
StringLength:
		mov 	ch, 0
Loop_5:
		cmp 	byte ptr [bx], '$'
		je 		Done_5
		inc 	ch
		inc 	bx
		jmp 	Loop_5

Done_5:
		mov 	bx, 0
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
		mov 	cl, [screen_width]
		sub 	cl, ch
		shr 	cl, 1
Loop_3:
		add 	bx, 2
		dec 	cl
		cmp 	cl, 0 ; test cl cl
		jne 	Loop_3

		mov 	cl, ch

		ret
		endp

;---------------------------------------------------
; Сalculate the height offset for displaying a centered row
; Entry: AH = offset frame
; Exit : None
; Destr: None
;---------------------------------------------------
HeightOffset:
		push 	ax
		mov 	al, ah
		mov 	ah, [screen_height]
		sub 	ah, al
		shr 	ah, 1
Loop_4:
		add 	di, 10
		dec 	ah
		cmp 	ah, 0
		jne 	Loop_4

		pop 	ax

		ret
		endp

;---------------------------------------------------
; Сomplete the program execution.
; Entry: None
; Exit : None
; Destr: None
;---------------------------------------------------
Exit:
		mov 	ax, 4c00h
		int 	21h

Style_1:
		db 		'+-+| |+-+$'
Style_2:
		db 		'/-\| |+-+$'
Style_3:
		db 		'***< >***$'

Text:
		db 		'Hello Vova!$'

screen_width  db 80
screen_height db 25

		end		Start
