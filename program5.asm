TITLE  Designing low-level I/O procedures   (program5a.asm)

; Author: Tatsiana Clifton   email: cliftota@onid.oregonstate.edu
; Course and section: CS271-400            Date: 08/04/2015
; Assignment#: 5a          Due date: 08/09/2015
; Description:  This program gets 10 valid integers from the user,
; stores the numeric values in an array. The program then displays
; the integers, their sum, and their average.
; *EC: Number each line of user input.
; NOTE: The average is rounded up if remainder =>5, otherwise down

INCLUDE Irvine32.inc

ARRAYSIZE = 10
MAX = 15

getString MACRO string, prompt               ;source: Lecture 26

;Save registers
   push    ecx
   push    edx

   mov     edx, OFFSET prompt
   call    WriteString

   mov     edx, OFFSET string
   mov     ecx, (SIZEOF string)- 1
   call    ReadString

;Restore registers
   pop    edx
   pop    ecx

ENDM

displayString MACRO string                   ;source: Lecture 26

;Save register
   push    edx

   mov    edx, string
   call   WriteString

;Restore register
   pop    edx

ENDM

.data
progTitle     BYTE    "Designing low-level I/O procedures", 0dh, 0ah, 0
authorName	  BYTE	  "Programmed by Tatsiana Clifton", 0dh, 0ah, 0, 0bh
intro         BYTE    "Please provide 10 unsigned decimal integers.", 0dh, 0ah
              BYTE    "Each number needs to be small enough to fit inside a 32 bit register.", 0dh, 0ah
     	      BYTE	  "After you have finished inputting the raw numbers I will display ", 0dh, 0ah
    	      BYTE	  "a list of the integers, their sum, and their average value.", 0dh, 0ah, 0
introEC       BYTE    "*EC: Number each line of user input.", 0 
userInput  	  BYTE    MAX DUP(?)		   	      ;to be entered by user
inputSize     DWORD   0
stringInput   BYTE    MAX DUP(?)                  ;to store string of numbers for conversion
promptNumber  BYTE    "Please enter an unsigned number: ", 0
warning       BYTE    "ERROR: You did not enter an unsigned number or your number was too big.", 0dh, 0ah
              BYTE	  "Please try again: ", 0
secondPrompt  BYTE    "Please try again: ", 0dh, 0ah, 0
array         DWORD   ARRAYSIZE DUP(?)            ;empty array 
lineNumber    DWORD   0                           ;used to number lines of user input
strIntro      BYTE    "You entered the following numbers: ", 0dh, 0ah, 0
sum           DWORD    ?                          ;to store the sum of numbers
avg           DWORD    ?                          ;to store the average of numbers
sumIntro      BYTE    "The sum of these numbers is: ", 0
avgIntro      BYTE    "The average is: ", 0
dotSign       BYTE    ". ", 0
commaSign     BYTE     ", ", 0
goodBye		  BYTE	  "Thanks for playing!", 0dh, 0ah, 0

.code
main PROC

;Display introduction
   displayString OFFSET progTitle      ;title
   displayString OFFSET authorName     ;name of the author
   call    CrLf                           ;new line
   displayString OFFSET intro          ;introduction for the program
   call    CrLf
   displayString OFFSET introEC 
   call    CrLf

;Get 10 numbers from the user
   call    CrLf
   mov     ecx, ARRAYSIZE                 ;set counter to 10 numbers
L1:
   push    inputSize                      ;push the size of input string by value
   push    OFFSET dotSign                 ;push the dot sign by address
   push    OFFSET array                   ;push the address of array
   push    lineNumber                     ;push lineNumber by value
   call    ReadVal                        ;call the procedure to get value from the user
   inc     lineNumber                     ;increment the line number
   loop    L1                             ;loop to get the next number

;Calculate results
   push    OFFSET array		              ;push the address of array
   push    ARRAYSIZE		              ;push the size of array by value
   push    OFFSET sum		              ;push the address of variable to hold the sum
   push    OFFSET avg		              ;push the address of variable to hold average
   call    calculate                      ;call the procedure to find sum and average

;Display results
   call    CrLf                           ;new line
   push    OFFSET commaSign               ;push by address comma sign
   push    SIZEOF stringInput	          ;push the size of input string          
   push    OFFSET stringInput		      ;push the address of input string
   push    OFFSET strIntro	              ;push the address of intro to string with numbers
   push    OFFSET array		              ;push the address of array
   push    ARRAYSIZE			          ;push by value size of array	
   push    OFFSET sumIntro		          ;push by address intro for sum
   push    sum			                  ;push by value sum	
   push    OFFSET avgIntro	              ;push by address intro for average
   push    avg			                  ;push by value avg
   call    display                        ;call the procedure to display results

;Display farewell message
   call    CrLf
   displayString OFFSET goodBye

   exit	                                  ;exit to operating system
main ENDP

;*******************************************
;Procedure to get the user’s string of digits.
;It then converts the digit string to numeric,
;while validating the user’s input.
;receives: value of number of line, value of
;string length, the address of dot sign, and
;the address of array on system stack 
;returns:none
;preconditions: macros are written 
;registers changed: eax, ecx, esi, edx, ebx
;********************************************
readVal PROC
     
   pushad                                 ;save all registers
   mov       ebp, esp
   mov       eax, [ebp+36]                ;set eax to the current number of lines
   inc       eax                          ;increment number of line for user input
   call      WriteDec                     ;display number of line
   displayString   [ebp+44]               ;put the dot after the number of line
   getString userInput, promptNumber      ;call macro to get number from the user
   jmp       validate                     ;jump to code to validate number

error:                                   
   getString userInput, warning           ;display error message and call macro to get number from the user

validate:
   mov       [ebp+48], eax                ;move the number of characters that were entered
   mov       ecx, eax                     ;set the loop counter to number of characters
   mov       esi, OFFSET userInput
	 	 
next:                                     
   lodsb                                  ;load byte from esi to al
   cmp       al, '0'                      ;compare content of al to 0 
   jb        notNumber                    ;if less than 48 it is not a number
   cmp       al, '9'                      ;compare content of al to 9
   ja        notNumber                    ;if greater than 57 it is not a number
   loop      next                         ;check next character
   jmp       validated                    ;it is a number

notNumber:                                 
   jmp       error                        ;display error and prompt for another number

validated:
   mov       edx, OFFSET userInput        ;move the address on entered string to edx
   mov       ecx, [ebp+48]                ;move the size of entered string to ecx
   call      ParseDecimal32               ;convert an unsigned decimal integer to 32-bit binary             
   jc        error                        ;check if carry flag is set; if it is the number too big, start over
   mov       edx, [ebp+40]                ;move the address of array into edx
   mov       ebx, [ebp+36]                ;set ebx to the current number of lines
   imul      ebx, TYPE DWORD              ;multiply the count by size of dword to see where to place it
   mov       [edx+ebx], eax               ;add value into array at the correct position

   popad                                  ;restore all registers
   ret 16    				
readVal ENDP

;*******************************************
;Procedure to convert a numeric value to 
;a string of digits, and invoke 
;displayString macro to produce the output.
;receives: string length, number, address of
;of string on system stack 
;returns: none
;preconditions: macro is written
;registers changed: eax, edi, eax, ebx
;********************************************
writeVal PROC

   pushad                                 ;save all registers
   mov       ebp, esp	
   
   mov       eax, [ebp+36]	              ;move the number into eax
   mov       edi, [ebp+40]	              ;move the address of string where converted will be stored
   add       edi, [ebp+44]                ;add string length to edi
   dec       edi                          ;room for null character
   std                                    ;set direction flag (move reverse direction)
   push      eax                          ;push eax to save the number
   mov       al, 0                        ;move zero to al
   stosb                                  ;move 0 from al to location pointed by edi (end of string)
   pop       eax                          ;pop eax to restore the number
again:
   cdq
   mov       ebx, 10                      ;set divisor to 10
   div       ebx                          ;divide number by 10 to convert by single digit
   add       edx, 48                      ;add 48 to quotient to convert in to character
   push      eax                          ;save quotient
   mov       eax, edx                     ;move reminder to eax to get next digit
   stosb                                  ;move digit to location pointed by edi (string)
   pop       eax                          ;pop eax to restore quotient
   cmp       eax, 0                       ;if quotient is zero no more digits
   jne       again                        ;if there are digits continue

   inc       edi                          ;get string 
   displayString edi                      ;call macro to print string
   
   popad
   ret	12	
writeVal ENDP

;*******************************************
;Procedure to calculate sum and average
;receives: address of array, value of array
;size, address of variable sum, address of 
;variable average on system stack
;returns: stores the sum and average in variables
;preconditions: array with numbers 
;registers changed: edi, ecx, ebx, eax 
;********************************************
calculate PROC
  
   pushad				                  ;save all registers
   mov    ebp, esp			

;Calculate the sum  
   mov    edi, [ebp+48]	                  ;move the address of array 
   mov    ecx, [ebp+44]		              ;set loop counter to array size
   mov    eax, [ebp+40]		              ;move the address of sum			
   mov    ebx, 0				          ;set ebx equals 0
addMore:
   add    ebx, [edi]		              ;add number
   add    edi, TYPE DWORD	              ;move to next element of array
   loop   addMore
   
   mov    [eax], ebx			          ;store the sum 

;Calculate the avarege
   mov    eax, ebx			              ;move the sum to eax
   mov    ebx, [ebp+44]		              ;move array size to ebx
   cdq
   div    ebx				              ;divide the sum by the size of array
   cmp    edx, 5			              ;compare remainder with 5
   jb     noRound		                  ;if less then 5 do not need to roun up
   inc    eax				              ;if equal or more round the number incrementing eax by 1	
noRound:	
   mov    ebx, [ebp+36]		              ;mov the address of the variable for holding average
   mov    [ebx], eax		              ;store the result in variable avg
   
   popad					              ;restore registers
   ret 16					              ;remove additional 16 bytes from the stack
calculate ENDP

;*******************************************
;Procedure to display sum and average
;receives: addresses of string input, intro 
;strings, array, variable sum and average,
;comma sign, value size of string on system stack 
;returns: none 
;preconditions: macro is written 
;registers changed: edi, ecx
;********************************************
display PROC
	
   pushad                                 ;save all registers
   mov    ebp, esp
   displayString [ebp+60]	              ;pass address of string to macro to display it
   mov    edi, [ebp+56]		              ;mov the address of array to edi
   mov    ecx, [ebp+52]		              ;set loop counter to size of array

more:
   push   [ebp+68]		                  ;push the size of string with numbers
   push   [ebp+64]			              ;push the address of string with numbers
   push   [edi]				              ;push current value from array onto stack
   call   writeVal		                  ;call the procedure to print current element of array
   add    edi, TYPE DWORD				  ;move to the next element
   
   cmp    ecx, 1                          ;compare loop counter to 1
   je     print			                  ;if equals 1 skip printing the comma because it is last element
   displayString [ebp+72]                 ;if not last element print the comma
   loop   more				              ;start again to print next value

print:
   call   CrLf                            ;new line
   displayString [ebp+48]	              ;pass address of string to macro to display sum intro
   push   [ebp+68]                        ;push the size of string with numbers
   push   [ebp+64]				          ;push the address of string with numbers
   push   [ebp+44]				          ;push the address of sum
   call   writeVal				          ;call the procedure to print sum
   call   CrLf                            ;new line
   
   displayString [ebp+40]		          ;pass address of string to macro to display sum intro
   push   [ebp+68]                        ;push the size of string with numbers
   push   [ebp+64]				          ;push the address of string with numbers
   push   [ebp+36]				          ;push the address of avg
   call   writeVal				          ;call the procedure to print average
   call   CrLf                            ;new line
   
   popad					              ;restore registers
   ret 40					             	
display ENDP

END main