#include <stdio.h>
#include <stdlib.h>
#include <string.h>

enum Command {
    ON = 8,
    OFF = 9,
    TOGGLE = 7
};

struct Instruction {
    enum Command command;
    int left;
    int top;
    int right;
    int bottom;
};

enum Command parseCommand(const char *line) {
    if(line[1] == 'o') {
        return TOGGLE;
    } else if (line[6] == 'n') {
        return ON;
    } else {
        return OFF;
    }
}

struct Instruction parse(const char *line) {
    struct Instruction i;
    i.command = parseCommand(line);

    line += (int)(i.command);
    sscanf(
        line, "%d,%d through %d,%d", 
        &i.left, &i.top, &i.right, &i.bottom
    );

    printf(
        "Command %d: %d, %d through %d, %d\n", 
        i.command, i.left, i.top, i.right, i.bottom
    );
    return i;
}

void execute(struct Instruction i, int lights[1000][1000]) {
    int increment;

    switch(i.command) {
        case ON:
            increment = 1;
            break;
        case OFF: 
            increment = -1;
            break;
        case TOGGLE:
            increment = 2;
            break;
    }

    for(int x = i.left; x <= i.right; x++) {
        for(int y = i.top; y <= i.bottom; y++) {
            int level = lights[x][y] + increment;
            lights[x][y] = (level > 0) ? level : 0;
        }
    }
}

int countlit(const int lights[1000][1000]) {
    int count = 0;
    for(int i = 0; i < 1000; i++) {
        for(int j = 0; j < 1000; j++) {
            count += lights[i][j];
        }
    }
    return count;
}

int main(void) {
    char *line = NULL;
    size_t bufSize = 0;
    size_t numRead;

    int lights[1000][1000] = { 0 };

    while(-1 != (numRead = getline(&line, &bufSize, stdin))) {
        printf("\n%s", line);

        struct Instruction instruction = parse(line);
        execute(instruction, lights);

        int numlit = countlit(lights);
        printf("%d total light.\n", numlit);
    }


    return 0;
}
