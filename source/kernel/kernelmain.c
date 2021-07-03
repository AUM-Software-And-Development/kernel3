#include "display.h"

void kernel_main()
{
    cleardisplay();
    setdisplaycolor(PRINT_COLOR_BLUE, PRINT_COLOR_DARK_GRAY);
    displaystring("This is a 64 bit kernel started in asm, and functioning by C.");
}