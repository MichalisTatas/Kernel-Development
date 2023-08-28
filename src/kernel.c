#include "kernel.h"
#include <stdint.h>
#include <stddef.h>
#include "idt/idt.h"
#include "io/io.h"

uint16_t* video_mem = 0;
uint16_t terminal_row = 0;
uint16_t terminal_column = 0;

size_t strlen(const char* str)
{
    size_t len = 0;
    while (str[len])
        len++;

    return len;
}

uint16_t char_and_colour_to_two_bytes(char character, char colour)
{
    // we put first colour and then character while video memory wants the opposite because of indianess of intel processor
    return (colour << 8) | character;
}

void terminalPrintCharWithCoordinates(int x, int y, char character, char colour)
{
    video_mem[(y*VGA_WIDTH) + x] = char_and_colour_to_two_bytes(character, colour);
}

void terminalPrintCharSequentially(char character, char colour)
{

    if (character == '\n') {
        terminal_row += 1;
        terminal_column = 0;
        return;
    }

    terminalPrintCharWithCoordinates(terminal_column, terminal_row, character, colour);
    terminal_column += 1;

    if (terminal_column >= VGA_WIDTH) {
        terminal_column = 0;
        terminal_row += 1;
    }
}

void print(const char* str)
{
    size_t len = strlen(str);

    for (int i=0; i<len; i++)
        terminalPrintCharSequentially(str[i], 15);
}

// initializes terminal to a blank black terminal
void terminalInitialize()
{
    video_mem = (uint16_t*)(0xB8000);
    terminal_row = 0;
    terminal_column = 0;

    for (int y=0; y<VGA_HEIGHT; y++) {
        for (int x=0; x<VGA_WIDTH; x++) {
            terminalPrintCharWithCoordinates(x, y, ' ', 0);
        }
    }
}

void kernel_main()
{

    terminalInitialize();
    print("Hello world");

    //initialize interrupt descriptor table
    idt_init();

    outb(0x60, 0xff);

}