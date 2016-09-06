TITLE Composite Numbers   (program3.asm)

; Author: Tatsiana Clifton   email: cliftota@onid.oregonstate.edu
; Course and section: CS271-400            Date: 07/17/2015
; Assignment#: 3          Due date: 07/25/2015
; Description:  This program will display author's name and the program title, 
; ask the user for the number of composites to be displayed in range [1..800], 
; validate the user input, calculate and display all composite up to the number
; entered by the user. 
;*EC: Align the output columns.
;**EC: Display more composites 800, but show them one page at a time.
; The user can “Press any key to continue …” to view the next page.
;***EC: Program prints instructions in white on blue background. 
 


INCLUDE Irvine32.inc

UPPER_LIMIT = 800                     ;upper limit for the number of composites
TAB = 9                               ;used to align the output columns

.data
progTitle     BYTE    "Composite Numbers", 0
authorName	  BYTE	  "Programmed by Tatsiana Clifton", 0
introEC1      BYTE    "*EC: Program aligns the output columns.", 0
introEC2      BYTE    "**EC: Program displays more composites, but show them one page at a time.", 0 
introEC2c     BYTE    "    The user can press any key to continue to view the next page.", 0
introEC3      BYTE    "*EC: Program prints instructions in white on blue background.", 0
instruction1  BYTE	  "Enter the number of composite numbers you would like to see.", 0
instruction2  BYTE	  "I'll accept orders for up to 400 composites. ", 0
promptComp    BYTE    "Enter the number of composites to display [1 .. 800]: ", 0
numComp  	  DWORD   ?		   	      ;number of composites to be entered by user
numberToCheck DWORD   ?               ;used to check if it is a composite number	
spaces        BYTE    "   ", 0        ;spaces to put between composites
countForTen   DWORD   ?               ;used to count 10 numbers per line
countRows     DWORD   ?               ;used to print 8 rows per page
minDivisor    DWORD   ?               ;the first number that used for trial division to check if composite
maxDivisor    DWORD   ?               ;the last number equals n-1 that used for trial division to check if composite
warning       BYTE    "Out of range. Try again.", 0
parting       BYTE    "Results certified by Tatsiana Clifton.", 0
goodBye		  BYTE	  "Good-bye. ", 0

.code
main PROC
  
    call    introduction    
	call    getUserData
	call    showComposites
	call    farewell
	
	exit	                          ;exit to operating system
main ENDP

;*******************************************
;Procedure to introduce the program
;receives: none
;returns: none
;preconditions: none
;registers changed: edx
;********************************************
introduction PROC

;Introduce programmer and program title
	mov		     edx, OFFSET progTitle
	call	WriteString
	call    CrLf
	mov		     edx, OFFSET authorName
	call	WriteString
	call	CrLf
	call    CrLf

;Display which extra credits were chosen to work on
	mov		     edx, OFFSET introEC1
	call	WriteString
	call	CrLf
	call    CrLf
	mov		     edx, OFFSET introEC2
	call	WriteString
	call    CrLf
	mov		     edx, OFFSET introEC2c
	call	WriteString
	call	CrLf
	call    CrLf
	mov		     edx, OFFSET introEC3
	call	WriteString
	call	CrLf
	call    CrLf

;Provide instructions to the user
    mov     eax, white + (blue*16)    ;white on blue color
    call    SetTextColor
    mov          edx, OFFSET instruction1
	call    WriteString
	call    CrLf
	mov          edx, OFFSET instruction2
	call    WriteString
	call    CrLf
	call    CrLf

	ret
introduction ENDP

;********************************************
;Procedure to get data from the user
;receives: none
;returns: user input value for variable numComp
;preconditions: none
;registers changed: edx, aex
;********************************************
getUserData PROC

;Get the number of composites from the user
numberComp:
    mov          edx, OFFSET promptComp
	call    WriteString
	call    ReadInt                   ;read user input
	mov     numComp, eax              ;store the input
	call    validate

	ret
getUserData ENDP

;********************************************
;Procedure to validate date from the user
;     should be in range [1..400]
;receives: none
;returns: none
;preconditions: variable numComp was assigned 
;     with user input in the getUserDate procedure
;registers changed: edx
;********************************************
validate PROC

;Validate the user input, must be more than 1 or equal
    mov     edx, numComp
	cmp     edx, 1                    ;compare the entered number with 1
	jl      errorMessage
	je      finish                    ;if number is 1 it is valid, continue
	jg      nextComparison            ;if the number more then 1, compare with 46

;Validate the user input, must be less than 400 or equal
nextComparison:
	mov     edx, numComp
	cmp     edx, UPPER_LIMIT
	jg      errorMessage
	jle     finish

;Display that out of range
errorMessage:
    mov          edx, OFFSET warning
	call    WriteString
	call    CrLf
	jmp     getUserData

finish:
	ret
validate ENDP

;********************************************
;Procedure to display composite numbers 10 per
;     line using loop
;receives: none
;returns: none
;preconditions: validated input from the user
;     for number of composite numbers
;registers changed: ecx, eax, edx, al
;********************************************
showComposites PROC

;Return default color
	mov	    eax,lightGray + (black * 16)
	call	SetTextColor
	
;Call procedure for calculation composite numbers
  
    mov     countRows, 1
	mov     countForTen, 1
    mov     numberToCheck, 4          ;first composite is 4
    mov     ecx, numComp              ;set loop count to the number of desired composites
L1:
    call    isComposite               ;call the procedure for finding a composite number

;Print the composite number
    mov     eax, numberToCheck
	call    WriteDec
	mov          edx, OFFSET spaces
	call    WriteString
	mov     al, TAB                  ;align columns
	call    WriteChar
	cmp     countForTen, 10          ;check if 10 numbers were printed
	jnl     row                      ;if yes start a new row
	inc     countForTen              ;increment the count for nembers per line
	jmp     next                     ;if not 10 numbers yet, continue without a new row
row:
	call    CrLf
	mov     countForTen, 1
	cmp     countRows, 8
    jnl     pages
	inc     countRows
	jmp     next
pages:
    call    WaitMsg                  ;the message "Press any key"
	call    Clrscr
	mov     countRows, 1
next:
    mov     eax, numberToCheck        ;restore eax, it was changed by mov al, TAB
	inc     numberToCheck             ;increment the current number in order to find next composite
	loop    L1	
	
	ret

showComposites ENDP

;********************************************
;Procedure to determine if the number is
;     a composite number
;receives: none
;returns: a composite number
;preconditions: first composite number 4 was
;     set in the showComposites procedure
;registers changed: eax, edx
;********************************************
isComposite PROC
	
;Check if it is a composite number
beginChecking:
    mov     eax, numberToCheck        ;move current number for checking if composite
	cdq
	mov     ebx, 2
	div     ebx
	mov     minDivisor, 2             ;min divisor is 2
	mov     maxDivisor, eax           ;max divisor is half of current number
testDivision:
    mov     eax, numberToCheck
	cdq
	div     minDivisor                ;divide current number by min divisor
	cmp     edx, 0                    ;compare remainder with zero
	je      finish                    ;if zero the composite number is found
	inc     minDivisor                ;increment min divisor
	mov     eax, minDivisor
	cmp     eax, maxDivisor           ;compare that min divisor not reached max divisor
	jng     testDivision              ;if not continue checking by division
    inc     numberToCheck             ;increment the number for checking
	jmp	    beginChecking             ;start checking new number

finish:        	
	ret

isComposite ENDP

;******************************************** 
;Procedure to display farewell message 
;     on console
;receives: none
;returns: none
;preconditions: none
;registers changed: edx
;******************************************** 
farewell PROC  

;Say "Good-bye" 
    call    CrLf
	call    CrLf
    mov		     edx, OFFSET parting
	call	WriteString
	call	CrLf
	mov		     edx, OFFSET goodBye
	call	WriteString
	call	CrLf

	ret
farewell ENDP

END main