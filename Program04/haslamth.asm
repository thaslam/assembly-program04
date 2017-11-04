TITLE COMPOSITE NUMBERS     (haslamth.asm)            
;EC: Program foating average.

; Author: Tom Haslam
; CS271 / Program #4                 Date: 11/04/2017
; Description: Write a program that computes composite numbers based on the number input bu the user

INCLUDE Irvine32.inc

; constant definitions
   numbers_per_line     EQU         <10>
.data
    program_title       BYTE        "Composite Numbers     Programmed by Tom Haslam", 10, 0             ; store program title to output
    instructions        BYTE        "Enter the number of composite numbers you would like to see.", \
                                    10, "I can accept orders for up to 400 composites.", 10, 10, 0      ; store instructions for the program
    terminate           BYTE        "Good Bye!, press any key to exit.", 0                              ; store exit message
    invalid_input       BYTE        "Out of range.  Try again.", 0                                      ; store error for invalid input
    prompt_count        BYTE        "Enter the number of composites to display [1 .. 400]: ", 0         ; store input prompt text
    found_text          BYTE        "Yes", 0            
    spaces              BYTE        "     ", 0                                                          ; store padding betweeen numbers
    input_count         DWORD       ?                                                                   ; store composite # count
    count               DWORD       0
    line_count          DWORD       0                               
.code
main PROC

; show program title in intro instructions
call    introduction

; collect input from the user
call    getUserData
    mov     input_count, eax
    mov     ecx, 0
NextNumber:
    inc     ecx
    mov     eax, count
    cmp     eax, input_count
    jge     ExitProgram

    push    ecx
    push    ecx
    call    isComposite
    pop     ecx                                 ; here we want to restore the ecx counter after proc returns
    cmp     al, 1
    je      CompositeFound                      ; write composite output to screen
    jmp     NextNumber                          ; loop next number

; write found composite number to screen update global counters
CompositeFound:
    inc     count
    inc     line_count
    mov     eax, ecx
    call    WriteDec
    mov     edx, OFFSET spaces
    call    WriteString

; check how many numbers we have written per line, if 10 start new line
    mov     edx, 0
    mov     eax, line_count
    mov     ebx, numbers_per_line
    div     ebx
    cmp     edx, 0
    je      WriteNewLine
    jmp     NextNumber

WriteNewLine:
    call    Crlf
    mov     line_count, 0
    jmp     NextNumber

; exit program but wait for user to press any key
ExitProgram:
    call    farewell
main ENDP

introduction PROC
; output title of the program
    mov     edx, OFFSET program_title
    call    WriteString
    call    Crlf

; output program instructions
    mov     edx, OFFSET instructions
    call    WriteString
    ret
introduction ENDP
    
farewell PROC
    call    CrLf
    call    CrLf
    mov     edx, OFFSET terminate
    call    WriteString
    call	ReadChar
	exit	; exit to operating system
    ret
farewell ENDP
getUserData PROC
PromptNumberInput:
    mov     edx, OFFSET prompt_count
    call    WriteString
    call    ReadInt
    push    eax
    call    validateNumberInput
    cmp     eax, 0                              ; check valid return flag, if 1 then invalid
    jle     PromptNumberInput
    ret
getUserData ENDP

validateNumberInput PROC
    push    ebp
    mov     ebp, esp
    mov     eax, [esp+8]
    cmp     eax, 400
    jg      ShowInvalidInputErrorMessage
    cmp     eax, 1
    jl      ShowInvalidInputErrorMessage
    mov     eax, [esp+8]                        ; set eax to original number
    jmp     ExitProc                            ; jump to exit procedure
ShowInvalidInputErrorMessage:
    mov     edx, OFFSET invalid_input
    call    WriteString
    call    Crlf
    mov     eax, 0                              ; set eax to zero to indicate invalid number    
ExitProc:
    pop     ebp
    ret     4                                   ; cleanup the stack
validateNumberInput ENDP

isComposite PROC
    push    ebp
    mov     ebp, esp
    mov     ecx, 1                              ; default to 1 so first increment starts us at two

CheckNextNumber:
    inc     ecx                                 ; increment factor counter;

; divide current number by factor
    mov     edx, 0
    mov     eax, [esp+8]                        ; set number parameter value for division
    div     ecx

; check for factor
    cmp     edx, 0                              ; check modulus to determine if not prime
    je      AndCheckThatQuotientIsNot1          ; this avoids numbers like 2 from returning true
    jmp     CheckIfDoneSearching                ; here we have a fraction, so jump to check if we should check next number
AndCheckThatQuotientIsNot1:
    cmp     eax, 1
    jne     Found

; check if we hit the potential max factor
CheckIfDoneSearching:
    cmp     ecx, eax                            ; check against max factor we could potentially have, max factory cannot be greater (number)/(iterator count)
    mov     al, 0
    jge     ExitProc

; check next number
    jmp     CheckNextNumber

Found:
    mov     al, 1                               ; set return true flag that composite found

ExitProc:
    pop     ebp
    ret     4
isComposite ENDP
END main
