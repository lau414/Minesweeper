.586
.MODEL FLAT, C


; Funcions definides en C
printChar_C PROTO C, value:SDWORD
printInt_C PROTO C, value:SDWORD
clearscreen_C PROTO C
clearArea_C PROTO C, value:SDWORD, value1: SDWORD
printMenu_C PROTO C
gotoxy_C PROTO C, value:SDWORD, value1: SDWORD
getch_C PROTO C
printBoard_C PROTO C, value: DWORD
initialPosition_C PROTO C
win PROTO C
lose PROTO C

.code   
   
;;Macros que guarden y recuperen de la pila els registres de proposit general de la arquitectura de 32 bits de Intel  
Push_all macro
	
	push eax
   	push ebx
    push ecx
    push edx
    push esi
    push edi
endm


Pop_all macro

	pop edi
   	pop esi
   	pop edx
   	pop ecx
   	pop ebx
   	pop eax
endm
   
   
public C posCurScreenP1, getMoveP1, moveCursorP1, movContinuoP1, openP1, openContinuousP1
                         

extern C opc: SDWORD, row:SDWORD, col: BYTE, carac: BYTE, carac2: BYTE, mineField: BYTE, taulell: BYTE, indexMat: SDWORD
extern C rowCur: SDWORD, colCur: BYTE, rowScreen: SDWORD, colScreen: SDWORD, RowScreenIni: SDWORD, ColScreenIni: SDWORD
extern C rowIni: SDWORD, colIni: BYTE, indexMatIni: SDWORD
extern C neighbours: SDWORD, marks: SDWORD, endGame: SDWORD, victory: SDWORD

;****************************************************************************************

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Situar el cursor en una fila i una columna de la pantalla
; en funció de la fila i columna indicats per les variables colScreen i rowScreen
; cridant a la funció gotoxy_C.
;
; Variables utilitzades: 
; Cap
; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;gotoxy:
gotoxy proc
   push ebp
   mov  ebp, esp
   Push_all

   ; Quan cridem la funció gotoxy_C(int row_num, int col_num) des d'assemblador 
   ; els paràmetres s'han de passar per la pila
      
   mov eax, [colScreen]
   push eax
   mov eax, [rowScreen]
   push eax
   call gotoxy_C
   pop eax
   pop eax 
   
   Pop_all

   mov esp, ebp
   pop ebp
   ret
gotoxy endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Mostrar un caràcter, guardat a la variable carac
; en la pantalla en la posició on està  el cursor,  
; cridant a la funció printChar_C.
; 
; Variables utilitzades: 
; carac : variable on està emmagatzemat el caracter a treure per pantalla
; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;printch:
printch proc
   push ebp
   mov  ebp, esp
   ;guardem l'estat dels registres del processador perqué
   ;les funcions de C no mantenen l'estat dels registres.
   
   
   Push_all
   

   ; Quan cridem la funció  printch_C(char c) des d'assemblador, 
   ; el paràmetre (carac) s'ha de passar per la pila.
 
   xor eax,eax
   mov  al, [carac]
   push eax 
   call printChar_C
 
   pop eax
   Pop_all

   mov esp, ebp
   pop ebp
   ret
printch endp
   
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Llegir un caràcter de teclat   
; cridant a la funció getch_C
; i deixar-lo a la variable carac2.
;
; Variables utilitzades: 
; carac2 : Variable on s'emmagatzema el caracter llegit
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;getch:
getch proc
   push ebp
   mov  ebp, esp
    
   ;push eax
   Push_all

   call getch_C
   
   mov [carac2],al
   
   ;pop eax
   Pop_all

   mov esp, ebp
   pop ebp
   ret
getch endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Posicionar el cursor a la pantalla, dins el tauler, en funció de
; les variables (row) fila (int) i (col) columna (char), a partir dels
; valors de les constants RowScreenIni i ColScreenIni.
; Primer cal restar 1 a row (fila) per a que quedi entre 0 i 7 
; i convertir el char de la columna (A..H) a un número entre 0 i 7.
; Per calcular la posició del cursor a pantalla (rowScreen) i 
; (colScreen) utilitzar aquestes fórmules:
; rowScreen=rowScreenIni+(row*2)
; colScreen=colScreenIni+(col*4)
; Per a posicionar el cursor cridar a la subrutina gotoxy.
;
; Variables utilitzades:	
; row       : fila per a accedir a la matriu mineField/taulell
; col       : columna per a accedir a la matriu mineField/taulell
; rowScreen : fila on volem posicionar el cursor a la pantalla.
; colScreen : columna on volem posicionar el cursor a la pantalla.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;posCurScreenP1:
posCurScreenP1 proc
    push ebp
	mov  ebp, esp
	Push_all
	mov eax, [row]
	dec eax
	imul eax, 2
	add eax, [rowScreenIni]
	mov [rowScreen], eax

	mov eax, 0
	mov al, [col]
	sub eax, 'A'
	imul eax, 4
	add eax, [colScreenIni]
	mov [colScreen], eax
	call gotoxy

	Pop_all
	mov esp, ebp
	pop ebp
	ret
posCurScreenP1 endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Llegir un caràcter de teclat   
; cridant a la subrutina getch
; Verificar que solament es pot introduir valors entre 'i' i 'l', 
; o les tecles espai ' ', 'm' o 's' i deixar-lo a la variable carac2.
; 
; Variables utilitzades: 
; carac2 : Variable on s'emmagatzema el caràcter llegit
; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;getMoveP1:
getMoveP1 proc
   push ebp
   mov  ebp, esp
   Push_all

   bucle:
   call getch
   cmp carac2, 'i'
   jl eti1
   cmp carac2, 'l'
   jg eti1
   jmp fi

   eti1:
   cmp carac2, 'm'
   je fi
   cmp carac2, 's'
   je fi
   cmp carac2, ' '
   je fi
   jmp bucle 

   fi:
   Pop_all
   mov esp, ebp
   pop ebp
   ret
getMoveP1 endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Actualitzar les variables (rowCur) i (colCur) en funció de 
; la tecla premuda que tenim a la variable (carac2)
; (i: amunt, j:esquerra, k:avall, l:dreta).
; Comprovar que no sortim del taulell, (rowCur) i (colCur) només poden 
; prendre els valors [1..8] i ['A'..'H']. Si al fer el moviment es surt 
; del tauler, no fer el moviment.
; No posicionar el cursor a la pantalla, es fa a posCurScreenP1.
; 
; Variables utilitzades: 
; carac2 : caràcter llegit de teclat
;          'i': amunt, 'j':esquerra, 'k':avall, 'l':dreta
; rowCur : fila del cursor a la matriu mineField.
; colCur : columna del cursor a la matriu mineField.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;moveCursorP1: proc endp
moveCursorP1 proc
   push ebp
   mov  ebp, esp 
   Push_all

   mov eax, 0
   cmp [carac2], 'i'
   jne esquerra
   mov eax, [rowCur]
   dec eax
   cmp eax, 1
   jl fi
   mov [rowCur], eax
   jmp fi

   mov eax, 0
   esquerra:
   cmp [carac2], 'j'
   jne avall
   mov al, [colCur]
   dec eax
   cmp eax, 'A'
   jl fi
   mov [colCur], al
   jmp fi

   mov eax, 0
   avall:
   cmp [carac2], 'k'
   jne dreta
   mov eax, [rowCur]
   inc eax
   cmp eax, 8
   jg fi
   mov [rowCur], eax
   jmp fi

   mov eax, 0
   dreta:
   cmp [carac2], 'l'
   jne fi
   mov al, [colCur]
   inc eax
   cmp eax, 'H'
   jg fi
   mov [colCur], al
   jmp fi

   fi:
   Pop_all
   mov esp, ebp
   pop ebp
   ret
moveCursorP1 endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Subrutina que implementa el moviment continuo. 
;
; Variables utilitzades: 
;		carac2   : variable on s’emmagatzema el caràcter llegit
;		rowCur   : Fila del cursor a la matriu mineField
;		colCur   : Columna del cursor a la matriu mineField
;		row      : Fila per a accedir a la matriu mineField
;		col      : Columna per a accedir a la matriu mineField
; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;movContinuoP1: proc endp
movContinuoP1 proc
	push ebp
	mov  ebp, esp
	Push_all
   bucleMov:
   
   call getMoveP1
   call moveCursorP1
   mov eax, [rowCur]
   mov row, eax
   mov al, [colCur]
   mov col, al
   call posCurScreenP1

   cmp [carac2], 'm'
   je fi2
   cmp [carac2], 's'
   je fi2
   cmp [carac2], ' '
   je fi2
   
   jmp bucleMov

   fi2:
   Pop_all
	mov esp, ebp
	pop ebp
	ret
movContinuoP1 endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Calcular l'índex per a accedir a les matrius en assemblador.
; mineField[row][col] en C, és [mineField+indexMat] en assemblador.
; on indexMat = row*8 + col (col convertir a número).
;
; Variables utilitzades:	
; row       : fila per a accedir a la matriu mineField
; col       : columna per a accedir a la matriu mineField
; indexMat  : índex per a accedir a la matriu mineField
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;calcIndexP1: proc endp
calcIndexP1 proc
	push ebp
	
	mov  ebp, esp
	Push_all
	mov eax, row
	dec eax
	mov ebx, 0
	mov bl, col
	sub bl,65
	imul eax, 8
	add eax, ebx
	mov [indexMat], eax
	Pop_all
	mov esp, ebp
	pop ebp
	
	ret
calcIndexP1 endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Obrim una casella de la matriu mineField
; En primer lloc calcular la posició de la matriu corresponent a la
; posició que ocupa el cursor a la pantalla, cridant a la 
; subrutina calcIndexP1.
; En cas de que la casella no estigui oberta ni marcada mostrar:
;	- 'X' si hi ha una mina
;	- 'm' si volem marcar la casella
;	- el numero de veïns si obrim una casella sense mina (crida a la subrutina sumNeighbours)
; En cas de que la casella estigui marcada mostrar:
;	- ' ' si volem desmarcar la casella
; Mostrarem el contingut de la casella criant a la subrutina printch. L'índex per
; a accedir a la matriu mineField, el calcularem cridant a la subrutina calcIndexP1.
; No es pot obrir una casella que ja tenim oberta o marcada.

;NIVELL MIG
; Cada vegada que marquem/desmarquem una casella, actualitzar el número de marques restants 
; cridant a la subrutina updateMarks.
; Si obrim una casella amb mina actualitzar el valor endGame a -1.

;NUVELL AVANÇAT
; Finalment, per al nivell avançat, si obrim una casella sense mina y amb 
; 0 mines al voltant, cridarem a la subrutina openBorders del nivell avançat.
;
; Variables utilitzades:	
; row       : fila per a accedir a la matriu mineField
; rowCur    : fila actual del cursor a la matriu
; col       : columna per a accedir a la matriu mineField
; colCur    : columna actual del cursor a la matriu 
; indexMat  : Índex per a accedir a la matriu mineField
; mineField : Matriu 8x8 on tenim les posicions de les mines. 
; carac	    : caràcter per a escriure a pantalla.
; taulell   : Matriu en la que anem indicant els valors de les nostres tirades 
; endGame   : Quan és igual a 1 determina que el joc ha acabat
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;openP1: proc endp
openP1 proc
	push ebp
	mov  ebp, esp
	Push_all
	call calcIndexP1
	mov ebx, [indexMat]
	mov al, [mineField+ebx]

	mov ecx, [indexMat]
	mov bl, [taulell+ecx]
	
	;QUITAR M
	cmp bl, 'm' 
	jne eti1
	cmp [carac2], 'm'
	jne eti1
	mov [carac], ' '
	mov [taulell+ecx], ' '
	jmp fi

	;PONER M o ABRIR
	eti1:
	cmp bl, ' '
	jne fi_def
	cmp [carac2], 'm'
	jne abrir
	cmp [marks], 0
	je fi_def
	mov [carac], 'm'
	mov [taulell+ecx], 'm'
	jmp fi

	abrir:
	cmp [carac2], ' '
	jne fi
	mov [taulell+ecx], '0'
	cmp al,0
	jne mina
	call countMines
	cmp [neighbours],0
	jne sig
	call openBorders

	sig:
	call countMines
	mov edx, [neighbours]
	add dl, '0'
	mov [carac], dl
	
	jmp fi

	mina:
	cmp al, 1
	jne fi
	mov [carac], 'x'
	mov [endGame], -1 ;HEM PERDUT
	

    fi:
	call printch
	call posCurScreenP1

	fi_def:
	call updateMarks
	call checkWin ;;CRIDA

	Pop_all
	mov esp, ebp
	pop ebp
	ret
openP1 endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Subrutina que implementa l’obertura continua de caselles. S’ha d’utilitzar
; la tecla espai per a obrir una casella i la 's' per a sortir. 
; Per a cada moviment introduït comprovar si hem guanyat el joc cridant a 
; la subrutina checkWin, o bé si hem perdut el joc (endGame!=0).
;
; Variables utilitzades: 
; carac2   : Caràcter introduït per l’usuari
; rowCur   : Fila del cursor a la matriu mineField
; colCur   : Columna del cursor a la matriu mineField
; row      : Fila per a accedir a la matriu mineField
; col      : Columna per a accedir a la matriu mineField
; endGame  : flag per indicar si hem perdut (0=no hem perdut, 1=hem perdut)
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;openContinuousP1:proc endp
openContinuousP1 proc
	push ebp
	mov  ebp, esp
	Push_all
	continua:
	cmp [victory], 1
	je fi
	cmp [endGame], -1
	je fi
	call movContinuoP1
	call openP1

	cmp [carac2], 's'
	je fi
	jmp continua
		
	fi:
	Pop_all
	mov esp, ebp
	pop ebp
	ret
openContinuousP1 endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Modificar el nombre de marques encara disponibles.
; Recórrer el taullel per comptar les marques posades ('m') i restar aquest valor a les inicials (9).
; Imprimir el nou valor a la posició indicada (rowScreen = 3, colScreen = 57), tenint
; en compte que hi haurem de sumar el valor '0' pel format ASCII.
;
; Variables utilitzades: 
; taulell   : Matriu en la que anem indicant els valors de les nostres tirades 
; rowScreen : Fila de la pantalla
; colScreen : Columna de la pantalla
; marks     : Nombre de mines no marcades
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
updateMarks proc
	push ebp
	mov  ebp, esp
	Push_all
	mov eax, 0
	mov [marks], 9

	bucle:
	cmp eax, 64
	jge fi
	mov bl, [taulell+eax]
	cmp bl, 'm'
	jne no_mark

	;DECREMENTA MARKS NO PUESTAS
	dec [marks]

	no_mark:
	inc eax
	jmp bucle

	fi:

	mov [rowScreen], 3
	mov [colScreen], 57
	mov ecx, [marks]
	add cl, '0'
	mov [carac], cl
	call gotoxy
	call printch
	call posCurScreenP1
	Pop_all
	mov esp, ebp
	pop ebp
	ret
updateMarks endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Comptar el nombre de mines a les cel·les veïnes (les vuit del voltant). 
; S'ha de comprovar que no accedim a posicions de fora el mineField per comptar les mines.
; Guardar el nombre de mines de les cel·les a la variable neighbours.
;
; Variables utilitzades: 
; taulell    : Matriu en la que anem indicant els valors de les nostres tirades 
; mineField  : Matriu 8x8 on tenim les posicions de les mines. 
; neighbours : Numero de veïns
; col        : Columna del cursor a la matriu mineField
; row        : Fila del cursor a la matriu mineField
; indexMat   : Índex per a accedir a la matriu mineField
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
countMines proc
	push ebp
	mov  ebp, esp
	;esqDalt   dalt   dretDalt
	;esq              dret
	;esqBaix   baix   dretBaix
	Push_all
	mov [neighbours],0
	mov eax,[row]
	mov bl,[col]

	EA:
	dec [row]
	dec [col]
	cmp [row],1
	jl A
	cmp [col],'A'
	jl A

	call calcIndexP1
	mov ecx, [indexMat]
	mov dl, [mineField+ecx]

	cmp dl, 1
	jne A
	add [neighbours], 1

	A:
	inc [col]
	cmp [row],1
	jl AD

	call calcIndexP1
	mov ecx, [indexMat]
	mov dl, [mineField+ecx]

	cmp dl, 1
	jne AD
	add [neighbours], 1

	AD:
	inc [col]
	cmp [row],1
	jl D
	cmp [col],'H'
	jg D

	call calcIndexP1
	mov ecx, [indexMat]
	mov dl, [mineField+ecx]

	cmp dl, 1
	jne D
	add [neighbours], 1

	D:
	inc [row]
	cmp [col],'H'
	jg BD

	call calcIndexP1
	mov ecx, [indexMat]
	mov dl, [mineField+ecx]

	cmp dl, 1
	jne BD
	add [neighbours], 1

	BD:
	inc [row]
	cmp [row],8
	jg B
	cmp [col],'H'
	jg B

	call calcIndexP1
	mov ecx, [indexMat]
	mov dl, [mineField+ecx]

	cmp dl, 1
	jne B
	add [neighbours], 1

	B:
	dec [col]
	cmp [row],8
	jg EB
	
	call calcIndexP1
	mov ecx, [indexMat]
	mov dl, [mineField+ecx]

	cmp dl, 1
	jne EB
	add [neighbours], 1
	
	EB:
	dec [col]
	cmp [row],8
	jg E
	cmp [col],'A'
	jl E
	
	call calcIndexP1
	mov ecx, [indexMat]
	mov dl, [mineField+ecx]

	cmp dl, 1
	jne E
	add [neighbours], 1

	E:
	dec [row]
	cmp [col],'A'
	jl fi
	
	call calcIndexP1
	mov ecx, [indexMat]
	mov edx, 0
	mov dl, [mineField+ecx]

	cmp dl, 1
	jne fi
	add [neighbours], 1

	fi:

	mov [row],eax
	mov [col],bl

	Pop_all
	mov esp, ebp
	pop ebp
	ret
countMines endp


abre proc
	push ebp
	mov  ebp, esp
	Push_all

	call calcIndexP1
	mov ebx, [indexMat]
	mov cl, [taulell+ebx]

	;no hay vecinos y esta cerrada
	cmp cl, ' '
	jne sig_def
	mov [taulell+ebx], '0'
	call countMines
	mov edx, [neighbours]
	add dl, '0'
	mov [carac], dl

	mov eax, [row]
	mov cl, [col]

	call posCurScreenP1
	call printch
	cmp [neighbours],0
	jne sig
	call openBorders
	

	sig:

	mov [row],eax
	mov [col],cl

	sig_def:

	Pop_all
	mov esp, ebp
	pop ebp
	ret
abre endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Obrir les cel·les veïnes si la cel·la actual té 0 mines veïnes.
; Fer aquest procès recursivament sempre que una nova cel·la oberta tingui 0 mines veïnes.
; S'ha de comprovar que no accedim a posicions de fora el taullel en obrir noves cel·les.
;
; Variables utilitzades: 
; taulell   : Matriu en la que anem indicant els valors de les nostres tirades 
; neighbours : Caràcter introduït per l’usuari
; col        : Fila del cursor a la matriu mineField
; row        : Columna del cursor a la matriu mineField
; indexMat   : Índex per a accedir a la matriu mineField
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

openBorders proc
	push ebp
	mov  ebp, esp
	Push_all
	mov eax,[row]
	mov bl,[col]
	
	call countMines
	cmp [neighbours],0
	jne fi

	EA:
	dec [row]
	dec [col]
	cmp [row],1
	jl A
	cmp [col],'A'
	jl A

	call abre

	A:
	inc [col]
	cmp [row],1
	jl AD

	call abre

	AD:
	inc [col]
	cmp [row],1
	jl D
	cmp [col],'H'
	jg D

	call abre

	D:
	inc [row]
	cmp [col],'H'
	jg BD

	call abre

	BD:
	inc [row]
	cmp [row],8
	jg B
	cmp [col],'H'
	jg B

	call abre

	B:
	dec [col]
	cmp [row],8
	jg EB
	
	call abre
	
	EB:
	dec [col]
	cmp [row],8
	jg E
	cmp [col],'A'
	jl E
	
	call abre

	E:
	dec [row]
	cmp [col],'A'
	jl fi
	
call abre
	
	

	fi:
	mov edx, 0
	mov [row],eax
	mov [col],bl
	call posCurScreenP1
	Pop_all
	mov esp, ebp
	pop ebp
	ret
openBorders endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Comprovar que queden 0 mines per marcar i que estan correctament marcades.
; Per fer-ho, recórrer la matriu per comprovar que a les posicions on hi ha mines també hi ha marques.
; Guardar a la variable victory un 1 si s'ha guanyat la partida i un 0 si encara no s'ha guanyat.
;
; Variables utilitzades: 
; taulell    : Matriu en la que anem indicant els valors de les nostres tirades 
; mineField  : Matriu 8x8 on tenim les posicions de les mines. 
; victory    : Variable que indica la victòria en el joc.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
checkWin proc
	push ebp
	mov  ebp, esp
	Push_all

	;mov [victory], 0

	;Cas: hem obert mina
	cmp [endGame], -1
	je perdut
	
	;Cas: tot obert i marks sobre mines
	mov eax, 0

	mov ecx, 0 ;var count caselles obertes

	bucle:
	cmp eax, 64
	jge comprova
	mov bl, [taulell+eax]
	cmp bl, 'm'
	jne sub_bucle
	mov dl, [mineField+eax]
	cmp dl, 1
	jne sub_bucle
	add ecx,1
	jmp sub_bucle

	sub_bucle:
	add eax,1
	jmp bucle


	comprova:
	cmp ecx, 9
	jne fi
	cmp [marks], 0
	jne fi
	
	;Ha guanyat
	mov [victory], 1
	call win
	jmp fi

	perdut:
	call lose

	fi:

	Pop_all
	mov esp, ebp
	pop ebp
	ret
checkWin endp

END
