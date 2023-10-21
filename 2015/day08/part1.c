#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>
#include <string.h>

void chop_newline(char *line) {
    for(int i = 0; i < strlen(line); i++) {
        if(line[i] == '\n') {
            line[i] = '\0';
        }
    }
}

int count_chars(const char *line) {
    if(line[0] != '\"') {
        printf("ERROR: line is not quoted: %s", line);
        exit(-1);
    }

    int count = 0;
    for(int i = 1; i < strlen(line); i++) {
        if(line[i] == '\"') {
            return count;
        } else if(line[i] == '\\') {
            switch(line[i+1]) {
                case '\\':
                case '\"':
                    i += 1;
                    break;
                case 'x':
                    i += 3;
            }
        }
        count += 1;
    }

    printf("ERROR: string not terminated: %s", line);
    exit(-1);
}

int main(void) {
    char *line = NULL;
    size_t bufSize = 0;
    size_t numRead;

    int total = 0;

    while(-1 != (numRead = getline(&line, &bufSize, stdin))) {
        chop_newline(line);
        int line_len = strlen(line);
        int str_len = count_chars(line);
        int overhead = line_len - str_len;

        total += overhead;
        printf(
            "\n%s -> (%d - %d = %d) (total: %d)\n",
             line, line_len, str_len, overhead, total
        );
    }

    return 0;
}
