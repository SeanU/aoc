// Compile with -lcrypto
#include <stdbool.h>
#include <stdio.h>
#include <string.h>

// suppress MD5 deprecation warning
#define OPENSSL_API_COMPAT 0x10100000L
#include <openssl/md5.h>

#define LENGTH 80

void replace(char *str, char target, char replacement) {
    for(int i = 0; i < strlen(str); i++) {
        if(str[i] == target) {
            str[i] = replacement;
        }
    }
}

bool isMatch(const unsigned char* hash) {
    // hex wonkiness here
    return hash[0] == 0x00 && hash[1] == 0x00 && hash[2] >> 4 == 0x00;
}

void printhash(const unsigned char* hash) {
    printf("checking ");
    for(int i = 0; i < MD5_DIGEST_LENGTH; i++) {
        printf("%02x", hash[i]);
    }
    printf("\n");
}

int main(void) {
    char *secret = NULL;
    size_t secretLength;
    getline(&secret, &secretLength, stdin);
    replace(secret, '\n', '\0');
    char key[LENGTH];
    unsigned char hash[MD5_DIGEST_LENGTH];

    for(int i = 1;; i++) {
        int keyLength = sprintf(key, "%s%d", secret, i);
        // printf("checking \"%s\".\n", key);

        MD5((unsigned char *)key, keyLength, hash);
        printf("%d ", i);
        printhash(hash);
        if(isMatch(hash)) {
            printf("Answer is %d\n", i);
            break;
        }
    }

    return 0;
}
