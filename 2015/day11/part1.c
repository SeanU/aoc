#include <limits.h>
#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>
#include <string.h>

bool has_run(const char *pw)
{
    for (size_t i = 0; i < strlen(pw) - 2; i++)
    {
        char a = pw[i];
        char b = pw[i + 1];
        char c = pw[i + 2];
        if ((b - a) == 1 && (c - b) == 1)
        {
            return true;
        }
    }
    return false;
}

bool has_bad_letters(const char *pw)
{
    for (size_t i = 0; i < strlen(pw); i++)
    {
        switch (pw[i])
        {
        case 'i':
        case 'l':
        case 'o':
            return true;
        }
    }
    return false;
}

bool two_pair(const char *pw)
{
    int count = 0;

    for (size_t i = 0; i < strlen(pw); i++)
    {
        if (pw[i] == pw[i + 1])
        {
            count++;
            i++;
        }
    }
    return count >= 2;
}

bool allowed(const char *pw)
{
    // printf("%s", pw);

    if (!has_run(pw))
    {
        // printf(" has no run.\n");
        return false;
    }

    if (has_bad_letters(pw))
    {
        // printf(" has an i, l or o.\n");
        return false;
    }

    if (!two_pair(pw))
    {
        // printf(" does not have two pairs.\n");
        return false;
    }

    printf("%s seems ok.\n", pw);
    return true;
}

void increment(char *pw)
{
    size_t i = strlen(pw) - 1;

    for (size_t i = strlen(pw) - 1; i >= 0; i--)
    {
        pw[i] += 1;
        if (pw[i] <= 'z')
        {
            break;
        }
        else
        {
            pw[i] = 'a';
        }
    }
}

int main(int argc, char **argv)
{
    if (argc < 1)
    {
        printf("Need an argument.\n");
        exit(-1);
    }

    char *pw = calloc(strlen(argv[1]) + 1, sizeof(char));
    strcpy(pw, argv[1]);

    while (!allowed(pw))
    {
        increment(pw);
    }

    return 0;
}
