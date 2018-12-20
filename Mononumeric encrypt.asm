
; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt
include emu8086.inc
org 100h  
DEFINE_PRINT_NUM
DEFINE_PRINT_NUM_UNS  
DEFINE_SCAN_NUM

.MODEL SMALL
.DATA
MSG   DB  "ENTER MESSAGE IN LOWER CASE LETTERS: ",'$'   

.CODE
MOV   AX,@DATA    
MOV   DS,AX  ; ==DS 0700H
MOV SI, 0



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;INITIALIZE TABLE OF LETTERS IN DS AND ES    



MOV AX,1111h
MOV ES,AX ; ES 1111H  
CLD
MOV DI,0 
MOV SP,0  



  

MOV CX,26  
MOV BL,61H                ;;61H is a in ascii 
INITI_LABEL: 
MOV [SI],BL
INC BL 
MOVSB 
LOOP INITI_LABEL      

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;     ENC OR DEC

PRINT 'TO ENCRYPT PRESS 1 , TO DECRYPT PRESS 2: '                 ; label to read
MOV AH,01
INT 21H 
MOV CL,AL 
MOV CH,0
MOV DL,0AH               ;new line printing
MOV AH,02                
INT 21H                 
SUB CL,32H               ;32H is 2
JCXZ DECRYPT
  
 




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;    ENCRYPTING PART

ENCRYPT:
PRINT  '                                      '  
LEA DX,MSG               ;//print msg
MOV AH,09H
INT 21H  

READING:                 ;// label to read
MOV AH,01
INT 21H 
CMP AL , 32              ;;to neglect space entered and not to decrypt it    
JE READING     
PUSH AX                  ;to save every entered letter in stack and by looping till sp = zero i can get all data entered  
CMP AL,13                ; //ascii for "ENTER" key     
JE EXIT

;MOV DL,0AH              ;new line
;MOV AH,02               ;  
;INT 21H
LOOP READING             ;;looping  


EXIT:  
POP AX                   ; pop the enter that was last thing be pushed to stack i dont need it
MOV BX,9FH               ; saves the location of  TOP OF the table of numbers returned at 100 if we refrence it we find the number of last charc entered
MOV CX,100                 
SCANSTRING_LABEL:  
MOV DI,0 
POP AX                  
REPNE SCASB                   ;; to compare the value of ""AL"" with [DI] the value of DI returned +1 is the incryption needed for the letter
;ADD DI,'0'                     ;to get the ascii number correct
MOV [BX],DI
INC BX                    ;;to store the previous letter encryption "NUMBER"   
MOV CX,SP                 ;;so i can loop until stack pops all data entered 
JCXZ DONE_ENCRYPTION
LOOP SCANSTRING_LABEL    

DONE_ENCRYPTION: 
MOV [BX],0FFH             ;INDICATION IN MEMORY FOR start of the data   

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; PRINTING AFTER ENCRYPTION 
MOV DL,0AH              ;new line
MOV AH,02               ;  
INT 21H
                                                         
PRINT 'THE MESSAGE AFTER ENCRYPTION is: '
PRINT_ENCRYPTEDMSG:  
DEC BX                                                            
MOV AL,[BX]   
MOV AH ,0
CALL PRINT_NUM_UNS 
PRINT ' '         
;MOV AH,02H   
;;MOV DL,0AH
;INT 21H
MOV DX,BX
SUB DX,9FH                ;to loop until first position  
LOOPNZ PRINT_ENCRYPTEDMSG  

   
                          
JMP DONE                      



 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;DYCREPTING PART

DECRYPT:   

PRINT  '                                      '   
PRINT 'ENTER NUMBER[1-26] YOU WANT TO DECRYPT OR 27 TO EXIT THEN PRESS ENTER: '  

CALL SCAN_NUM  ;; stores to cx register
MOV DL,0AH     ;;new line
MOV AH,02  
INT 21H  
MOV BX,0
DEC BX
MOV AL,CL 
XLAT    
MOV DL,AL 

PRINT '                                                                                DECRYPTED:'


MOV AH,02               ;  //code to print a character
INT 21H 
PRINT '                               '
SUB CL,27              ; 
JNZ DECRYPT


PRINT 'EXITTTTTTT'



DONE: 


MOV AH,4CH 
INT 21H
END
   


ret




