TITLE NUMBER ACCUMULATOR     (haslamth.asm)            
;EC: Program foating average.

; Author: Tom Haslam
; CS271 / Program #3                 Date: 10/28/2017
; Description: Program prompts user to enter negative numbers between -100 to -1 and sums resuults

INCLUDE Irvine32.inc

; constant definitions
    max_size           EQU         <-1>                                             ;store maximum number that can be entered
    min_size           EQU         <-100>                                           ;store min number that can be entered
.data
   intro               BYTE        "ACCUMULATER", 10, \
                                    "Tom Haslam", 10, \
                                    "**EC: Calculates and ", \
                                    "displays floating point average.", \
                                    10, 0                                           ;store intro text
    terminate           BYTE        "Good Bye!, press any key to exit.", 0          ;store exit message
    name_instructs      BYTE        "Enter your name: ", 0                          ;instructions to enter username
    number_instructs    BYTE        "Please enter numbers in [-100, -1].", 10, \
                                    "Enter a non-negative number when you are ", \
                                    "finished to see results.", 0                   ;instructions for program
    number_toolow_text  BYTE        "Number too low, cannot be less than -100.", 0  ;error message when number is too low
    number_prompt       BYTE        "Enter number: ", 0                             ;store number prompt text
    number_input        SDWORD      ?                                               ;signed number entered by user
    number_sum          SDWORD      0                                               ;signed number to store running sum
    number_int_avg      SDWORD      ?                                               ;signed average as integer
    number_average      REAL8       ?                                               ;floating point average value
    ctrlWord            WORD        ?
    valid_count         DWORD       0                                               ;store count for valid input
    user_name           BYTE 64     DUP(0)                                          ;name input buffer
    greeting_prefix     BYTE        "Hello, ", 0                                    ;greeting prefix
    greeting_suffix     BYTE        "!" ,0                                          ;greeting suffix

    count_output_prefix BYTE        "You entered ", 0                               ;count output prefix
    count_output_suffix BYTE        " valid numbers." ,0                            ;count output suffix
    sum_output_prefix   BYTE        "The sum of your valid numbers is ", 0          ;sum output prefix
    avg_output_prefix   BYTE        "The rounded average is ", 0                    ;average output prefix
    flt_output_prefix   BYTE        "The floating point average is ", 0             ;floating average output prefix

.code
main PROC
    finit                           ;initialize FPU
    fstcw   ctrlWord                ;store control word in a variable
    or      ctrlWord, 010000000000b ;round down toward infinity
    fldcw   ctrlWord                ;load control word

; display title and programmers name
    mov     edx, OFFSET intro
    call    WriteString
    call    CrLf

; get user name and display instructions
    mov     edx, OFFSET name_instructs
    call    WriteString
    mov     edx, OFFSET user_name
    mov     ecx, SIZEOF user_name
    call    ReadString
    mov     edx, OFFSET greeting_prefix
    call    WriteString
    mov     edx, OFFSET user_name
    call    WriteString
    mov     edx, OFFSET greeting_suffix
    call    WriteString
    call    CrLf
    call    CrLf
    mov     edx, OFFSET number_instructs
    call    WriteString
    call    CrLf
    call    CrLf
; get number from user

GetNumber:
    mov     edx, OFFSET number_prompt
    call    WriteString
    call    ReadInt
    mov     number_input, eax

; check range, if large than max then blah
CheckRange:
    mov     eax, number_input
    cmp     eax, max_size
    jg      DisplayOutput           ;non-negative entered, all done
    cmp     eax, min_size
    jl      DisplayInvalidOutput    ;nubmer too low, display error message

; increment valid number count  
inc     valid_count

; update sum
mov     eax, number_sum
add     eax, number_input
mov     number_sum, eax

; update regular integer average
mov     edx, 0
mov     eax, number_sum
cdq                             ;fill edx register
idiv    valid_count
mov     number_int_avg, eax       

; update floating point average
fild    valid_count             ;load running sum into stack(0)
fild    number_sum              ;load running sum into stack(0)
fdiv    ST(0), ST(1)            ;divide stack(0) by valid_count, result stored in stack(0)
fstp    number_average          ;store quotient by popping stack(0) off

;jump to get next number
jmp     GetNumber

DisplayInvalidOutput:
    call    CrLf
    mov     edx, OFFSET number_toolow_text
    call    WriteString
    call    Crlf
    call    Crlf
    jmp     GetNumber

; display accumlator results
DisplayOutput:
; display counter output
    call    CrLf
    mov     edx, OFFSET count_output_prefix
    call    WriteString
    mov     eax, valid_count
    call    WriteDec
    mov     edx, OFFSET count_output_suffix
    call    WriteString
    call    Crlf
; display sum output
    mov     edx, OFFSET sum_output_prefix
    call    WriteString
    mov     eax, number_sum
    call    WriteInt
    call    Crlf
; display average output
    mov     edx, OFFSET avg_output_prefix
    call    WriteString
    mov     eax, number_int_avg
    call    WriteInt
    call    Crlf
; display average output
    mov     edx, OFFSET flt_output_prefix
    call    WriteString
    fld     number_average
    call    WriteFloat
    call    Crlf

; exit program but wait for user to press any key
ExitProgram:
    call    CrLf
    call    CrLf
    mov     edx, OFFSET terminate
    call    WriteString
    call	ReadChar
	exit	; exit to operating system

main ENDP
END main
