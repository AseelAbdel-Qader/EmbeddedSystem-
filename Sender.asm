INCLUDE "P16F877A.INC"
countF1  equ  0x20
countF2  equ  0x21
num      equ  0x22
TIM     equ  0X23
temp  equ  0x24
	org 0x0000
	goto START
	org 0x0004
	goto ISR
	
START   
	movlw D'15'
	movwf num   ;constant number 
	movlw D'255'
	movwf TIM
	BANKSEL TRISB
	MOVLW B'00000000';**
	movwf TRISB
	BANKSEL PORTB
	clrf PORTB
	BANKSEL TRISC
	CLRF    TRISC ; RC6 IS CONFIGURED AS OUTPUT
	banksel PORTB
	movlw 0x00
	movwf countF1
	movwf countF2
	movwf temp
	BANKSEL TRISB
	MOVLW B'11110000'
	movwf TRISB
	BANKSEL PORTB
	clrf  PORTB
	movf PORTB,f ;to clear the intrrupt flag
	bcf INTCON,RBIF
	
		
	BANKSEL INTCON
	bsf INTCON,RBIE
	bsf INTCON,GIE 
	;	bsf INTCON,T0IE
		
	BANKSEL TXSTA
	MOVLW B'01100100'   ; CONFIGURE TX (TXEN=1,TX9=1,SYNC=0,BRGH=0)
	MOVWF TXSTA 

	MOVLW D'5' ; BAUD RATE = 9.6KBPS 
	MOVWF SPBRG
	BANKSEL    TXSTA
	bsf    TXSTA,TXEN
	BANKSEL     RCSTA

	BSF RCSTA, SPEN
	BCF PIR1,  TXIF
	banksel TRISA 
	movlw 1;
	banksel TRISA 
	movwf TRISA;
	movlw 0;
	banksel TRISD 
	movwf TRISD;
	BANKSEL PORTD
	clrf PORTD
		
loop1
	call adc
	goto loop1

		

ISR	movf PORTB,w
	movwf temp
	BANKSEL TRISB
	MOVLW B'00000000'
	movwf TRISB
	BANKSEL PORTB
	clrf PORTB
		
	btfsc temp,4   ; MEANS CAR ENTER THE FIRST FLOOR
	call enter1
	btfsc temp,5   ; MEANS CAR ENTER TO THE SECOND FLOOR
	call enter2
	btfsc temp,6   ; MEANS CAR EXIT THE FIRST FLOOR 
	call out1
	btfsc temp,7    ;CAR EXIT THE SECOND FLOOR
	call  out2
	BANKSEL PORTB
	clrf PORTB
	clrf temp

	BANKSEL TRISB
 	MOVLW B'11110000'
	movwf TRISB
	BANKSEL PORTB		
		
	movf PORTB,f
	BANKSEL INTCON
	bcf INTCON,RBIF
	
	retfie
		

enter1	
	movf countF1,w
	subwf num,w
	btfss STATUS,Z  ;if countF1 = 15 donot increment the value
	incf countF1

	movf countF1,w
	BANKSEL PIR1
;WAIT	BTFSS PIR1,TXIF 
	;	GOTO WAIT
	BANKSEL TXSTA
	bcf TXSTA,TX9D
	BANKSEL TXREG
	movf countF1,w
	movwf TXREG
		
	subwf num,w
	btfss STATUS,Z 
	goto turrn_on 
	goto ret
		
turrn_on
	bsf PORTD,1
	call Delay_5ms 
	call Delay_5ms 
	call Delay_5ms 
	call Delay_5ms 
	bcf PORTD,1

ret	return


enter2	
		movf countF2,w  
		subwf num,w
		btfss STATUS,Z  ; if countF2 = 15 donot increment the value 

		incf countF2
		movf countF2,w
		BANKSEL TXSTA
		bSf TXSTA,TX9D
		BANKSEL TXREG
		movf countF2,w
		movwf TXREG
		return



out1	decf countF1
		movf countF1,w
		BANKSEL TXSTA
		bcf TXSTA,TX9D
		BANKSEL TXREG
		movf countF1,w
		movwf TXREG
		return



out2	decf countF2
 		movf countF2,w
		BANKSEL TXSTA
		bSf TXSTA,TX9D
		BANKSEL TXREG
		movf countF2,w
		movwf TXREG
		return




adc: 
	movlw 0x81;
	banksel ADCON0
	movwf ADCON0 ;Set ADON ,channel 0,Fosc/64
	movlw 0xc0;
	banksel ADCON1;VREF+=VDD,VREF-=VSS,Right Justified
	movwf ADCON1;
	banksel ADCON0
	BSF ADCON0,GO; startup ADC divert
loop:	
	btfss ADCON0,2;is GO/DONE set or not?
	goto LED;
	goto loop

LED:

	banksel ADRESH
	btfss ADRESH,1
	goto off
	goto on



on:
	bsf PORTD,0;
	return;

off:
	bcf PORTD,0;
	return 


Delay_5ms 
	movlw  D'250'
	movwf  0x40 
repet	NOP
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
		decfsz  0x40,f
		goto repet
		decfsz TIM ,f 
		goto Delay_5ms 
	
		return 

		end
