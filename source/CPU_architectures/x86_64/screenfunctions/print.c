#include "print.h"
void clearrow(); /* push-ahead */
void clearbyrow();

const static size_t Column_Sum = 80;
const static size_t Row_Sum = 25;

int8_t color = PRINT_COLOR_WHITE | PRINT_COLOR_DARK_GRAY << 4; /* default color palet */

struct Char* displaybuffer = (struct Char*) 0xb8000;

struct Char {
    uint8_t character;
    uint8_t color;
};

size_t col = 0;
size_t row = 0;

/* Declaring delegates */

struct Char characterdefault;

/*
*
*/

void cleardisplay() {
    clearbyrow();
}

void clearrow(int row) 
{
    characterdefault.character = ' ';
    characterdefault.color = color;

    for (int col = 0; col < Column_Sum; col++) {
        displaybuffer[col + Column_Sum * row] = characterdefault;
    }
}

void clearbyrow() {
    for (int i = 0; i < Row_Sum; i++) {
    clearrow(i);
    }
}

void newline() {
    col = 0;
    struct Char characterswitch;

    if (row < Row_Sum - 1) {
        row++;
        return;
    }

    for (int row = 1; row < Row_Sum; row++) {
        for (int col = 0; col < Column_Sum; col++) {
            characterswitch = displaybuffer[col + Column_Sum * row];
            displaybuffer[col + Column_Sum * (row - 1)] = characterswitch;
        }
    }

    clearrow(Column_Sum - 1);
}

void displaycharacter(char character) {
    if (character == '\n') {
        newline();
        return;
    }

    if (col > Column_Sum) {
        newline();
    }

    displaybuffer[col + Column_Sum * row] = (struct Char) {
        character: (uint8_t) character,
        color: color,
    };

    col++;
}

void displaystring(char* str) {
    for (size_t i = 0; 1; i++) {
        char character = (uint8_t) str[i];

        if (character == '\0') {
            return;
        }

        displaycharacter(character);
    }
}

void setdisplaycolor(uint8_t foreground, uint8_t background)
{
    color = foreground + (background << 4); /* foreground and background fit into 1 byte */
}