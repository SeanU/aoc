#include <limits.h>
#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>
#include <string.h>

int main(void)
{
    size_t limit = 1024 * 1024;
    char *buf = calloc(limit, sizeof(char));
    char *line = NULL;
    long sum = 0;

    while ((line = fgets(buf, limit, stdin)) != NULL)
    {
        char *endptr = NULL;
        while (line[0] != '\0')
        {
            long value = strtol(line, &endptr, 10);
            if (endptr > line)
            {
                // printf("Read %ld from %s\n", value, line);
                sum += value;
                line = endptr;
            }
            else
            {
                line += 1;
            }
        }
    }
    printf("Total: %ld\n", sum);

    return 0;
}
