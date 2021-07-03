#include "print.h"

void kernel_main()
{
    print_clear();
    print_set_color(PRINT_COLOR_BLUE, PRINT_COLOR_DARK_GRAY);
    print_str("This is a 64 bit kernel started in asm, and functioning by C.");
}