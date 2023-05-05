#include p16F877A.INC




First equ 0x22; control seven_seg1
Secound equ 0x23; control seven_seg2
FirstF2 equ 0x24; contro2 seven_seg1
SecoundF2 equ 0x25; contro2 seven_seg2
;dat   equ  0x30
temp equ 0x34 ; to test number if greater or smaller than 9
temp2 equ 0x30; in case2 have to select first bit (15-10=5) 5
temp3 equ 0x27

tempF2 equ 0x28 ; to test number if greater or smaller than 9
temp2F2 equ 0x29; in case2 have to select first bit (15-10=5) 5
temp3F2 equ 0x31


org 0x00
goto start 
org 0x04 
goto AGIN
start 
		banksel TRISC
		bsf TRISC, 7 ; RC7 IS CONFIGURED AS INPUT
		clrf TRISD

		BANKSEL TXSTA
		bsf TXSTA, BRGH
		bcf TXSTA, SYNC


		BANKSEL SPBRG
		movlw D'5' ; BAUD RATE = 9.6KBPS
		movwf SPBRG


		banksel RCSTA
		movlw B'11010000' ; CONFIGURE RX (SPEN=1,RX9=1,CREN=1)
		movwf RCSTA
		banksel PIE1
		bsf PIE1,5
		banksel INTCON
		bsf INTCON,7
		;bsf INTCON,6

		banksel RCREG
		clrf RCREG



		banksel TRISB ; select bank1
		CLRF TRISB
		CLRF TRISA
		BCF STATUS,RP0
		CLRF First
		CLRF Secound
		CLRF FirstF2
		CLRF SecoundF2
		
		movlw 0x09;Constant9
		movwf temp
		movlw 0x0A; Constant10
		movwf temp2
		movlw 0x0F
		movwf temp3
		
		movlw 0x09;Constant9
		movwf tempF2
		movlw 0x0A; Constant10
		movwf temp2F2
		movlw 0x0F
		movwf temp3F2

LOOP	 btfss PIR1, RCIF ; WAIT FOR RECEPTION
		 goto LOOP
AGIN  	
		banksel RCREG
		movf RCREG ,w

		BANKSEL RCSTA
		movf RCSTA ,w
		
		btfss RCSTA,0  ; test the parity bit
		CALL floor2    ; if parity bit = 0 --> this number to the first floor
		CALL floor1    ; if parity bit = 1 --> this number to the second floor



floor1
		banksel RCREG
	;	movf RCREG ,w
		movf RCREG,W
       	movwf First       ;variable depend in value come from receiver

	
		movf First,w
		subwf temp,w
		btfss STATUS ,C  ; to cheak First >9 or 9>
		GOTO CASE2       ; First>9 and the secound seven seg constant 0
MAIN
		BANKSEL PIR1   ; to ensure if any number send
		btfsc PIR1,RCIF
		GOTO AGIN
		clrf Secound; First<9
		MOVF First,W; select specific number(0-9) from seven seg
		CALL Tabel
		MOVWF PORTB; to show in seve seg
		BSF PORTA,0 ; SEVEN SEG1 ON
		CALL DELAY
		BCF PORTA,0
		MOVF Secound,W; select specific number(0-9)
		CALL Tabel
		MOVWF PORTB; to show in seve seg
		BSF PORTA,1 ; SEVEN SEG1 ON
		CALL DELAY
		BCF PORTA,1
		GOTO MAIN
CASE2 	
		movf temp3,w
		subwf First,w
		btfss STATUS ,C; to cheak First >9 or 9>
		GOTO MAIN2;
		GOTO CASE3;

MAIN2 
		BANKSEL PIR1
		btfsc PIR1,RCIF
		GOTO AGIN
		MOVLW 0X01 ; the secound seven seg constant 1
		MOVWF Secound
		movf temp2,w ; (number from recriver >9-10)
		subwf First,w
		CALL Tabel
		MOVWF PORTB; to show in seve seg
		BSF PORTA,0 ; SEVEN SEG1 ON
		CALL DELAY
		BCF PORTA,0
		MOVF Secound,W; select specific number(0-9)
		CALL Tabel
		MOVWF PORTB; to show in seve seg
		BSF PORTA,1 ; SEVEN SEG1 ON
		CALL DELAY
		BCF PORTA,1
		GOTO MAIN2



CASE3
MAIN3
		BANKSEL PIR1
		btfsc PIR1,RCIF
		GOTO AGIN
		MOVLW 0X01 ; the secound seven seg constant 1
		MOVWF Secound
		movf temp2,w ; (number from recriver >9-10)
		subwf temp3,w
		CALL Tabel
		MOVWF PORTB   ; to show in seve seg
		BSF PORTA,0 ; SEVEN SEG1 ON
		CALL DELAY
		CALL DELAY
		CALL DELAY
		BCF PORTA,0
		MOVF Secound,W; select specific number(0-9)
		CALL Tabel
		MOVWF PORTB; to show in seve seg
		BSF PORTA,1 ; SEVEN SEG1 ON
		CALL DELAY
		BCF PORTA,1
		GOTO MAIN3


return


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;






floor2  
	  	banksel RCREG
	;	movf RCREG ,w
		movf RCREG,W
       	movwf FirstF2       ;variable depend in value come from receiver

	
		movf FirstF2,w
		subwf tempF2,w
		btfss STATUS ,C  ; to cheak First >9 or 9>
		GOTO CASE2f2      ; First>9 and the secound seven seg constant 0
MAINf2
		BANKSEL PIR1
		btfsc PIR1,RCIF
		GOTO AGIN
		clrf SecoundF2; First<9
		MOVF FirstF2,W; select specific number(0-9) from seven seg
		CALL Tabel
		MOVWF PORTD; to show in seve seg
		BSF PORTA,3 ; SEVEN SEG1 ON
		CALL DELAY
		BCF PORTA,3
		MOVF SecoundF2,W; select specific number(0-9)
		CALL Tabel
		MOVWF PORTD; to show in seve seg
		BSF PORTA,2 ; SEVEN SEG1 ON
		CALL DELAY
		BCF PORTA,2
		GOTO MAINf2
CASE2f2 	
		movf temp3F2,w
		subwf FirstF2,w
		btfss STATUS ,C; to cheak First >9 or 9>
		GOTO MAIN2f2;
		GOTO CASE3f2;

MAIN2f2 
		BANKSEL PIR1
		btfsc PIR1,RCIF
		GOTO AGIN
		MOVLW 0X01 ; the secound seven seg constant 1
		MOVWF SecoundF2
		movf temp2F2,w ; (number from recriver >9-10)
		subwf FirstF2,w
		CALL Tabel
		MOVWF PORTD; to show in seve seg
		BSF PORTA,3 ; SEVEN SEG1 ON
		CALL DELAY
		BCF PORTA,3
		MOVF SecoundF2,W; select specific number(0-9)
		CALL Tabel
		MOVWF PORTD; to show in seve seg
		BSF PORTA,2 ; SEVEN SEG1 ON
		CALL DELAY
		BCF PORTA,2
		GOTO MAIN2f2



CASE3f2
MAIN3f2
		BANKSEL PIR1
		btfsc PIR1,RCIF
		GOTO AGIN
		MOVLW 0X01 ; the secound seven seg constant 1
		MOVWF SecoundF2
		movf temp2F2,w ; (number from recriver >9-10)
		subwf temp3F2,w
		CALL Tabel
		MOVWF PORTD   ; to show in seve seg
		BSF PORTA,3 ; SEVEN SEG1 ON
		CALL DELAY
		CALL DELAY
		CALL DELAY
		BCF PORTA,3
		MOVF SecoundF2,W; select specific number(0-9)
		CALL Tabel
		MOVWF PORTD; to show in seve seg
		BSF PORTA,2 ; SEVEN SEG1 ON
		CALL DELAY
		BCF PORTA,2
		GOTO MAIN3f2

return 


DELAY MOVLW D'250'
MOVWF 0X40



REPEAT
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP



		DECFSZ 0X40,1
		GOTO REPEAT
		RETURN





Tabel 	
		ADDWF PCL,F
		RETLW 0X3F
		RETLW 0X06
		RETLW 0X5B
		RETLW 0X4F
		RETLW 0X66
		RETLW 0X6D
		RETLW 0X7D
		RETLW 0X07
		RETLW 0X7F
		RETLW 0X6F
	
END

