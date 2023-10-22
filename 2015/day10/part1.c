#include <limits.h>
#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>
#include <string.h>

void print_state(int i, const char *state)
{
    printf("(%d): %s\n\t(%lu chars)\n", i, state, strlen(state));
}

char *update(const char *buf, int count, char c)
{
    char *newbuf = NULL;
    int size = asprintf(&newbuf, "%s%d%c", buf, count, c);
    if (size < 0)
    {
        printf("ERROR: could not allocate new string.\n");
        exit(-1);
    }
    return newbuf;
}

char *iterate(const char *state)
{
    int n = strlen(state);
    char *buf = calloc(1, sizeof(char));

    char current = state[0];
    int count = 1;
    for (int i = 1; i < n; i++)
    {
        char c = state[i];
        if (c != current)
        {
            char *oldbuf = buf;
            buf = update(oldbuf, count, current);
            free(oldbuf);
            current = c;
            count = 1;
        }
        else
        {
            count++;
        }
    }

    char *oldbuf = buf;
    buf = update(oldbuf, count, current);
    free(oldbuf);
    return buf;
}

int main(int argc, char **argv)
{
    if (argc < 3)
    {
        printf("Need two arguments.\n");
        exit(-1);
    }

    char *state = argv[1];
    int n = atoi(argv[2]);
    char *current = calloc(strlen(state) + 1, sizeof(char));
    strcpy(current, state);

    print_state(0, current);
    for (int i = 1; i <= n; i++)
    {
        char *last = current;
        current = iterate(last);
        printf("\n");
        print_state(i, current);
        free(last);
    }

    return 0;
}
