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
    struct coord santa = (struct coord) {0, 0};
    struct coord robot = (struct coord) {0, 0};
    struct house *start = makeHouse(santa);
    int numVisited = 1;
    unsigned char c;
    char* who = "santa";

    struct coord *pos = &santa;

    while((c = fgetc(stdin)) != '\n') {

        switch(c) {
            case '^' :
                pos->y += 1;
                break;
            case '>':
                pos->x += 1;
                break;
            case 'v' :
                pos->y -= 1;
                break;
            case '<':
                pos->x -= 1;
                break;
            default:
                printf("Unsupported character.");
                break;
        }

        printf("(%c) %s visiting (%d, %d)\n", c, who, pos->x, pos->y);
        numVisited += visitHouse(start, *pos);

        if(pos == &santa) {
            pos = &robot;
            who = "robot";
        } else {
            pos = &santa;
            who = "santa";
        }
    }

    printf("\nTotal visited: %d\n", numVisited);
    return 0;
}
