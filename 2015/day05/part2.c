#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>
#include <string.h>

void chopNewline(char* str) {
    for(int i = 0; i < strlen(str); i++) {
        if(str[i] == '\n') {
            str[i] = '\0';
        }
    }
}

bool secondPair(const char *needle, const char *haystack) {
    // printf("\tneedle: %c%c\n", needle[0], needle[1]);

    while(strlen(haystack) >= 2) {
        // printf("\t\thaystack: %s\n", haystack);
        if(strncmp(needle, haystack, 2) == 0) {
            return true;
        } else {
            haystack = haystack + 1;
        }
    }
    return false;
}

bool twoPairs(const char* str) {
    const char *needle = str;
    const char *haystack = str;
    while(strlen(needle) >= 4) {
        haystack = needle + 2;
        if(secondPair(needle, haystack)) {
            return true;
        }
        needle += 1;
    }
    return false;
}

bool splitPair(const char* str) {
    for(int i = 0; i < strlen(str) - 2; i++) {
        if(str[i] == str[i + 2]) {
            return true;
        }
    }
    return false;
}

bool isNice(const char* str) {
    bool tp = twoPairs(str);
    bool sp = splitPair(str);
    bool nice = tp && sp;
    
    printf(
        "%s is nice: %d (tp: %d, sp: %d)\n", 
        str, nice, tp, sp
    );
    return nice;
}

int main(void) {
    char *line = NULL;
    size_t bufSize = 0;
    size_t numRead;

    int nnice = 0;

    while(-1 != (numRead = getline(&line, &bufSize, stdin))) {
        chopNewline(line);
        // printf("read %zu bytes: %s \n", numRead, line);

        if(isNice(line)) {
            nnice += 1;
        }

        free(line);
        line = NULL;
        bufSize = 0;
    }

    printf("\n%d strings were nice.\n", nnice);

    return 0;
}
