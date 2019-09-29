 ;LCD 2x16 Port
;Control
RS	EQU P1.0	;Register Select Pin
RW 	EQU P1.1	;Read/Write Pin
E 	EQU P1.2	;Enable Pin - Set High to Low
;Button
B1 EQU P1.3
B2 EQU P1.4
B3 EQU P1.5
;Data Pin
D0	EQU P0.0
D1	EQU P0.1
D2	EQU P0.2
D3	EQU P0.3
D4	EQU P0.4
D5	EQU P0.5
D6	EQU P0.6
D7	EQU P0.7
;------------------------------------------------------------------------------------------------
ORG 00H
JMP MAIN	;Jump to Main Program

;------------------------------------------------------------------------------------------------
;Kumpulan Data

;Line LCD Display
LINE1:	DB ' ',' ', 'W', 'E', 'L', 'C', 'O', 'M', 'E', '!', '$'
LINE2:	DB ' ',' ', 'D', 'E', 'E', 'P', 'B', 'L', 'U', 'E', '$'
LINE3:	DB ' ',' ','P', 'A', 'S', 'S', 'W', 'O', 'R', 'D', ':', '$'
LINE4:  DB 'B','E','N','A', 'R', '$'
LINE5:  DB 'SALAH$'
PASSWORD: DB 33H,32H,31H,34H,35H,0 ;PASSWORD 3,2,1,4,5 
;------------------------------------------------------------------------------------------------
;MAIN Program
MAIN:
	ACALL LCDCONFIG			;Konfigurasi LCD
	ACALL PRINTLINE1
	ACALL CLEARLCD
	ACALL PRINTLINE2
	ACALL CLEARLCD
	ACALL PRINTLINE3
	ACALL CLEARLCD
	ACALL KEYPAD		;Memanggil subrutin KEYPAD sebgai input user
    ACALL CHECK_PASS_INP	;Subrutin untuk membandingkan input x password
	
JMP EXIT
	
;------------------------------------------------------------------------------------------------
;Kumpulan Procedure
UP:
	INC R4
RET

DOWN:
	DEC R4
RET

;Print LINE1
PRINTLINE1:
	MOV A,#80H		;Force Cursor to Beginning First Line
	ACALL CMDWRITE		;Send Command
	MOV B, #LINE1		;Masukan Pointer Awal
AGAIN1:	MOV A, B		;Pindahkan Pointer
	MOVC A, @A+DPTR		;Ambil Data dari Lookup-Table > A
	CJNE A, #'$', PRINT1	;Jika String Belum Habis > Print Lagi
	JMP ENDPRINT1
PRINT1:	ACALL DATAWRITE		;Print Char
	INC B			;Increase Pointer
	JMP AGAIN1
ENDPRINT1:
RET

;Print LINE2
PRINTLINE2:
	MOV A,#0C0H		;Force Cursor to Beginning Second Line
	ACALL CMDWRITE		;Send Command
	MOV B, #LINE2		;Masukan Pointer Awal
	AGAIN2:	MOV A, B		;Pindahkan Pointer
	MOVC A, @A+DPTR		;Ambil Data dari Lookup-Table > A
	CJNE A, #'$', PRINT2	;Jika String Belum Habis > Print Lagi
	JMP ENDPRINT2
PRINT2:	ACALL DATAWRITE		;Print Char
	INC B			;Increase Pointer
	JMP AGAIN2
ENDPRINT2:
RET

;Print LINE3
PRINTLINE3:
	MOV A,#80H		;Force Cursor to Beginning First Line
	ACALL CMDWRITE		;Send Command
	MOV B, #LINE3		;Masukan Pointer Awal
AGAIN3:	MOV A, B		;Pindahkan Pointer
	MOVC A, @A+DPTR		;Ambil Data dari Lookup-Table > A
	CJNE A, #'$', PRINT3	;Jika String Belum Habis > Print Lagi
	JMP ENDPRINT3
PRINT3:	ACALL DATAWRITE		;Print Char
	INC B			;Increase Pointer
	JMP AGAIN3
ENDPRINT3:
RET

PRINTLINE4:
	MOV A,#80H		;Force Cursor to Beginning First Line
	ACALL CMDWRITE		;Send Command
	MOV B, #LINE4		;Masukan Pointer Awal
AGAIN4:	MOV A, B		;Pindahkan Pointer
	MOVC A, @A+DPTR		;Ambil Data dari Lookup-Table > A
	CJNE A, #'$', PRINT4	;Jika String Belum Habis > Print Lagi
	JMP ENDPRINT4
PRINT4:	ACALL DATAWRITE		;Print Char
	INC B			;Increase Pointer
	JMP AGAIN4
ENDPRINT4:
RET

;Print LINE2
PRINTLINE5:
	MOV A,#0C0H		;Force Cursor to Beginning Second Line
	ACALL CMDWRITE		;Send Command
	MOV DPTR, #LINE5		;Masukan Pointer Awal
	AGAIN5:	
	CLR A
	MOVC A, @A+DPTR		;Ambil Data dari Lookup-Table > A
	CJNE A, #'$', PRINT5	;Jika String Belum Habis > Print Lagi
	JMP ENDPRINT5
PRINT5:	ACALL DATAWRITE		;Print Char
	INC DPTR			;Increase Pointer
	JMP AGAIN5
ENDPRINT5:
RET

;LCD Configuration
LCDCONFIG:
	MOV A,#38H	;Configure 2 Line - 5x7 Matrix
	ACALL CMDWRITE	;Send Command7
	
	MOV A,#0CH	;Display On - Cursor Off
	ACALL CMDWRITE	;Send Command

	MOV A,#01H	;Clear Screen
	ACALL CMDWRITE	;Send Command

	MOV A,#80H	;Force Cursor to Beginning First Line
	ACALL CMDWRITE	;Send Command
RET
	
;Command Write Procedure
CMDWRITE:
	ACALL ISLCDREADY;Check LCD Status
	MOV P0, A	;Input Command to P0	
	CLR RS		;Clear RS Pin - Sending Command
	CLR RW		;Clear RW Pin - Write
	SETB E		;High E
	CLR E		;Low E - Enable > Sending Command
RET

;Data Write Procedure
DATAWRITE:
	ACALL ISLCDREADY;Check LCD Status	
	MOV P0, A	;Input Data to P0	
	SETB RS		;Set High RS Pin - Sending Data	
	CLR RW		;Clear RW Pin - Write
	SETB E		;High E
	CLR E		;Low E - Enable > Sending Data
RET

;Check LCD Status Procedure
ISLCDREADY:
	SETB D7		;Set D7 High = Busy Flags 
	CLR RS		;Clear RS Pin
	SETB RW		;Set RW High - Read Data From LCD
NOTYET:
	SETB E		;High E
	CLR E		;Low E - Enable > Sending Command
	JB D7, NOTYET	;Check PIN D7 - Jika High > Busy
RET

; Clear LCD
CLEARLCD:
	MOV A,#01H	;Clear Screen
	ACALL CMDWRITE	;Send Command
RET
	
KEYPAD:  	MOV A, #5D	;Indikator jumlah looping untuk cek input
		MOV R0,A		
		MOV A, #100D	
		MOV R1,A
SCAN: 		ACALL SCAN_KEYPAD
		MOV @R1,A	;Input disimpan pada alamat yang ditunjuk oleh isi R1
		INC R1		
		DJNZ R0,SCAN	;SCAN sebanyak jumlah input yang ada
		RET

CHECK_PASS_INP:	MOV R0,#5D
		MOV R1,#100D
		MOV DPTR,#PASSWORD 	;Memasukkan alamat PASSWORD ke DPTR
BACK:		CLR A
		MOVC A,@A+DPTR		;COPY setiap digit password satu persatu ke A
		SUBB A,@R1		;Mengurangi isi A dengan indirect address R1
		JNZ SALAH		;Apabila hasil pengurangan tidak 0 maka salah
		INC DPTR
		INC R1
		DJNZ R0,BACK		;Cek semua input terhadapt pass sebanyak 5 kali
		acall BENAR
		RET

BENAR:		
		ACALL PRINTLINE3
		ACALL CLEARLCD
		RET
		

SALAH:		
		ACALL PRINTLINE5
		ACALL CLEARLCD
		RET

SCAN_KEYPAD:	MOV A, #11111111B
		MOV P2,A 		;Select Port 2 sebagai input
		acall DELAY
		CLR P2.0 		;Menyalakan baris 1
		JB P2.4, LANJUT1 	;Cek apakah kolom 1 Ada yang menyala
		MOV A,#31H		;Copy 31H ke A
		RET


LANJUT1:	JB P2.5,LANJUT2		;Cek apakah kolom 2 Ada yang menyala
		MOV A,#32H
		RET

LANJUT2: 	JB P2.6,LANJUT3		;Cek apakah kolom 3 Ada yang menyala
		MOV A,#33H
		RET

LANJUT3: 	JB P2.7,LANJUT4		;Cek apakah kolom 4 Ada yang menyala
		MOV A,#41H
		RET

LANJUT4:	SETB P2.0		;Mematikan baris 1
		CLR P2.1 		;Menyalakan baris 2
		JB P2.4, LANJUT5 	;Cek apakah kolom 1 Ada yang menyala
		MOV A,#34H
		RET

LANJUT5:	JB P2.5,LANJUT6		;Cek apakah kolom 2 Ada yang menyala
		MOV A,#35H
		RET

LANJUT6: 	JB P2.6,LANJUT7		;Cek apakah kolom 3 Ada yang menyala
		MOV A,#36H
		RET

LANJUT7: 	JB P2.7,LANJUT8		;Cek apakah kolom 4 Ada yang menyala
		MOV A,#42H
		RET

LANJUT8:	SETB P2.1		;Mematikan baris 2
		CLR P2.2		;Menyalakan baris 3
		JB P2.4, LANJUT9 
		MOV A,#37H
		RET

LANJUT9:	JB P2.5,LANJUT10
		MOV A,#38H
		RET

LANJUT10: 	JB P2.6,LANJUT11
		MOV A,#39H
		RET

LANJUT11: 	JB P2.7,LANJUT12
		MOV A,#43H
		RET

LANJUT12:	SETB P2.2
		CLR P2.3
		JB P2.4, LANJUT13 
		MOV A,#2AH
		RET

LANJUT13:	JB P2.5,LANJUT14
		MOV A,#30H
		RET

LANJUT14: 	JB P2.6,LANJUT15
		MOV A,#23H
		RET

LANJUT15: 	JB P2.7,LANJUT16
		MOV A,#44H
		RET

LANJUT16:	LJMP SCAN_KEYPAD

DELAY:  MOV R4, #5		; delay total : 119,35 Î¼s perhitungan ada pada laporan
DELAY1: MOV TL0, #0FEH
 	MOV TH0, #0FFH
 	SETB TR0
LOOP:   JNB TF0, LOOP
 	CLR TR0
 	CLR TF0
 	DJNZ R4, DELAY1
 	RET

;------------------------------------------------------------------------------------------------
EXIT:
END
