.MODEL SMALL
.STACK 100H

.DATA

TASK_TITLES DB 400 DUP('$')   ; 20 * 20
TASK_PRIORITIES DB 20 DUP(0)
TASK_STATUS DB 20 DUP(0)
TASK_ACTIVE DB 20 DUP(0)
TASK_IDS DB 20 DUP(0)
TASK_COUNT DW 0

DESC_BUFFER DB 2048 DUP('$')
DESC_POINTER DW 0
TASK_DESC_OFFSETS DW 20 DUP(0)

LAST_DELETED_INDEX DW 0FFFFH

DIGIT_ARRAY DB 10 DUP(0)
TEMP_CX_SORT DW 0
TEMP_BX_SORT1 DW 0
TEMP_BX_SORT2 DW 0
TEMP_CX_SORT2 DW 0
TEMP_BX_UPDATE1 DW 0
TEMP_BX_UPDATE2 DW 0
TEMP_AX_FILTER DW 0
TEMP_AX_PRINT_STR DW 0
TEMP_AX_PRINT_CHAR DW 0
TEMP_AX_NEWLINE DW 0
TEMP_DX_NEWLINE DW 0
TEMP_AX_PRINT_TASK DW 0
TEMP_CX_PRINT_TASK DW 0
TEMP_DX_PRINT_TASK DW 0
TEMP_BX_PRINT_TASK1 DW 0
TEMP_BX_PRINT_TASK2 DW 0
TEMP_BX_RN DW 0
TEMP_CX_RN DW 0
TEMP_DX_RN DW 0
TEMP_AX_RN_MUL DW 0
TEMP_AX_PN DW 0
TEMP_BX_PN DW 0
TEMP_CX_PN DW 0
TEMP_DX_PN DW 0
TEMP_SI_PN DW 0
TEMP_AX_RS DW 0
TEMP_CX_RS DW 0
TEMP_DI_RS DW 0
TEMP_AX_RDS DW 0
TEMP_DI_RDS DW 0

menu_msg DB 0DH, 0AH, "--- SMART TASK PLANNER ---", 0DH, 0AH
         DB "1. Add Task", 0DH, 0AH
         DB "2. View All Tasks", 0DH, 0AH
         DB "3. Search Task by ID", 0DH, 0AH
         DB "4. Sort Tasks by Priority", 0DH, 0AH
         DB "5. Mark Task Completed", 0DH, 0AH
         DB "6. Delete Task", 0DH, 0AH
         DB "7. Undo Last Delete", 0DH, 0AH
         DB "8. Update Task", 0DH, 0AH
         DB "9. Filter by Priority", 0DH, 0AH
         DB "0. Exit", 0DH, 0AH
         DB "Select choice: $"

prompt_title DB "Enter Task Title (max 19 chars): $"
prompt_pri DB "Enter Priority (1=Low, 2=Med, 3=High): $"
prompt_desc DB "Enter Description (Press ENTER to finish): $"
prompt_id DB "Enter Task ID: $"
msg_added DB "Task Added successfully! ID is: $"
msg_not_found DB "Task not found!$"
msg_deleted DB "Task deleted!$"
msg_undo DB "Undo successful! Task restored.$"
msg_no_undo DB "Nothing to undo!$"
msg_done DB "Task marked as completed!$"
msg_sorted DB "Tasks sorted by priority!$"
msg_full DB "Task list is full!$"
msg_pending DB " [Pending] $"
msg_completed DB " [Done] $"
msg_p1 DB " (Low Priority)$"
msg_p2 DB " (Medium Priority)$"
msg_p3 DB " (High Priority)$"
msg_id_label DB "ID: $"
msg_title_label DB " | Title: $"
msg_desc_label DB " | Desc: $"
msg_inv_choice DB "Invalid choice!$"
msg_line DB "----------------------------------------$"

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX

main_loop:
    CALL NEWLINE_PROC
    LEA DX, menu_msg
    CALL PRINT_STR_PROC
    
    MOV AH, 01H
    INT 21H
    
    CMP AL, '1'
    JE ADD_TASK
    CMP AL, '2'
    JE VIEW_ALL
    CMP AL, '3'
    JE SEARCH_TASK
    CMP AL, '4'
    JE SORT_TASKS
    CMP AL, '5'
    JE MARK_DONE
    CMP AL, '6'
    JE DELETE_TASK
    CMP AL, '7'
    JE UNDO_DELETE
    CMP AL, '8'
    JE UPDATE_TASK
    CMP AL, '9'
    JE FILTER_TASK
    CMP AL, '0'
    JE EXIT_PROGRAM
    
    CALL NEWLINE_PROC
    LEA DX, msg_inv_choice
    CALL PRINT_STR_PROC
    CALL NEWLINE_PROC
    JMP main_loop

ADD_TASK:
    MOV AX, TASK_COUNT
    CMP AX, 20
    JGE task_full
    
    CALL NEWLINE_PROC
    LEA DX, prompt_title
    CALL PRINT_STR_PROC
    MOV AX, TASK_COUNT
    MOV BX, 20
    MUL BX
    LEA DI, TASK_TITLES
    ADD DI, AX
    MOV CX, 19
    CALL READ_STRING
    
    CALL NEWLINE_PROC
    LEA DX, prompt_pri
    CALL PRINT_STR_PROC
    CALL READ_NUMBER
    MOV BX, TASK_COUNT
    MOV TASK_PRIORITIES[BX], AL
    
    CALL NEWLINE_PROC
    LEA DX, prompt_desc
    CALL PRINT_STR_PROC
    MOV AX, DESC_POINTER
    MOV BX, TASK_COUNT
    SHL BX, 1
    MOV TASK_DESC_OFFSETS[BX], AX
    CALL READ_DYNAMIC_STRING
    
    MOV BX, TASK_COUNT
    MOV TASK_STATUS[BX], 0
    MOV TASK_ACTIVE[BX], 1
    MOV AX, TASK_COUNT
    INC AX
    MOV TASK_IDS[BX], AL
    
    CALL NEWLINE_PROC
    LEA DX, msg_added
    CALL PRINT_STR_PROC
    MOV AL, TASK_IDS[BX]
    XOR AH, AH
    CALL PRINT_NUMBER
    CALL NEWLINE_PROC
    
    INC TASK_COUNT
    JMP main_loop
    
task_full:
    CALL NEWLINE_PROC
    LEA DX, msg_full
    CALL PRINT_STR_PROC
    CALL NEWLINE_PROC
    JMP main_loop

VIEW_ALL:
    CALL NEWLINE_PROC
    LEA DX, msg_line
    CALL PRINT_STR_PROC
    CALL NEWLINE_PROC
    MOV CX, TASK_COUNT
    CMP CX, 0
    JE va_end
    MOV BX, 0
va_loop:
    CMP TASK_ACTIVE[BX], 1
    JNE va_next
    CALL PRINT_TASK
va_next:
    INC BX
    LOOP va_loop
va_end:
    LEA DX, msg_line
    CALL PRINT_STR_PROC
    CALL NEWLINE_PROC
    JMP main_loop

SEARCH_TASK:
    CALL NEWLINE_PROC
    LEA DX, prompt_id
    CALL PRINT_STR_PROC
    CALL READ_NUMBER
    CALL FIND_TASK_BY_ID
    CMP BX, 0FFFFh
    JE st_not_found
    CALL PRINT_TASK
    JMP main_loop
st_not_found:
    CALL NEWLINE_PROC
    LEA DX, msg_not_found
    CALL PRINT_STR_PROC
    CALL NEWLINE_PROC
    JMP main_loop

SORT_TASKS:
    MOV CX, TASK_COUNT
    DEC CX
    CMP CX, 0
    JLE sort_end
sort_outer:
    MOV TEMP_CX_SORT, CX
    MOV BX, 0
sort_inner:
    MOV AL, TASK_PRIORITIES[BX]
    MOV DL, TASK_PRIORITIES[BX+1]
    CMP AL, DL
    JGE sort_skip
    
    ; swap priorities
    MOV TASK_PRIORITIES[BX], DL
    MOV TASK_PRIORITIES[BX+1], AL
    
    ; swap status
    MOV AL, TASK_STATUS[BX]
    MOV DL, TASK_STATUS[BX+1]
    MOV TASK_STATUS[BX], DL
    MOV TASK_STATUS[BX+1], AL
    
    ; swap active
    MOV AL, TASK_ACTIVE[BX]
    MOV DL, TASK_ACTIVE[BX+1]
    MOV TASK_ACTIVE[BX], DL
    MOV TASK_ACTIVE[BX+1], AL
    
    ; swap ids
    MOV AL, TASK_IDS[BX]
    MOV DL, TASK_IDS[BX+1]
    MOV TASK_IDS[BX], DL
    MOV TASK_IDS[BX+1], AL
    
    ; swap offsets
    MOV TEMP_BX_SORT1, BX
    SHL BX, 1
    MOV AX, TASK_DESC_OFFSETS[BX]
    MOV DX, TASK_DESC_OFFSETS[BX+2]
    MOV TASK_DESC_OFFSETS[BX], DX
    MOV TASK_DESC_OFFSETS[BX+2], AX
    MOV BX, TEMP_BX_SORT1
    
    ; swap titles
    MOV TEMP_BX_SORT2, BX
    MOV TEMP_CX_SORT2, CX
    MOV AX, BX
    MOV CX, 20
    MUL CX
    LEA DI, TASK_TITLES
    ADD DI, AX
    MOV SI, DI
    ADD SI, 20
    MOV CX, 20
swap_title_loop:
    MOV AL, [DI]
    MOV DL, [SI]
    MOV [DI], DL
    MOV [SI], AL
    INC DI
    INC SI
    LOOP swap_title_loop
    MOV CX, TEMP_CX_SORT2
    MOV BX, TEMP_BX_SORT2
    
sort_skip:
    INC BX
    LOOP sort_inner
    MOV CX, TEMP_CX_SORT
    LOOP sort_outer
sort_end:
    CALL NEWLINE_PROC
    LEA DX, msg_sorted
    CALL PRINT_STR_PROC
    CALL NEWLINE_PROC
    JMP main_loop


DELETE_TASK:
    CALL NEWLINE_PROC
    LEA DX, prompt_id
    CALL PRINT_STR_PROC
    CALL READ_NUMBER
    CALL FIND_TASK_BY_ID
    CMP BX, 0FFFFh
    JE del_not_found
    
    MOV TASK_ACTIVE[BX], 0
    MOV LAST_DELETED_INDEX, BX
    CALL NEWLINE_PROC
    LEA DX, msg_deleted
    CALL PRINT_STR_PROC
    CALL NEWLINE_PROC
    JMP main_loop
del_not_found:
    CALL NEWLINE_PROC
    LEA DX, msg_not_found
    CALL PRINT_STR_PROC
    CALL NEWLINE_PROC
    JMP main_loop

UNDO_DELETE:
    CMP LAST_DELETED_INDEX, 0FFFFH
    JE no_undo
    MOV BX, LAST_DELETED_INDEX
    MOV TASK_ACTIVE[BX], 1
    MOV LAST_DELETED_INDEX, 0FFFFH
    CALL NEWLINE_PROC
    LEA DX, msg_undo
    CALL PRINT_STR_PROC
    CALL NEWLINE_PROC
    JMP main_loop
no_undo:
    CALL NEWLINE_PROC
    LEA DX, msg_no_undo
    CALL PRINT_STR_PROC
    CALL NEWLINE_PROC
    JMP main_loop

UPDATE_TASK:
    CALL NEWLINE_PROC
    LEA DX, prompt_id
    CALL PRINT_STR_PROC
    CALL READ_NUMBER
    CALL FIND_TASK_BY_ID
    CMP BX, 0FFFFh
    JE ut_not_found
    
    CALL NEWLINE_PROC
    LEA DX, prompt_title
    CALL PRINT_STR_PROC
    MOV AX, BX
    MOV TEMP_BX_UPDATE1, BX
    MOV CX, 20
    MUL CX
    LEA DI, TASK_TITLES
    ADD DI, AX
    MOV CX, 19
    CALL READ_STRING
    MOV BX, TEMP_BX_UPDATE1
    
    CALL NEWLINE_PROC
    LEA DX, prompt_pri
    CALL PRINT_STR_PROC
    CALL READ_NUMBER
    MOV TASK_PRIORITIES[BX], AL
    
    CALL NEWLINE_PROC
    LEA DX, prompt_desc
    CALL PRINT_STR_PROC
    MOV AX, DESC_POINTER
    MOV TEMP_BX_UPDATE2, BX
    SHL BX, 1
    MOV TASK_DESC_OFFSETS[BX], AX
    MOV BX, TEMP_BX_UPDATE2
    CALL READ_DYNAMIC_STRING
    
    JMP main_loop
ut_not_found:
    CALL NEWLINE_PROC
    LEA DX, msg_not_found
    CALL PRINT_STR_PROC
    CALL NEWLINE_PROC
    JMP main_loop


MARK_DONE:
    CALL NEWLINE_PROC
    LEA DX, prompt_id
    CALL PRINT_STR_PROC
    CALL READ_NUMBER
    CALL FIND_TASK_BY_ID
    CMP BX, 0FFFFh
    JE md_not_found
    MOV TASK_STATUS[BX], 1
    CALL NEWLINE_PROC
    LEA DX, msg_done
    CALL PRINT_STR_PROC
    CALL NEWLINE_PROC
    JMP main_loop
md_not_found:
    CALL NEWLINE_PROC
    LEA DX, msg_not_found
    CALL PRINT_STR_PROC
    CALL NEWLINE_PROC
    JMP main_loop


FILTER_TASK:
    CALL NEWLINE_PROC
    LEA DX, prompt_pri
    CALL PRINT_STR_PROC
    CALL READ_NUMBER
    MOV TEMP_AX_FILTER, AX
    
    CALL NEWLINE_PROC
    LEA DX, msg_line
    CALL PRINT_STR_PROC
    CALL NEWLINE_PROC
    
    MOV AX, TEMP_AX_FILTER
    MOV DL, AL
    
    MOV CX, TASK_COUNT
    CMP CX, 0
    JE filt_end
    MOV BX, 0
filt_loop2:
    CMP TASK_ACTIVE[BX], 1
    JNE filt_next2
    CMP TASK_PRIORITIES[BX], DL
    JNE filt_next2
    CALL PRINT_TASK
filt_next2:
    INC BX
    LOOP filt_loop2
filt_end:
    LEA DX, msg_line
    CALL PRINT_STR_PROC
    CALL NEWLINE_PROC
    JMP main_loop

EXIT_PROGRAM:
    MOV AX, 4C00H
    INT 21H

MAIN ENDP

; --- PROCEDURES ---

PRINT_STR_PROC PROC
    MOV TEMP_AX_PRINT_STR, AX
    MOV AH, 09H
    INT 21H
    MOV AX, TEMP_AX_PRINT_STR
    RET
PRINT_STR_PROC ENDP

PRINT_CHAR_PROC PROC
    MOV TEMP_AX_PRINT_CHAR, AX
    MOV AH, 02H
    INT 21H
    MOV AX, TEMP_AX_PRINT_CHAR
    RET
PRINT_CHAR_PROC ENDP

NEWLINE_PROC PROC
    MOV TEMP_AX_NEWLINE, AX
    MOV TEMP_DX_NEWLINE, DX
    MOV DL, 0DH
    MOV AH, 02H
    INT 21H
    MOV DL, 0AH
    MOV AH, 02H
    INT 21H
    MOV DX, TEMP_DX_NEWLINE
    MOV AX, TEMP_AX_NEWLINE
    RET
NEWLINE_PROC ENDP

PRINT_TASK PROC
    MOV TEMP_AX_PRINT_TASK, AX
    MOV TEMP_CX_PRINT_TASK, CX
    MOV TEMP_DX_PRINT_TASK, DX
    
    LEA DX, msg_id_label
    CALL PRINT_STR_PROC
    XOR AH, AH
    MOV AL, TASK_IDS[BX]
    CALL PRINT_NUMBER
    
    LEA DX, msg_title_label
    CALL PRINT_STR_PROC
    MOV AX, BX
    MOV TEMP_BX_PRINT_TASK1, BX
    MOV CX, 20
    MUL CX
    LEA DX, TASK_TITLES
    ADD DX, AX
    CALL PRINT_STR_PROC
    MOV BX, TEMP_BX_PRINT_TASK1
    
    CMP TASK_PRIORITIES[BX], 1
    JE pt_vp1
    CMP TASK_PRIORITIES[BX], 2
    JE pt_vp2
    CMP TASK_PRIORITIES[BX], 3
    JE pt_vp3
pt_vp1: LEA DX, msg_p1
    CALL PRINT_STR_PROC
    JMP pt_vp_done
pt_vp2: LEA DX, msg_p2
    CALL PRINT_STR_PROC
    JMP pt_vp_done
pt_vp3: LEA DX, msg_p3
    CALL PRINT_STR_PROC
pt_vp_done:
    
    CMP TASK_STATUS[BX], 1
    JE pt_vs_done
    LEA DX, msg_pending
    CALL PRINT_STR_PROC
    JMP pt_vs_end
pt_vs_done:
    LEA DX, msg_completed
    CALL PRINT_STR_PROC
pt_vs_end:

    LEA DX, msg_desc_label
    CALL PRINT_STR_PROC
    MOV TEMP_BX_PRINT_TASK2, BX
    SHL BX, 1
    MOV AX, TASK_DESC_OFFSETS[BX]
    LEA DX, DESC_BUFFER
    ADD DX, AX
    CALL PRINT_STR_PROC
    MOV BX, TEMP_BX_PRINT_TASK2
    
    CALL NEWLINE_PROC
    
    MOV DX, TEMP_DX_PRINT_TASK
    MOV CX, TEMP_CX_PRINT_TASK
    MOV AX, TEMP_AX_PRINT_TASK
    RET
PRINT_TASK ENDP

FIND_TASK_BY_ID PROC
    MOV CX, TASK_COUNT
    CMP CX, 0
    JE ft_not_found
    MOV BX, 0
ft_loop:
    CMP TASK_ACTIVE[BX], 1
    JNE ft_next
    CMP TASK_IDS[BX], AL
    JE ft_found
ft_next:
    INC BX
    LOOP ft_loop
ft_not_found:
    MOV BX, 0FFFFh
    RET
ft_found:
    RET
FIND_TASK_BY_ID ENDP

READ_NUMBER PROC
    MOV TEMP_BX_RN, BX
    MOV TEMP_CX_RN, CX
    MOV TEMP_DX_RN, DX
    XOR BX, BX
rn_loop:
    MOV AH, 01H
    INT 21H
    CMP AL, 0DH
    JE rn_end
    CMP AL, '0'
    JL rn_loop
    CMP AL, '9'
    JG rn_loop
    SUB AL, 30H
    XOR AH, AH
    MOV TEMP_AX_RN_MUL, AX
    MOV AX, 10
    MUL BX
    MOV BX, AX
    MOV AX, TEMP_AX_RN_MUL
    ADD BX, AX
    JMP rn_loop
rn_end:
    MOV AX, BX
    MOV DX, TEMP_DX_RN
    MOV CX, TEMP_CX_RN
    MOV BX, TEMP_BX_RN
    RET
READ_NUMBER ENDP

PRINT_NUMBER PROC
    MOV TEMP_AX_PN, AX
    MOV TEMP_BX_PN, BX
    MOV TEMP_CX_PN, CX
    MOV TEMP_DX_PN, DX
    MOV TEMP_SI_PN, SI
    
    MOV CX, 0
    MOV BX, 10
    LEA SI, DIGIT_ARRAY
pn_loop1:
    XOR DX, DX
    DIV BX
    MOV [SI], DL
    INC SI
    INC CX
    CMP AX, 0
    JNE pn_loop1
pn_loop2:
    DEC SI
    MOV DL, [SI]
    ADD DL, 30H
    CALL PRINT_CHAR_PROC
    LOOP pn_loop2
    
    MOV SI, TEMP_SI_PN
    MOV DX, TEMP_DX_PN
    MOV CX, TEMP_CX_PN
    MOV BX, TEMP_BX_PN
    MOV AX, TEMP_AX_PN
    RET
PRINT_NUMBER ENDP

READ_STRING PROC
    MOV TEMP_AX_RS, AX
    MOV TEMP_CX_RS, CX
    MOV TEMP_DI_RS, DI
rs_loop:
    MOV AH, 01H
    INT 21H
    CMP AL, 0DH
    JE rs_end
    MOV [DI], AL
    INC DI
    LOOP rs_loop
rs_end:
    MOV BYTE PTR [DI], '$'
    MOV DI, TEMP_DI_RS
    MOV CX, TEMP_CX_RS
    MOV AX, TEMP_AX_RS
    RET
READ_STRING ENDP

READ_DYNAMIC_STRING PROC
    MOV TEMP_AX_RDS, AX
    MOV TEMP_DI_RDS, DI
    LEA DI, DESC_BUFFER
    ADD DI, DESC_POINTER
rds_loop:
    MOV AH, 01H
    INT 21H
    CMP AL, 0DH
    JE rds_end
    MOV [DI], AL
    INC DI
    INC DESC_POINTER
    JMP rds_loop
rds_end:
    MOV BYTE PTR [DI], '$'
    INC DESC_POINTER
    MOV DI, TEMP_DI_RDS
    MOV AX, TEMP_AX_RDS
    RET
READ_DYNAMIC_STRING ENDP

END MAIN
