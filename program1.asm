TITLE Simple Calculations   (program1.asm)

; Author: Tatsiana Clifton   email: cliftota@onid.oregonstate.edu
; Course and section: CS271-400            Date: 06/27/2015
; Assignment#: 1          Due date: 07/05/2015
; Description:  This program will display author's name and the program title, ask the user
; for two numbers, perform simple calculations with these numbers and display the results
;*EC: Program repeats until the user chooses to quit.
;**EC: Program verifies that the second number if less than the first number.
;***EC: Program calculates and displays the quotient as a floating-point number, rounded to the nearest .001.

INCLUDE Irvine32.inc

.data
progTitle     BYTE    "         Simple Calculations     ", 0
authorName	  BYTE	  "by Tatsiana Clifton ", 0
firstNum	  DWORD   ?		   	 ;first integer to be entered by user
secondNum     DWORD   ?          ;second integer to be entered by user
intro		  BYTE	  "Enter 2 numbers, and I'll show you the sum, difference, product, quotient,and remainder.", 0
introEC1      BYTE    "*EC: Program repeats until the user chooses to quit.", 0
introEC2      BYTE    "**EC: Program verifies second number less than first.", 0
introEC3      BYTE    "***EC: Program calculates and displays the quotient as a floating-point number, rounded to the nearest .001.", 0
prompt1  	  BYTE	  "First number: ", 0
prompt2	      BYTE	  "Second number: ", 0
warning1      BYTE    "The second number cannot be zero! ", 0
warning2      BYTE    "The second number must be less than the first!", 0
introForFloat BYTE    "Floating-point representation of division, rounded to the nearest .001 is: ", 0
rem           BYTE    " remainder ", 0
plus          BYTE    " + ", 0
minus         BYTE    " - ", 0
multipl       BYTE    " x ", 0
divider       BYTE    " / ", 0
equal         BYTE    " = ", 0
sum           DWORD   0          ;for storing the sum
differ        DWORD   0          ;for storing the difference
product       DWORD   0          ;for storing the product
quotient      DWORD   0          ;for storing the quotient
reminder      DWORD   0          ;for storing remainder
thousand      DWORD   1000       ;will be used for converting integer to floating-point
intForFloat   DWORD   0          ;for storing integer that will be used for floating-point representation of division
wholePart     DWORD   0          ;for storing the main part of floating-point
floatPart     DWORD   0          ;for storing the floating-point part of the number
dotSign       BYTE    ".", 0
askUser       BYTE    "Would you like to continue with different numbers. Please, enter 1 for Yes. ", 0
response      DWORD   0          ;for get the response from user if he/she wants to continue
goodBye		  BYTE	  "Good-bye!", 0

.code
main PROC

;Introduce programmer and program title
	mov		     edx, OFFSET progTitle
	call	WriteString
	mov		     edx, OFFSET authorName
	call	WriteString
	call	CrLf
	call    CrLf

;Display which extra credits were chosen to work on
    mov		     edx, OFFSET introEC1
	call	WriteString
	call    CrLf
	call    CrLf
	mov		     edx, OFFSET introEC2
	call	WriteString
	call	CrLf
	call    CrLf
	mov		     edx, OFFSET introEC3
	call	WriteString
	call	CrLf
	call    CrLf

;Get two numbers from the user
top:
    mov          edx, OFFSET intro
	call   WriteString
	call   CrLf
	call   CrLf
	mov          edx, OFFSET prompt1
	call   WriteString
	call   ReadInt               ;read user input
	mov    firstNum, eax         ;store the first input
	mov          edx, OFFSET prompt2
	call   WriteString
	call   ReadInt               ;read the second user input
	mov    secondNum, eax        ;store the second input
	call   CrLf

;Verify that the second number not equal zero
   mov     eax, secondNum
   cmp     eax, 0                ;compare second number with 0
   je      zero                  ;if the number = 0, jump to part of the program labelled "zero"
   jne     notZero               ;if the number not = 0, jump to part of the program labelled "notZero"
zero:
   mov           edx, OFFSET warning1
   call    WriteString
   call    CrLf
   call    CrLf
   jmp     toRepeat              ;jump to part of the program labelled "toRepet"

;Verify that the second number is bigger than first
notZero:
   mov     eax, secondNum
   cmp     eax, firstNum         ;compare two numbers
   jg      greater               ;if the second number is greater jump to part of the program labelled "greater"
   jle     less                  ;otherwise jump to part of the program labelled "less"
greater:
   mov           edx, OFFSET warning2
   call    WriteString
   call    CrLf
   call    CrLf
   jmp     toRepeat              ;jump to part of the program labelled "toRepet"

;Calculate and display the sum
less:
	mov    eax, firstNum
	add    eax, secondNum
	mov    sum, eax              ;store the summation
	mov    eax, firstNum
	call   WriteDec
	mov          edx, OFFSET plus
	call   WriteString
	mov          eax, secondNum   
	call   WriteDec
	mov          edx, OFFSET equal
	call   WriteString
	mov    eax, sum
	call   WriteDec
	call   CrLf

;Calculate and display the difference
    mov    eax, firstNum
	sub    eax, secondNum
	mov    differ, eax           ;store the difference
	mov    eax, firstNum
	call   WriteDec
	mov          edx, OFFSET minus
	call   WriteString
	mov    eax, secondNum   
	call   WriteDec
	mov          edx, OFFSET equal
	call   WriteString
	mov    eax, differ
	call   WriteDec
	call   CrLf

;Calculate and display the product
    mov    eax, secondNum
	mov    ebx, firstNum
	mul    ebx
	mov    product, eax          ;store the product
	mov    eax, firstNum
	call   WriteDec
	mov          edx, OFFSET multipl
	call   WriteString
	mov    eax, secondNum   
	call   WriteDec
	mov          edx, OFFSET equal
	call   WriteString
	mov    eax, product
	call   WriteDec
	call   CrLf

;Calculate and display the quotient and the reminder
    mov    eax, firstNum
    cdq
	mov    ebx, secondNum
	div    ebx
	mov    quotient, eax         ;store the quotient
	mov    reminder, edx         ;store the reminder
	mov    eax, firstNum
	call   WriteDec
	mov          edx, OFFSET divider
	call   WriteString
	mov    eax, secondNum   
	call   WriteDec
	mov          edx, OFFSET equal
	call   WriteString
	mov    eax, quotient
	call   WriteDec
	mov          edx, OFFSET rem
	call   WriteString
	mov    eax, reminder
	call   WriteDec
	call   CrLf
	call   CrLf

;Calculate and display the quotient as a floating-point number, rounded to the nearest .001.
    mov          edx, OFFSET introForFloat
    call    WriteString
    call    CrLf
    mov     eax, firstNum
	call    WriteDec
	mov          edx, OFFSET divider
	call    WriteString
	mov     eax, secondNum   
	call    WriteDec
	mov          edx, OFFSET equal
	call    WriteString
    fld     firstNum             ;load the first number onto register stack ST(0)
    fdiv    secondNum            ;divide the first number by the second and store the result in ST(0)
    fimul   thousand             ;convert into floating-point, multiply by the result in ST(0), store the product in ST(0)
    frndint                      ;round the product value in ST(0) to the nearest integer
    fistp   intForFloat          ;store the product value into variable and pop the register stack
    mov     eax, intForFloat
    cdq
    mov     ebx, thousand
    div     ebx                  ;divide the integer stored in intForFloat by 1000 to have .001 format after division
    mov     wholePart, eax       ;save the quotient 
    mov     floatPart, edx       ;save the remainder
    mov     eax, wholePart
    call    WriteDec
    mov           edx, OFFSET dotSign
    call    WriteString
    mov     eax, floatPart
    call    WriteDec
    call    CrLf
    call    CrLf

;Ask if user would like to continue with other numbers
toRepeat:
    mov           edx, OFFSET askUser
	call    WriteString
	call    ReadInt
	mov     response, eax
	call    CrLf
	cmp     eax, 1               ;check if the user response is 1
	je      top                  ;if is 1 start from the top of the program

;Say "Good-bye" if the user did not enter 1 for continuing
	mov		      edx, OFFSET goodBye
	call	WriteString
	call	CrLf

exit	                         ;exit to operating system
main ENDP

END main