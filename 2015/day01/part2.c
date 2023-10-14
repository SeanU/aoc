#include <stdio.h>

int main(void) {
    int floor = 0;
    unsigned char c = 0;
    int cursor = 0;
    
    while((c = fgetc(stdin)) != '\n') {
        cursor += 1;
        switch(c) {
            case '(' :
                floor += 1;
                break;
            case ')':
                floor -= 1;
                break;
            default:
                printf("Unsupported character.");
                break;
        }
        if(floor < 0) {
            break;
        }
    }

    printf("Entered basemen at position %d\n", cursor);
    return 0;
}