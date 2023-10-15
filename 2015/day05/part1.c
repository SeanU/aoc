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

bool threeVowels(const char* str) {
    int nvowels = 0;
    for(int i = 0; i < strlen(str) && nvowels < 3; i++) {
        switch(str[i]) {
            case 'a':
            case 'e':
            case 'i':
            case 'o':
            case 'u':
                nvowels += 1;
                break;
            default:
                break;
        }
    }

bool threeVowels = nvowels >= 3;
    // printf("\tthree vowels: %d\n", threeVowels);

    return threeVowels;
}

bool doubleLetter(const char* str) {
    char prev = '\0';
    bool hasdouble = false;

    for(int i = 0; i < strlen(str); i++) {
        char cur = str[i];
        hasdouble = hasdouble || (prev == cur);
        prev = cur;
    }

    // printf("\tno double letter.\n");
    return hasdouble;
}

bool noBadWords(const char* str) {
    char prev = '\0';
    bool badWord = false;

    for(int i = 0; i < strlen(str); i++) {
        char cur = str[i];
        badWord = badWord || (
            (prev == 'a' && cur == 'b')
            || (prev == 'c' && cur == 'd')
            || (prev == 'p' && cur == 'q')
            || (prev == 'x' && cur == 'y')
        );
        prev = cur;
    }

    return !badWord;
}

bool isNice(const char* str) {
    bool tv = threeVowels(str);
    bool dl = doubleLetter(str);
    bool nbw = noBadWords(str);
    bool nice = tv && dl && nbw;
    
    printf(
        "%s is nice: %d (tv: %d, dl: %d, nbw: %d)\n", 
        str, nice, tv, dl, nbw
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

    printf("%d strings were nice.\n", nnice);

    return 0;
}
