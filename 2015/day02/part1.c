#include <stdio.h>

int min(int a, int b) {
    if(a < b) {
        return a;
    } else {
        return b;
    }
}

int boxSize(int length, int width, int height) {
    int top = length * width;
    int side = length * height;
    int front = width * height;

    int slack = min(top, min(side, front));

    return ((top + side + front) * 2) + slack;
}

int main(void) {
    int total = 0;
    int length = 0;
    int width = 0;
    int height = 0;

    while(fscanf(stdin, "%dx%dx%d\n", &length, &width, &height) > 0) {
        int area = boxSize(length, width, height);
        printf("%dx%dx%d -> %d\n", length, width, height, area);

        total += area;
    }

    printf("\nTotal needed: %d\n", total);
    return 0;
}
