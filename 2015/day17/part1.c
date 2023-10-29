#include <limits.h>
#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>
#include <string.h>

size_t read_input(const char *path, int **jars)
{
    const size_t size = 256;
    char buf[size];

    // count lines
    size_t nlines = 0;
    FILE *fp = fopen(path, "r");
    while (fgets(buf, size, fp) != NULL)
    {
        nlines++;
    }

    printf("\nReading %zu lines...\n\n", nlines);
    *jars = calloc(nlines, sizeof(int));

    fseek(fp, 0, SEEK_SET);
    size_t i = 0;
    while (fgets(buf, size, fp) != NULL)
    {
        (*jars)[i] = atoi(buf);
        i++;
    }

    fclose(fp);
    return i;
}

void print_jars(size_t n, int jars[n])
{
    printf("Jars: ");
    for (size_t i = 0; i < n; i++)
    {
        if (jars[i] != 0)
        {
            printf("%d ", jars[i]);
        }
    }
    printf("\n");
}

void copy_jars(size_t n, int dest[n], int src[n])
{
    for (size_t i = 0; i < n; i++)
    {
        dest[i] = src[i];
    }
}

int sum_jars(size_t n, int jars[n])
{
    int sum = 0;
    for (size_t i = 0; i < n; i++)
    {
        sum += jars[i];
    }
    return sum;
}

int count_fits(size_t n, int jars[n], int so_far[n], size_t cursor, size_t n_chosen, int nog)
{
    if (cursor == n)
    {
        return 0;
    }
    else
    {
        int count = 0;
        int tmp[n];
        for (size_t i = cursor; i < n; i++)
        {
            copy_jars(n, tmp, so_far);
            tmp[cursor] = jars[i];
            if (sum_jars(n, tmp) == nog)
            {
                printf("found: ");
                print_jars(n, tmp);
                count += 1;
            }
            else
            {
                count += count_fits(n, jars, tmp, i + 1, n_chosen + 1, nog);
            }
        }
        return count;
    }
}

int main(int argc, char **argv)
{
    if (argc != 3)
    {
        printf("Usage: ./a.out [nog-amount] [input-file]\n");
    }

    int total_nog = atoi(argv[1]);
    int *jars;
    size_t n_jars = read_input(argv[2], &jars);

    printf("Read ");
    print_jars(n_jars, jars);

    int *so_far = calloc(n_jars, sizeof(int));
    int num_fits = count_fits(n_jars, jars, so_far, 0, 0, total_nog);

    printf("Found %d combinations\n", num_fits);

    return 0;
}
