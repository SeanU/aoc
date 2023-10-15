#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

struct coord {
    int x;
    int y;
};

struct house {
    struct coord location;
    struct house *next;
};

bool coordEqual(struct coord a, struct coord b) {
    return (a.x == b.x) && (a.y == b.y);
}

struct house * makeHouse(struct coord position) {
    struct house *h = (struct house *) malloc(sizeof(struct house));
    h->location = position;
    h->next = NULL;
    return h;
}

int visitHouse(struct house *curHouse, struct coord pos) {
    if(coordEqual(curHouse->location, pos)) {
        return 0;
    } else if(curHouse->next == NULL) {
        curHouse->next = makeHouse(pos);
        return 1;
    } else {
        return visitHouse(curHouse->next, pos);
    }
}

int main(void) {
    struct coord position = (struct coord) {0, 0};
    struct house *start = makeHouse(position);
    int numVisited = 1;
    unsigned char c;

    while((c = fgetc(stdin)) != '\n') {
        switch(c) {
            case '^' :
                position.y += 1;
                break;
            case '>':
                position.x += 1;
                break;
            case 'v' :
                position.y -= 1;
                break;
            case '<':
                position.x -= 1;
                break;
            default:
                printf("Unsupported character.");
                break;
        }

        printf("(%c) Visiting (%d, %d):\n", c, position.x, position.y);
        numVisited += visitHouse(start, position);
    }

    printf("\nTotal visited: %d\n", numVisited);
    return 0;
}
