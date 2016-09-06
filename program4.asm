TITLE  Sorting Random Integers   (program4.asm)

; Author: Tatsiana Clifton   email: cliftota@onid.oregonstate.edu
; Course and section: CS271-400            Date: 07/29/2015
; Assignment#: 4          Due date: 08/02/2015
; Description:  This program get a user request in the range [10..200],
; generate request random integers in the range [l0..999], storing
; them in consecutive elements of an array. The program display the list
; of integers before sorting (10 numbers per line),sort the list 
; in descending order, calculate and display the median value, rounded to
; the nearest integer, and display the sorted list, 10 numbers per line.
; *EC: Round median if it is nessessary.
; *EC: Displays median on blue background.
; *EC: If the number of element is odd, median is also displyed as floating-point number.
; *EC: Generate the numbers into a file; then read the file into the array. The procedure
; OpenFile from the Irvine32 library is included because without it Visual Studio indicates 
; error: undefined symbol: OpenFile 
; *EC: Additional procedure Farewell which appears on the next screen.


INCLUDE Irvine32.inc

MIN = 10
MAX = 200
LO = 100
HI = 999
COLUMN = 10

.data
progTitle     BYTE    "Sorting Random Integers", 0
authorName	  BYTE	  "Programmed by Tatsiana Clifton", 0
intro1        BYTE    "This program generates random numbers in the range [100 .. 999],", 0
intro2        BYTE    "displays the original list, sorts the list, and calculates the", 0
intro3	      BYTE	  "median value. Finally, it displays the list sorted in descending order.", 0
introEC1      BYTE    "*EC: Round median if it is nessessary.", 0 
introEC2      BYTE    "*EC: If the number of element is odd, median is also displyed as floating-point number.", 0
introEC3      BYTE    "*EC: Generate the numbers into a file; then read the file into the array.", 0
introEC4      BYTE    "*EC: Additional procedure Farewell which appears on the next screen.", 0
promptRandInt BYTE    "How many numbers should be generated? [10 .. 200]: ", 0
request  	  DWORD   ?		   	      ;number of random integers to be entered by user
warning       BYTE    "Invalid input.", 0
array         DWORD   MAX DUP(?)      ;empty array of length MAX
titleUnsort   BYTE    "The unsorted random numbers: ", 0
titleSort     BYTE    "The sorted list:", 0
titleMed      BYTE    "The median is ", 0
titleMedFp    BYTE    "The median as floating-point is ", 0
spaces        BYTE    "   ", 0        ;spaces to put between numbers
errMsg        BYTE    "Cannot create file, using memory", 0
filename      BYTE    "output.txt",0
fileHandle    DWORD   ?	          ;handle to output file
goodBye		  BYTE	  "Good-bye.", 0

.code
main PROC

   call	    introduction

   push     OFFSET request         ;pass request by reference
   call     getUserData  
 
;Create file  
   mov           edx, OFFSET filename
   call     CreateOutputFile

;Check for errors
   cmp	    eax, INVALID_HANDLE_VALUE	;compare with special constant
   jne	    continue				   ;no errors
   jmp	    memoryUse 			   ;if error use memory
	
continue:
   mov      fileHandle, eax
   push     request                ;pass request by value  
   push     fileHandle             ;pass by value
   call     writeArray             ;output random numbers to file

;Close file
   mov      eax, fileHandle
   call     CloseFile

;Open file to read array
   mov          edx, OFFSET filename
   call     OpenFile
   cmp      eax, INVALID_HANDLE_VALUE
   jne	    continue2    		   ;no errors
   jmp	    memoryUse 			   ;if error use memory            

continue2:
   mov      fileHandle, eax
   push     SIZEOF array
   push     OFFSET array
   push     fileHandle
   call     readArray              ;read array from file
    
;Close input file
   mov      eax, fileHandle
   call     CloseFile
   
   jmp      noMemoryUse            ;skip memory use, file use was successful

memoryUse:
   mov           edx, OFFSET errMsg         
   call     WriteString
   push     request                ;pass request by value  
   push     OFFSET array
   call     fillArray

noMemoryUse:
   push     OFFSET array
   push     request
   push     OFFSET titleUnsort
   call     displayList

   push     OFFSET array
   push     request
   call     sortList

   push     OFFSET array
   push     request
   push     OFFSET titleMed
   call     displayMedian

   push     OFFSET array
   push     request
   push     OFFSET titleSort
   call     displayList

   call     farewell
   
   exit	                       ;exit to operating system
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
	
;Introduce the program
    mov          edx, OFFSET intro1
	call    WriteString
	call    CrLf
	mov          edx, OFFSET intro2
	call    WriteString
	call    CrLf
	mov          edx, OFFSET intro3
	call    WriteString
	call    CrLf
	call    CrLf

;Display which extra credits were chosen to work on
	mov		     edx, OFFSET introEC1
	call	WriteString
	call	CrLf
	mov		     edx, OFFSET introEC2
	call	WriteString
	call    CrLf
	mov		     edx, OFFSET introEC3
	call	WriteString
	call	CrLf
	mov		     edx, OFFSET introEC4
	call	WriteString
	call	CrLf
	call    CrLf

	ret
introduction ENDP

;********************************************
;Procedure to get data from the user and validate
;receives: address of a parametre on system stack
;returns: user input value for variable request
;preconditions: none
;registers changed: ebx, edx, aex
;********************************************
getUserData PROC

;Get the number of integers from the user
    push	ebp			     	   ;set up stack frame
	mov		ebp, esp
	mov		ebx, [ebp+8]		       ;get address of variable request

requestNumber:
	mov          edx, OFFSET promptRandInt
	call    WriteString
	call	ReadInt                ;read user input
	cmp     eax, MIN               ;compare entered number to min
	jl      outRange               ;jump to display out of range message
	cmp     eax, MAX               ;compare entered number to max
	jg      outRange               ;jump to display out of range message
	jmp     finish
	
outRange:
    mov          edx, OFFSET warning
	call    WriteString
	call    CrLf
	jmp     requestNumber

finish:
	mov		[ebx], eax			   ;Store user input at address in ebx
	pop		ebp					   ;Restore stack

	ret 4
getUserData ENDP

;*******************************************
;Procedure to open file 
;Source: K. Irvine, Assembly Language, p. 468
;receives: edx point to file name
;returns: eax with file handle if success
; INVALID_HANDLE_VALUE otherwise
;preconditions: none
;registers changed: edx
;********************************************
OpenFile PROC

    INVOKE  CreateFile,
        edx, GENERIC_READ, DO_NOT_SHARE, NULL,
        OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0

    ret
OpenFile        ENDP

;*******************************************
;Procedure to write an array with random numbers
;          to file
;receives: value of request, value of fileHandle
;            on system stack
;returns: none
;preconditions: created file
;registers changed: ecx, edx, eax
;********************************************
writeArray PROC

    push	ebp
	mov	    ebp, esp
	sub     esp, 4                 ;reserve space for local variable
	mov	    ecx, [ebp+12]		   ;request(count) in ecx
	call    Randomize              ;to get different number each time the program runs

again:
    mov     eax, HI                ;move upper limit
	sub     eax, LO                ;subtract lower limit to get range
	call    RandomRange
	add     eax, LO  
	mov     DWORD PTR [ebp-4], eax ;assign generated value to local variable

	push    ecx

;Write number to file
    mov	    eax, [ebp+8]	       ;fileHandle in eax 
	lea     edx, DWORD PTR [ebp-4] ;load address of local variable into edx
	mov     ecx, TYPE DWORD   
	call    WriteToFile

	pop     ecx
	loop    again               

	mov  esp, ebp
	pop ebp
    ret 8
writeArray ENDP

;*******************************************
;Procedure to read an array with random numbers
;          from file
;receives: value of fileHandle, address of array,
;          size of array on system stack
;returns: array with data from file
;preconditions: file with data
;registers changed: eax, edx, ecx
;********************************************
readArray PROC

    push	ebp
	mov	    ebp, esp
	mov	    eax, [ebp+8]		   ;fileHandle in eax
	mov	    edx, [ebp+12]		   ;address of array in edx
	mov     ecx, [ebp+16]          ;size of array
	call    ReadFromFile                  

	pop ebp
    ret 12
readArray ENDP

;*******************************************
;Procedure to fill an array with random numbers
;receives: value of request, address of array
;            on system stack
;returns: array with random numbers
;preconditions: constants are declared
;registers changed: ecx, edi, eax
;********************************************
fillArray PROC

    push	ebp
	mov	    ebp, esp
	mov	    edi, [ebp+8]		   ;address of array in edi
	mov	    ecx, [ebp+12]		   ;request(count) in ecx
	call    Randomize

again:
    mov     eax, HI                ;move upper limit
	sub     eax, LO                ;subtract lower limit to get range
	call    RandomRange
	add     eax, LO  
	mov     [edi], eax             ;move random number into array
	add     edi, 4                 ;move to the next position in array 
	loop    again                  

	pop ebp
    ret 8
fillArray ENDP

;*******************************************
;Procedure to display an array
;receives: value of request, address of array 
;          and title on system stack
;returns: none
;preconditions: array was filled with numbers
;registers changed: edi, ecx, edx, ebx
;********************************************
displayList PROC

    push    ebp
	mov     ebp, esp
	mov     edi, [ebp+16]          ;address of array in edi
	mov     ecx, [ebp+12]          ;request(count) in ecx
	mov     edx, [ebp+8]           ;address of title in edx
	call    CrLf
	call    WriteString            ;display title
	call    CrLf
	mov     ebx, 0                 ;used to count 10 per row

again:
	mov     eax, [edi]             ;move address of array into eax
	call    WriteDec               ;print the element
	mov          edx, OFFSET spaces
	call    WriteString
	inc     ebx
	cmp     ebx, 10
	jl      continue
	call    CrLf                   ;new line
	mov     ebx, 0                 ;set ebx to 0 because new line   

continue:
	add     edi, 4
	loop    again

    call    CrLf      

    pop     ebp
	ret 12		
 displayList ENDP

;*******************************************
;Procedure to sort the array using bubble sort
;Source: K. Irvine, Assembly Language, p. 375 
;receives: value of request, address of array
;            on system stack
;returns: sorted array
;preconditions: array filled with numbers
;registers changed: ecx, esi, eax, edi
;********************************************
sortList PROC

    push    ebp
	mov     ebp, esp
	mov     ecx, [ebp+8]               ;count for sort
    dec     ecx                          ;decrement count

outerLoop:
    push    ecx                          ;save loop count, it for outer loop
    mov     esi, [ebp+12]              ;address of array in ebx, for first element

innerLoop:
    mov     eax, [esi]                    ;move value from the array to eax
    cmp     [esi+4], eax                  ;compare the value with the next
	jbe     withoutExchange               ;do not need to swap
	push    esi                           ;push the current element
	mov     edi, esi                      ;move it to edi
	add     edi, 4                        ;move to the next element
	push    edi                           ;push it
	call    exchange                      ;if exchange needed call the exchange procedure                 

withoutExchange:
    add     esi, 4                        ;move to the next
    loop    innerLoop                     ;compare next value

	pop     ecx                           ;restore outer loop count
	loop    outerLoop                     ;start from the beginning of array
	
	pop     ebp

    ret 8
sortList ENDP


;*******************************************
;Procedure to exchange elements of the array
;receives: addresses of two array elements
;            on system stack
;returns: none
;preconditions: none
;registers changed: eax, ebx, ecx, edx
;********************************************
exchange PROC
    
	push    ebp
	mov     ebp, esp
	pushad
	mov     eax, [ebp+12]			;address of i element
	mov     ecx, [eax]              ;ecx contains first element
	mov     ebx, [ebp+8]			;address of j element
	mov		edx, [ebx]              ;edx contains second element

;exchange values 
	mov		edx, [ebx]
	mov		[eax], edx
	mov 	[ebx], ecx
	
	popad
	pop     ebp
 
    ret 8
exchange ENDP


;*******************************************
;Procedure to display median
;receives: value of request, address of array
;          and title on system stack
;returns: none
;preconditions: array with data
;registers changed: edx, ebx, eax, esi
;********************************************
displayMedian PROC

    push    ebp
	mov     ebp, esp
	mov     esi, [ebp+16]           ;address of array in edi
	mov     edx, [ebp+8]            ;address of title in edx
	mov     eax, white + (blue*16)    ;white on blue color
    call    SetTextColor
	call    CrLf
	call    WriteString             ;display title
	call    CrLf
	mov     eax, [ebp+12]           ;request(count) in ecx
	cdq
	mov	    ebx, 2                  ;divide number of element by 2
	div	    ebx
	cmp     edx, 0
	jg      odd                     ;odd number of element, median is one in the middle


    mov     ebx, 4                  ;because array of DWORDs
    mul     ebx                     ;eax after division by 2 has the index of one element for median, multiply it by 4
    add     esi, eax		        ;add to the beginning of the array 
    mov     eax, [esi]              ;move the address of median into eax
	add     eax, [esi-4]            ;add previous element to calculate median
	mov	    ebx, 2                  ;divide number of element by 2
	div     ebx

;Check if median needs to be rounded	
	cmp     edx, 1			        ;compare remainder with 1
	jb      noRound		            ;if less then one do not need to roun up
    inc     eax				        ;if equal or more round the number incrementing it by 1	

noRound:	
	call    WriteDec	            ;print median
    call    CrLf
	jmp     finish

odd: 
    mov     ebx, 4                  ;because array of DWORDs
    mul     ebx                     ;eax after division by 2 has the index of median, multiply it by 4
    add     esi, eax		        ;add to the beginning of the array 
    mov     eax, [esi]              ;move the address of median into eax
	call    WriteDec
	call    CrLf
	mov          edx, OFFSET titleMedFp
	call    WriteString
	fild    dword ptr [esi]
    call    WriteFloat	            ;print median
    call    CrLf
	
finish:
    mov	    eax,lightGray + (black * 16)
	call	SetTextColor
	pop  ebp

	ret  12 
displayMedian ENDP

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
    call    WaitMsg                  ;the message "Press any key"
	call    Clrscr
	mov     dh, 10
	mov     dl, 20
	call    Gotoxy
    call    CrLf
	mov		     edx, OFFSET goodBye
	call	WriteString
	call	CrLf

	ret
farewell ENDP

END main