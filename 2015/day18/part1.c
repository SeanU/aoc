#include <limits.h>
#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>
#include <string.h>

void fill(size_t n, char board[n][n], char filler, char border)
{
    for (size_t y = 0; y < n; y++)
    {
        for (size_t x = 0; x < n; x++)
        {
            board[y][x] = border;
        }
    }
}

void print_board(size_t n, const char board[n][n])
{
    for (size_t y = 0; y < n; y++)
    {
        for (size_t x = 0; x < n; x++)
        {
            printf("%c", board[y][x]);
        }
        printf("\n");
    }
}

void print_iteration(int i, size_t n, char board[n][n])
{
    printf("\nIteration %d:\n", i);
    print_board(n, board);
}

void read_board(
    size_t buf_size,
    char board[buf_size][buf_size],
    size_t board_size,
    const char *path)
{
    char buf[buf_size];

    FILE *fp = fopen(path, "r");

    size_t row = 1;
    while (fgets(buf, buf_size, fp) != NULL)
    {
        memcpy(&(board[row][1]), buf, board_size);
        row++;
    }

    fclose(fp);
}

char should_light(size_t n, const char board[n][n], size_t x, size_t y)
{
    int sum = 0;
    for (size_t row = y - 1; row <= y + 1; row++)
    {
        for (size_t col = x - 1; col <= x + 1; col++)
        {
            if (board[row][col] == '#')
            {
                sum++;
            }
        }
    }

    bool should_light;
    if (board[y][x] == '#')
    {
        // is lit
        should_light = sum == 3 || sum == 4;
    }
    else
    {
        // not lit
        should_light = sum == 3;
    }

    return should_light ? '#' : '.';
}

void iterate(size_t buf_size, size_t board_size, char board[buf_size][buf_size])
{
    char next[board_size][board_size];
    for (size_t y = 0; y < board_size; y++)
    {
        for (size_t x = 0; x < board_size; x++)
        {
            next[y][x] = should_light(buf_size, board, x + 1, y + 1);
        }
    }

    for (size_t y = 0; y < board_size; y++)
    {
        for (size_t x = 0; x < board_size; x++)
        {
            board[y + 1][x + 1] = next[y][x];
        }
    }
}

int count_lit(size_t n, char board[n][n])
{
    int count = 0;
    for (size_t i = 0; i < n; i++)
    {
        for (size_t j = 0; j < n; j++)
        {
            if (board[i][j] == '#')
            {
                count += 1;
            }
        }
    }
    return count;
}

int main(int argc, char **argv)
{
    if (argc != 4)
    {
        printf("Usage: ./a.out [steps] [size] [input-file]\n");
    }

    int steps = atoi(argv[1]);
    size_t board_size = atoi(argv[2]);
    size_t padded_size = board_size + 2;
    char board[padded_size][padded_size];
    fill(padded_size, board, '.', '_');

    read_board(padded_size, board, board_size, argv[3]);

    print_iteration(0, padded_size, board);
    for (int i = 1; i <= steps; i++)
    {
        iterate(padded_size, board_size, board);
        print_iteration(i, padded_size, board);
    }

    int n_lit = count_lit(padded_size, board);
    printf("\n%d lights lit.\n", n_lit);

    return 0;
}
