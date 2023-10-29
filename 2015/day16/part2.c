#include <limits.h>
#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>
#include <string.h>

const int n_things = 10;

typedef enum Thing
{
    CHILDREN = 0,
    CATS,
    SAMOYEDS,
    POMERANIANS,
    AKITAS,
    VIZSLAS,
    GOLDFISH,
    TREES,
    CARS,
    PERFUMES
} Thing;

char *things[n_things] = {
    "children",
    "cats",
    "samoyeds",
    "pomeranians",
    "akitas",
    "vizslas",
    "goldfish",
    "trees",
    "cars",
    "perfumes",
};

Thing to_thing(const char *s)
{
    for (int i = 0; i < n_things; i++)
    {
        if (strcmp(things[i], s) == 0)
        {
            return (Thing)i;
        }
    }
    printf("ERROR: unrecognized thing: %s\n", s);
    exit(-1);
}

typedef struct Clue
{
    int things[10];
} Clue;

void print_clue(Clue c)
{
    printf("Clue:\n");
    for (size_t i = 0; i < n_things; i++)
    {
        printf("\t%s: %d\n", things[i], c.things[i]);
    }
}

Clue new_clue()
{
    return (Clue){
        .things = {-1,
                   -1,
                   -1,
                   -1,
                   -1,
                   -1,
                   -1,
                   -1,
                   -1,
                   -1}};
}

Clue load_clue()
{
    Clue clue = new_clue();

    const size_t size = 256;
    char buf[size];
    char thing[16] = {0};
    uint16_t count;

    FILE *fp = fopen("clue.txt", "r");
    while (fgets(buf, size, fp) != NULL)
    {
        sscanf(buf, "%15[^:]: %hu", thing, &count);
        clue.things[to_thing(thing)] = count;
    }

    fclose(fp);
    printf("Read clue: ");
    print_clue(clue);
    return clue;
}

typedef struct Sue
{
    int number;
    Clue clue;
} Sue;

void print_sue(Sue sue)
{
    printf("Sue #%d: ", sue.number);
    for (size_t i = 0; i < n_things; i++)
    {
        if (sue.clue.things[i] >= 0)
        {
            printf("%s: %d, ", things[i], sue.clue.things[i]);
        }
    }
    printf("\n");
}

Sue read_sue(const char *buf)
{
    Sue sue = {0};
    sue.clue = new_clue();
    char thing1[16];
    int count1;
    char thing2[16];
    int count2;
    char thing3[16];
    int count3;

    sscanf(
        buf, "Sue %d: %15[^:]: %d, %15[^:]: %d, %15[^:]: %d",
        &(sue.number), thing1, &count1, thing2, &count2, thing3, &count3);

    sue.clue.things[to_thing(thing1)] = count1;
    sue.clue.things[to_thing(thing2)] = count2;
    sue.clue.things[to_thing(thing3)] = count3;

    return sue;
}

bool could_be(Sue sue, Clue clue)
{
    int *s = sue.clue.things;
    int *c = clue.things;

    for (size_t i = 0; i < n_things; i++)
    {
        char *cur_thing = things[i];
        switch (i)
        {
        case CATS:
        case TREES:
            if (s[i] >= 0 && s[i] <= c[i])
            {
                return false;
            }
            break;
        case POMERANIANS:
        case GOLDFISH:
            if (s[i] >= 0 && s[i] >= c[i])
            {
                return false;
            }
            break;
        default:
            if (s[i] >= 0 && s[i] != c[i])
            {
                return false;
            }
        }
    }
    return true;
}

Sue deduce_sue(Clue clue)
{
    const size_t size = 256;
    char buf[size];

    Sue the_sue;

    FILE *fp = fopen("aunts.txt", "r");
    while (fgets(buf, size, fp) != NULL)
    {
        Sue sue = read_sue(buf);
        // printf("Read: ");
        // print_sue(sue);
        if (could_be(sue, clue))
        {
            printf("Could be ");
            print_sue(sue);
            the_sue = sue;
        }
    }

    fclose(fp);
    return the_sue;
}

int main(void)
{
    printf("\n");
    Clue clue = load_clue();

    Sue sue = deduce_sue(clue);

    printf("The gift came from ");
    print_sue(sue);

    return 0;
}
