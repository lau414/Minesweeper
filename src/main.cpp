// ConsoleApplication2.cpp : Este archivo contiene la función "main". La ejecución del programa comienza y termina ahí.
//

#include "globals.h"
#include <iostream>


#include <stdio.h>
#include <conio.h>
#include <iomanip>
#include<stdlib.h>
#include<time.h>
#include<windows.h>

extern "C" {
	// Subrutines en ASM

	void posCurScreenP1();
	void moveCursorP1();
	void openP1();
	void getMoveP1();
	void movContinuoP1();
	void openContinuousP1();

	void lose();
	void win();

	void printChar_C(char c);
	int clearscreen_C();
	int gotoxy_C(int row_num, int col_num);
	char getch_C();
	int printBoard_C(int tries);
	void continue_C();
}

#define DimMatrix 8

int row = 0;			//fila de la pantalla
char col = 'A';   		//columna actual de la pantalla*/
int rowIni;
char colIni;

char carac, carac2;

int opc;
int indexMat;
int indexMatIni;
int rowScreen;
int colScreen;
int RowScreenIni;
int ColScreenIni;

int neighbours;
int marks;
int endGame;
int victory;


//Mostrar un caràcter
//Quan cridem aquesta funció des d'assemblador el paràmetre s'ha de passar a traves de la pila.
void printChar_C(char c) {
	putchar(c);
}

//Esborrar la pantalla
int clearscreen_C() {
	system("CLS");
	return 0;
}

int migotoxy(int x, int y) { //USHORT x,USHORT y) {
	COORD cp = { y,x };
	SetConsoleCursorPosition(GetStdHandle(STD_OUTPUT_HANDLE), cp);
	return 0;
}

//Situar el cursor en una fila i columna de la pantalla
//Quan cridem aquesta funció des d'assemblador els paràmetres (row_num) i (col_num) s'ha de passar a través de la pila
int gotoxy_C(int row_num, int col_num) {
	migotoxy(row_num, col_num);
	return 0;
}

//Funció que inicialitza les variables més importants del joc
void init_game() {
	for (int i = 0; i < 8; i++) {           //Inicialitza totes les posicions de la matriu taulell a 0 (totes les caselles tapades)   
		for (int j = 0; j < 8; j++) {
			taulell[i][j] = ' ';
		}
	}
}

//Llegir una tecla sense espera i sense mostrar-la per pantalla
char getch_C() {
	DWORD mode, old_mode, cc;
	HANDLE h = GetStdHandle(STD_INPUT_HANDLE);
	if (h == NULL) {
		return 0; // console not found
	}
	GetConsoleMode(h, &old_mode);
	mode = old_mode;
	SetConsoleMode(h, mode & ~(ENABLE_ECHO_INPUT | ENABLE_LINE_INPUT));
	TCHAR c = 0;
	ReadConsole(h, &c, 1, &cc, NULL);
	SetConsoleMode(h, old_mode);

	return c;
}

//Funcions que mostren el resultat final del joc
void lose() {
	gotoxy_C(RowScreenIni + (DimMatrix * 2) + 1, ColScreenIni - 7);
	printf("                                                          ");
	gotoxy_C(RowScreenIni + (DimMatrix * 2) + 2, ColScreenIni - 7);
	printf("                                                          ");
	gotoxy_C(RowScreenIni + (DimMatrix * 2) + 3, ColScreenIni - 2);
	printf("                                                          ");
	gotoxy_C(RowScreenIni + (DimMatrix * 2) + 1, ColScreenIni + 10);
	printf("GAME OVER");
	gotoxy_C(RowScreenIni + (DimMatrix * 2) + 2, ColScreenIni - 2);
	printf("Press any key to start a new game");
	getch_C();
}

void win() {
	gotoxy_C(RowScreenIni + (DimMatrix * 2) + 1, ColScreenIni - 7);
	printf("                                                          ");
	gotoxy_C(RowScreenIni + (DimMatrix * 2) + 2, ColScreenIni - 7);
	printf("                                                          ");
	gotoxy_C(RowScreenIni + (DimMatrix * 2) + 3, ColScreenIni - 2);
	printf("                                                          ");
	gotoxy_C(RowScreenIni + (DimMatrix * 2) + 1, ColScreenIni + 1);
	printf("CONGRATS YOU WIN ! ! !");
	gotoxy_C(RowScreenIni + (DimMatrix * 2) + 2, ColScreenIni - 2);
	printf("Press any key to start a new game");
	getch_C();
}

/**
* Mostrar el tauler de joc a la pantalla. Les línies del tauler.
*
* Aquesta funció es crida des de C i des d'assemblador,
* i no hi ha definida una subrutina d'assemblador equivalent.
* No hi ha pas de paràmetres.
*/
void printBoard_C() {

	int i, j, r = 1, c = 25;

	clearscreen_C();
	gotoxy_C(r++, 25);
	printf("===================================");
	gotoxy_C(r++, c);			//Tí­tol
	printf("           MINESWEEPER             ");
	gotoxy_C(r++, c);
	printf("                        marks:  %d  ", marks);
	gotoxy_C(r++, 25);
	printf("===================================");
	gotoxy_C(r++, c);			//Coordenades
	printf("    A   B   C   D   E   F   G   H   ");
	for (i = 0; i < DimMatrix; i++) {
		gotoxy_C(r++, c);
		printf("  +");			// "+" cantonada inicial
		for (j = 0; j < DimMatrix; j++) {
			printf("---+");		//segment horitzontal	
		}
		gotoxy_C(r++, c);
		printf("%i |", i + 1);	//Coordenades
		for (j = 0; j < DimMatrix; j++) {
			printf(" %c |", taulell[i][j]);		//lí­nies verticals
		}
	}
	gotoxy_C(r++, c);
	printf("  +");
	for (j = 0; j < DimMatrix; j++) {
		printf("---+");
	}

}


int main(void)
{
	int i, j;
	opc = 1;
	rowCur = 5;
	colCur = 'C';
	RowScreenIni = 7;
	ColScreenIni = 29;

	while (opc != 's') {
		marks = 9;
		endGame = 0;
		char mineField[8][8] = {
		{ 1,0,0,0,0,0,0,0 },
		{ 0,0,0,1,0,0,1,0 },
		{ 0,0,0,0,0,0,0,0 },
		{ 0,1,0,0,0,1,0,0 },
		{ 0,0,0,0,0,0,0,0 },
		{ 0,0,0,1,0,1,0,0 },
		{ 0,0,0,0,0,0,0,0 },
		{ 0,1,0,0,1,0,0,0 } };
		init_game();                    //Inicialitzar variables importants del joc
		for (i = 0; i < 8; i++)
			for (j = 0; j < 8; j++)
				taulell[i][j] = ' ';
		
		clearscreen_C();  	//Esborra la pantalla
		printBoard_C();   	//Mostrar el tauler.
		rowCur = 5;
		colCur = 'D';
		//			RowScreenIni = 7;
		//			ColScreenIni = 29;
		gotoxy_C(RowScreenIni + (DimMatrix * 2) + 1, ColScreenIni - 2);
		printf("up I | left J | down K | right L");
		gotoxy_C(RowScreenIni + (DimMatrix * 2) + 2, ColScreenIni + 1);
		printf(" open [espace] | mark M");
		gotoxy_C(RowScreenIni + (DimMatrix * 2) + 3, ColScreenIni );
		printf("Press s to start a new game");

		row = rowCur;
		col = colCur;
		posCurScreenP1();    //Posicionar el cursor a pantalla.

		carac2 = 0;
		openContinuousP1();  //Obrir contínuament les caselles del tauler
	}

	gotoxy_C(19, 1);	//Situar el cursor a la fila 19
	return 0;


}

// Ejecutar programa: Ctrl + F5 o menú Depurar > Iniciar sin depurar
// Depurar programa: F5 o menú Depurar > Iniciar depuración

// Sugerencias para primeros pasos: 1. Use la ventana del Explorador de soluciones para agregar y administrar archivos
//   2. Use la ventana de Team Explorer para conectar con el control de código fuente
//   3. Use la ventana de salida para ver la salida de compilación y otros mensajes
//   4. Use la ventana Lista de errores para ver los errores
//   5. Vaya a Proyecto > Agregar nuevo elemento para crear nuevos archivos de código, o a Proyecto > Agregar elemento existente para agregar archivos de código existentes al proyecto
//   6. En el futuro, para volver a abrir este proyecto, vaya a Archivo > Abrir > Proyecto y seleccione el archivo .sln
