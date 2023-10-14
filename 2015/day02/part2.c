#include <stdio.h>

int min(int a, int b) {
    if(a < b) {
        return a;
    } else {
        return b;
    }
}

int ribbonLength(int length, int width, int height) {
    int top = (length + width) * 2;
    int side = (length + height) * 2;
    int front = (width + height) * 2;

    return min(top, min(side, front));
}

int bowSize(int length, int width, int height) {
    return length * width * height;
}

int main(void) {
    int total = 0;
    int length = 0;
    int width = 0;
    int height = 0;

    while(fscanf(stdin, "%dx%dx%d\n", &length, &width, &height) > 0) {
        int ribbon = ribbonLength(length, width, height);
        int bow = bowSize(length, width, height);
        printf("%dx%dx%d -> %d + %d\n", length, width, height, ribbon, bow);

        total += ribbon + bow;
    }

    printf("\nTotal needed: %d\n", total);
    return 0;
}