TITLE Fibonacci Numbers   (program2.asm)

; Author: Tatsiana Clifton   email: cliftota@onid.oregonstate.edu
; Course and section: CS271-400            Date: 07/09/2015
; Assignment#: 1          Due date: 07/12/2015
; Description:  This program will display author's name and the program title, ask the user's name
; and greet the user, ask the user for the number of Fibonacci terms in range [1..46], 
; validate the user input, calculate and display Fibonacci numbers, 
;**EC: Program prints farewell in white on blue background.


INCLUDE Irvine32.inc

UPPER_LIMIT = 46                      ;upper limit for the number of terms

.data
progTitle     BYTE    "Fibonacci Numbers", 0
authorName	  BYTE	  "Programmed by Tatsiana Clifton", 0
promptName	  BYTE	  "What's your name? ", 0
userName  	  BYTE    30 DUP(0)	   	  ;name to be entered by user
byteCount     DWORD   ?               ;holds count of characters entered by the user
greetings     BYTE	  "Hello, ", 0
introEC       BYTE    "**EC: Program prints farewell in white on blue background .", 0
instruction1  BYTE	  "Enter the number of Fibonacci terms to be displayed ", 0
instruction2  BYTE	  "Give the number as an integer in the range [1 .. 46]. ", 0
promptTerms   BYTE    "How many Fibonacci terms do you want? ", 0
numTerms  	  DWORD   ?		   	      ;number of terms to be entered by user
prev          DWORD   ?
five          DWORD   5
space         BYTE    "      ", 0
warning       BYTE    "Out of range. Enter a number in [1 .. 46]", 0
parting       BYTE    "Results certified by Tatsiana Clifton.", 0
goodBye		  BYTE	  "Good-bye, ", 0

.code
main PROC

;Introduce programmer and program title
	mov		     edx, OFFSET progTitle
	call	WriteString
	call    CrLf
	mov		     edx, OFFSET authorName
	call	WriteString
	call	CrLf
	call    CrLf

;Display which extra credits were chosen to work on
	mov		     edx, OFFSET introEC
	call	WriteString
	call	CrLf
	call    CrLf

;Get the user name and greet him/her
    mov          edx, OFFSET promptName
	call    WriteString
	mov          edx, OFFSET userName
	mov          ecx, SIZEOF userName
	call    ReadString
	mov     byteCount, eax
	mov          edx, OFFSET greetings
	call    WriteString
	mov          edx, OFFSET userName
	call    WriteString
	call    CrLf

;Provide instructions to the user
    mov          edx, OFFSET instruction1
	call    WriteString
	call    CrLf
	mov          edx, OFFSET instruction2
	call    WriteString
	call    CrLf
	call    CrLf

;Get the number of terms from the user
numberTerms:
    mov          edx, OFFSET promptTerms
	call    WriteString
	call    ReadInt                   ;read user input
	mov     numTerms, eax             ;store the input
	call    CrLf

;Validate the user input, must be more than 1 or equal
    mov     edx, numTerms
	cmp     edx, 1                    ;compare the entered number with 1
	jl      errorMessage
	je      fibonacci                 ;if number is 1 it is valid, continue
	jg      nextComparison            ;if the number more then 1, compare with 46

;Validate the user input, must be less than 46 or equal
nextComparison:
	mov     edx, numTerms
	cmp     edx, UPPER_LIMIT
	jg      errorMessage
	jle     fibonacci

;Display that out of range
errorMessage:
    mov          edx, OFFSET warning
	call    WriteString
	call    CrLf
	jmp     numberTerms
	
;Calculate and display Fibonacci numbers
fibonacci:  
    mov     ebx, 1                    ;to start the sequence
	mov     prev, 0                   ;to start the sequence
    mov     ecx, numTerms             ;loop count
L:
    mov     eax, ebx
	add     eax, prev
	mov     ebx, prev
	mov     prev, eax
    call    WriteDec                  ;print the number from the sequence
	mov		     edx, OFFSET space
    call    WriteString               ;print 5 spaces
	mov     edx, ecx                  ;move the loop count to edx
	cdq
	div     five                      ;divide loop count by 5
	cmp     edx, 0                    ;compare remainder with 0
	jne     next                      ;if not 0 jump, it means not 5 numbers on the line yet   
	call    CrLf                      ;if loop count was divided by 5 without remainder print new line
next: 
    mov     eax, prev                 ;renew eax, it was change while division
	loop L

;Say "Good-bye" 
    mov     eax, white + (blue*16)    ;white on blue color
    call    SetTextColor 
    call    CrLf
	call    CrLf
    mov		     edx, OFFSET parting
	call	WriteString
	call	CrLf
	mov		     edx, OFFSET goodBye
	call	WriteString
	call	CrLf

exit	                              ;exit to operating system
main ENDP

END main