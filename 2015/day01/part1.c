#include <stdio.h>

int main(void) {
    int floor = 0;
    unsigned char c = 0;
    
    while((c = fgetc(stdin)) != '\n') {
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
    }

    printf("Floor is %d.\n", floor);
    return 0;
}