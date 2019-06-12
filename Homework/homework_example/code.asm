A_PORT EQU 0000H
B_PORT EQU 0002H
C_PORT EQU 0004H
CRTL_8255 EQU 0006H

ICW1 EQU 0400H
ICW2 EQU 0402H
ICW4 EQU 0402H
OCW2 EQU 0400H


T0   EQU 0200H
T1   EQU 0202H
T2   EQU 0204H
CRTL_8253 EQU 0206H

DATA SEGMENT 
    LEDTAB  DB 3FH,06H,5BH,4FH,66H,6DH,7DH,07H,7FH,6FH  ;�����
DATA ENDS

STACK   SEGMENT STACK
    ST DB 10 DUP(0)
STACK   ENDS

CODE SEGMENT 
   ASSUME CS:CODE,DS:DATA ,SS:STACK

START: MOV AX,DATA
		MOV DS,AX
		
		;8255��ʼ��  
		MOV AL,80H
		MOV DX,CRTL_8255
		OUT DX,AL 
       
      
		MOV AL, 01H	; LED0����(�ߵ�ƽ����)
		MOV BL,AL 
		MOV DX, B_PORT
		OUT DX, AL         ;PB0����
		
		;8253��ʼ��
		MOV AL,00100111B
		MOV DX, CRTL_8253
		OUT DX, AL
		
		MOV AL,10H
		MOV DX, T0
		OUT DX, AL
		
	    MOV AL,01100111B
		MOV DX, CRTL_8253
		OUT DX, AL
		
		MOV AL,10H
		MOV DX, T1
		OUT DX, AL

		
		;8259��ʼ��
		MOV AL, 13H; 00010011B��ICW1�����ش�������Ƭ��ҪICW4
		MOV DX, ICW1 ; 8259��ַ
		OUT DX, AL
		
		
		MOV AL, 40H  ;    ICW2�ж����ͺ�Ϊ40
		MOV DX, ICW2		
		OUT DX, AL
		MOV AL, 01H  ;   ICW4���û��巽ʽ�������жϽ������������ȫǶ�׷�ʽ
		MOV DX, ICW4		
		OUT DX, AL
        
        ;�ж��������ʼ��
		MOV AX, 0 
		MOV DS, AX           ; ���ݶ�����        
		
		MOV DI,0
		MOV CX,256
INITINTR:
		LEA AX,INT0   ; д8259�жϳ������ڵ�ַ
		MOV DS:[DI],AX  ; ���жϷ���������ڵ�ַƫ�������ж�������
		MOV AX, SEG INT0
		MOV DS:[DI+2], AX ; ���жϷ���������ڵ�ַ�ε�ַ���ж�������
        ADD DI,4
        
        LOOP INITINTR

		STI                       ;���ж�
    
        MOV AX,SEG LEDTAB
        MOV DS,AX
        MOV AX, 0
        MOV CX,0

LEDDISP:
        MOV AL,1110B       ;���λ��
        MOV DX,C_PORT
        OUT DX,AL
               
        MOV AL,LEDTAB[1]
        MOV DX,A_PORT       ;�������
        OUT DX,AL

        CALL DELAY
        
        MOV AL,0H
        MOV DX,A_PORT     ;����
        OUT DX,AL
  
        
        MOV AL,1101B        ;���λ��
        MOV DX,C_PORT
        OUT DX,AL
        
        MOV AL,LEDTAB[2]
        MOV DX,A_PORT       ;�������
        OUT DX,AL

        CALL DELAY
        MOV AL,0H
        MOV DX,A_PORT     ;����
        OUT DX,AL
        
        
        MOV AL,1011B        ;���λ��
        MOV DX,C_PORT
        OUT DX,AL

        MOV AL,LEDTAB[3]
        MOV DX,A_PORT       ;�������
        OUT DX,AL

        CALL DELAY
        MOV AL,0H
        MOV DX,A_PORT     ;����
        OUT DX,AL
        
        
        MOV AL,0111B        ;���λ��
        MOV DX,C_PORT
        OUT DX,AL
     
        MOV AL,LEDTAB[4]
        MOV DX,A_PORT       ;�������
        OUT DX,AL

        CALL DELAY
        MOV AL,0H
        MOV DX,A_PORT     ;����
        OUT DX,AL
        
        
        JMP LEDDISP

       
DELAY   PROC     ;��ʱ�ӳ���
        PUSH CX
        MOV CX,0FH    
    D1: LOOP D1
        POP CX
        RET        
DELAY   ENDP


INT0  PROC     ;8259�жϷ������   
      ;STI
      ROL BL,1        ;��ѭ��1��
      MOV AL,BL
      MOV DX,B_PORT   
      OUT DX,AL      ; PA�ڵ���
          
      MOV DX,OCW2 
      MOV AL,20H     ; OCW2����������EOI=1
      OUT DX,AL
      INC CX
      IRET
          
INT0 ENDP
    
CODE ENDS
END START
   





