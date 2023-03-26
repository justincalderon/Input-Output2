; Module:		Console.asm
; Author:		Justin Calderon
; Date:		March 25, 2023	
; Purpose:	Review using the Irvine library.
;			Perform procedure calls in sequence.
;			Perform console input/output.
;			Perform file input/output.	
;
;
INCLUDE C:\Irvine\Irvine32.inc							; include library
;
; <DATA SEGMENT>
;.model flat, STDCALL
.data

; <VARIABLES>
;	
	strPromptF	db "Enter the name of the file to create: ", 0	; prompt for filename
	strPromptB	db "Enter text to write to the file:      ", 0	; prompt for text
	strErrorCreate db "File error: Unable to create file."	, 0		; file not found error message
	strErrorRead   db "File error: Unable to read file. ", 0		; file not found error message
	strFilespec	db 7fh dup(0)								; file path
	fHandle		dd ?										; file handle
	strOutput		db 7fh dup(0)								; write to file
	strInput		db 7fh dup(0)								; read from file
;
; <CODE SEGMENT>
.code

;;;;;;;;;;;;;;;;;;;
; MAIN
;;;;;;;;;;;;;;;;;;;
main PROC
;
	; prompt for a filespec to create
	mov		edx, OFFSET strPromptF		; load prompt string
	call		WriteString				; display prompt

	; get user input (filespec)
	mov		edx, OFFSET strFilespec		; load input buffer
	mov		ecx, SIZEOF strFilespec		; set size of buffer
	call		ReadString				; get user input

	; for writing
	; prompt for file data to be written to file
	mov		edx, OFFSET strPromptB		; load prompt string
	call		WriteString				; display prompt

	; get user input (file contents)
	mov		edx, OFFSET strOutput		; load input buffer
	call		ReadString				; get user input

	; open as create, a new file per strFilespec
	call		NEWFILE					;
	
	; check for good open (create)
	;mov		eax, fHandle				; handle to register
	;cmp		eax, INVALID_HANDLE_VALUE	; check handle for error
	;je		ERROR_MSG					; goto error message if error

	; read file contents
	
	; open the file
	mov		edx, OFFSET strFilespec		; load filespec
	call		OpenInputFile				; open the file

	; good open?
	cmp		eax, INVALID_HANDLE_VALUE	; check for bad handle
	je		ERROR_MSG					; bad? goto error message
	mov		fHandle, eax				; save file handle

	; read the contents of the file
	mov		eax, fHandle				; load file handle 
	mov		edx, OFFSET strInput		; set buffer
	mov		ecx, SIZEOF strInput		; set size of buffer
	call		ReadFromFile				; read the file into the buffer
	
	; write contents of file to the console
	call		Crlf						; create newline
	mov		edx, OFFSET strInput		; load file contents
	call		WriteString				; display to console

	; close the file
	mov		eax, fHandle				; load file handle
	call		CloseFile					; close the file
	
	jmp		ENDPROG					; jump around error message

ERROR_MSG:							; file error 
	
	; display error message
	mov		edx, OFFSET strErrorRead		; load error message
	call		WriteString				; display error message
	call		Crlf						; create newline
;
;
ENDPROG:								; end of program
	call		Crlf						; blank line after end of program
	call		Crlf						; 

	ret									; return to console
main ENDP
;
;;;;;;;;;;;;;;;;;;;
; end main
;;;;;;;;;;;;;;;;;;;
;
;;;;;;;;;;;;;;;;;;;
; PROCEDURES
;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;
; NEWFILE								; create a file and write the buffer to it
;;;;;;;;;;;;;;;;;;;
NEWFILE proc							; open a file for create a nd save the handle
	pushad							; save registers
	
	; create file
	mov		edx, OFFSET strFilespec		; load the filespec
	call		CreateOutputFile			; Irvine, create file
	
	; test for file open error
	cmp		eax, INVALID_HANDLE_VALUE	; eax has handle, or error
	je		NEWFILE_ERROR				; if error, jump to error message

	; save valid handle
	mov		fHandle, eax				; file handle in eax (from CreateOutputFile)

	; write buffer to the file
	mov		eax, fHandle				; load file handle
	mov		edx, OFFSET strOutput		; load buffer
	mov		ecx, SIZEOF strOutput		; set size of buffer
	call		WriteToFile				; write buffer to file

	; close output file
	mov		eax, fHandle				; load file handle
	call		CloseFile					; close file

	jmp		NEWFILE_END				; jump around error message

NEWFILE_ERROR:							; file open error

	; display error message
	mov		edx, OFFSET strErrorCreate	; load error message
	call		WriteString				; display error message
	call		Crlf						; create new line

NEWFILE_END:							; end of procedure



	; pseudo for invalid handle value for filespec
	;if EAX = INVALID_HANDLE_VALUE
	;	the file was not created successfully
	;else
	;	EAX - handle for the open file
	;end if


	popad							; restore registers
	ret								; return to calling procedure
NEWFILE endp							; end of NEWFILE procedure


;;;;;;;;;;;;;;;;;;;
;
END main

