#include <limits.h>
#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>
#include <string.h>

struct Ingredient
{
    char *name;
    int capacity;
    int durability;
    int flavor;
    int texture;
    int calories;
};

void print_ingredient(struct Ingredient i)
{
    printf(
        "%s: cap %i, dur %i, flav %i, tex %i, cal %i\n",
        i.name, i.capacity, i.durability, i.flavor, i.texture, i.calories);
}

void print_ingredients(size_t n, struct Ingredient ingredients[n])
{
    printf("Ingredients:\n");
    for (size_t i = 0; i < n; i++)
    {
        printf("\t");
        print_ingredient(ingredients[i]);
    }
    printf("\n");
}

struct Ingredient parse_ingredient(const char *buf)
{
    struct Ingredient i = {0};
    i.name = calloc(16, sizeof(char));
    sscanf(
        buf, "%15[^:]: capacity %d, durability %d, flavor %d, texture %d, calories %d",
        i.name, &(i.capacity), &(i.durability), &(i.flavor), &(i.texture), &(i.calories));

    return i;
}

int score_cookie(size_t n, struct Ingredient ingredients[n], int recipe[n])
{
    int cap = 0;
    int dur = 0;
    int flav = 0;
    int tex = 0;
    int cal = 0;

    for (size_t i = 0; i < n; i++)
    {
        cap += ingredients[i].capacity * recipe[i];
        dur += ingredients[i].durability * recipe[i];
        flav += ingredients[i].flavor * recipe[i];
        tex += ingredients[i].texture * recipe[i];
        cal += ingredients[i].calories * recipe[i];
    }
    cap = cap > 0 ? cap : 0;
    dur = dur > 0 ? dur : 0;
    flav = flav > 0 ? flav : 0;
    tex = tex > 0 ? tex : 0;
    cal = cal > 0 ? cal : 0;

    return cap * dur * flav * tex;
}

void print_cookie(size_t n, struct Ingredient ingredients[n], int amounts[n])
{
    int score = score_cookie(n, ingredients, amounts);
    printf("Score: %d - ", score);
    for (size_t i = 0; i < n; i++)
    {
        if (i > 0)
        {
            printf(", ");
        }
        printf("%d %s", amounts[i], ingredients[i].name);
    }
    printf("\n");
}

size_t read_input(const char *path, struct Ingredient **ingredients)
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
    *ingredients = calloc(nlines + 1, sizeof(struct Ingredient));

    fseek(fp, 0, SEEK_SET);
    size_t i = 0;
    while (fgets(buf, size, fp) != NULL)
    {
        (*ingredients)[i] = parse_ingredient(buf);
        i++;
    }

    fclose(fp);
    return i;
}

int count_teaspoons(size_t n, int recipe[n])
{
    int x = 0;
    for (size_t i = 0; i < n; i++)
    {
        x += recipe[i];
    }

    return x;
}

void clone(size_t n, int dest[n], int source[n])
{
    for (size_t i = 0; i < n; i++)
    {
        dest[i] = source[i];
    }
}

void blank_rest(size_t n, int sample[n], size_t from)
{
    for (; from < n; from++)
    {
        sample[from] = 0;
    }
}

int find_best(
    size_t n,
    struct Ingredient ingredients[n],
    size_t cur_ingredient,
    int recipe[n])
{
    int remaining = 100 - count_teaspoons(n, recipe);
    recipe[cur_ingredient] = remaining;
    int best_score = score_cookie(n, ingredients, recipe);

    if (cur_ingredient == n - 1)
    {
        return best_score;
    }
    else
    {
        int sample[n];
        clone(n, sample, recipe);

        while (sample[cur_ingredient] > 0)
        {
            sample[cur_ingredient] -= 1;
            blank_rest(n, sample, cur_ingredient + 1);
            int sample_score = find_best(n, ingredients, cur_ingredient + 1, sample);

            if (sample_score > best_score)
            {
                clone(n, recipe, sample);
                best_score = sample_score;
            }
        }
    }
    return best_score;
}

int *find_best_cookie(size_t n, struct Ingredient ingredients[n])
{
    int *recipe = calloc(n, sizeof(int));
    find_best(n, ingredients, 0, recipe);
    return recipe;
}

int main(int argc, char **argv)
{
    if (argc != 2)
    {
        printf("Usage: ./a.out [input-file]\n");
    }

    struct Ingredient *ingredients = NULL;
    size_t n = read_input(argv[1], &ingredients);
    print_ingredients(n, ingredients);

    int *cookie = find_best_cookie(n, ingredients);
    print_cookie(n, ingredients, cookie);

    return 0;
}
