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

int count_encoded_chars(const char *line) {
    int count = 2;
    for(int i = 0; i < strlen(line); i++) {
        switch(line[i]) {
            case '\"':
            case '\\':
                count += 1;
            default:
                count += 1;
        }
    }
    return count;
}

int main(void) {
    char *line = NULL;
    size_t bufSize = 0;
    size_t numRead;

    int total = 0;

    while(-1 != (numRead = getline(&line, &bufSize, stdin))) {
        chop_newline(line);
        int line_len = strlen(line);
        int encoded_len = count_encoded_chars(line);
        int growth = encoded_len - line_len;

        total += growth;
        printf(
            "\n%s -> (%d - %d = %d) (total: %d)\n",
             line, encoded_len, line_len, growth, total
        );
    }

    return 0;
}
