#include <limits.h>
#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>
#include <string.h>

#define START_SIZE 16;

void print_state(int i, const char *state)
{
    printf("(%d): %lu chars.\n", i, strlen(state));
}

size_t say(char *buf, size_t index, unsigned char count, char digit)
{
    buf[index] = count + '0'; // hacky conversion to text
    buf[index + 1] = digit;
    return index + 2;
}

char *iterate(const char *state)
{
    // Conway's constant is a bit more than 1.3, 1.5 gives a fudge factor.
    // hackiness with dividing and multiplying by 2 to ensure even capacity.
    size_t capacity = (size_t)(strlen(state) / 2 * 1.5) * 2;

    char *buf = calloc(capacity, sizeof(char) + 1);
    size_t ptr = 0;

    char current = state[0];
    unsigned char count = 1;
    for (int i = 1; i < strlen(state); i++)
    {
        char c = state[i];
        if (c != current)
        {
            if (ptr == capacity)
            {
                // overkill early on, hopefully appropriate when it matters
                capacity += 1000;
                buf = realloc(buf, (capacity * sizeof(char)) + 1);
            }
            ptr = say(buf, ptr, count, current);
            current = c;
            count = 1;
        }
        else
        {
            count++;
        }
    }

    if (ptr == capacity)
    {
        // only need 2 more
        capacity += 2;
        buf = realloc(buf, (capacity * sizeof(char)) + 1);
    }
    ptr = say(buf, ptr, count, current);
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
        print_state(i, current);
        free(last);
    }

    return 0;
}
