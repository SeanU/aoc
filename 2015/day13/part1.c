#include <limits.h>
#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>
#include <string.h>

struct GuestList
{
    size_t number;
    char **names;
    int happiness;
};

void print_guests(struct GuestList guests)
{
    // printf("Guests:\n");
    for (size_t i = 0; i < guests.number; i++)
    {
        printf("%s, ", guests.names[i]);
    }

    printf("(%d net happy.)\n", guests.happiness);
}

void print_settings(size_t n, struct GuestList list[n])
{
    printf("Settings:\n");
    for (size_t i = 0; i < n; i++)
    {
        struct GuestList guests = list[i];

        printf("\t");
        for (int j = 0; j < guests.number; j++)
        {
            printf("%s, ", guests.names[j]);
        }
        printf("\n");
    }
}

char *name_guest(struct GuestList *guests, const char *name)
{
    for (int i = 0; i < guests->number; i++)
    {
        if (strcmp(name, guests->names[i]) == 0)
        {
            return guests->names[i];
        }
    }

    int i = guests->number;
    guests->number = i + 1;
    guests->names = realloc(guests->names, guests->number * sizeof(char *));
    // Copy to new string so we don't have to worry about whether to free input
    guests->names[i] = calloc(strlen(name) + 1, sizeof(char));
    strcpy(guests->names[i], name);
    return guests->names[i];
}

struct GuestList add_guest(struct GuestList old, char *name)
{
    struct GuestList new = {.number = old.number + 1, .happiness = old.happiness};
    new.names = calloc(new.number, sizeof(char *));

    size_t i;
    for (i = 0; i < old.number; i++)
    {
        new.names[i] = old.names[i];
    }
    new.names[i] = name;

    return new;
}

struct GuestList remove_guest(struct GuestList old, int n)
{
    struct GuestList new = {.number = old.number - 1, .happiness = old.happiness};
    new.names = calloc(new.number, sizeof(char *));

    size_t i;
    for (i = 0; i < n; i++)
    {
        new.names[i] = old.names[i];
    }
    for (i = i + 1; i < old.number; i++)
    {
        new.names[i - 1] = old.names[i];
    }

    return new;
}

struct Rule
{
    char *person;
    char *neighbor;
    int d_happy;
};

void print_rule(struct Rule rule)
{
    printf("%s - %s: %d\n", rule.person, rule.neighbor, rule.d_happy);
}

void print_rules(size_t n, const struct Rule rules[n])
{
    printf("Rules:\n");
    for (size_t i = 0; i < n; i++)
    {
        printf("\t");
        print_rule(rules[i]);
    }
    printf("\n");
}

struct Rule parse_rule(const char *buf, struct GuestList *guests)
{
    char person[16];
    char neighbor[16];
    char effect[5];
    int num;
    sscanf(buf,
           "%s would %s %d happiness units by sitting next to %s.",
           person, effect, &num, neighbor);

    if (strcmp(effect, "lose") == 0)
    {
        num *= -1;
    }

    struct Rule result = {
        .person = name_guest(guests, person),
        .neighbor = name_guest(guests, neighbor),
        .d_happy = num};

    return result;
}

void replace(char *str, char target, char replacement)
{
    while (*str != '\0')
    {
        if (*str == target)
        {
            *str = replacement;
        }
        str++;
    }
}

size_t read_input(const char *path, struct Rule **rules, struct GuestList *guests)
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

    *rules = calloc(nlines + 1, sizeof(struct Rule));

    fseek(fp, 0, SEEK_SET);
    size_t i = 0;
    while (fgets(buf, size, fp) != NULL)
    {
        replace(buf, '.', '\0');
        (*rules)[i] = parse_rule(buf, guests);
        i++;
    }

    fclose(fp);
    return i;
}

void print_lines(char **input)
{
    for (int i = 0; input[i] != NULL; i++)
    {
        printf("%s\n", input[i]);
    }
}

size_t factorial(size_t n)
{
    size_t fac = 1;
    for (size_t i = 1; i <= n; i++)
    {
        fac *= i;
    }
    return fac;
}

int score_pair(const char *a, const char *b, size_t n, struct Rule rules[n])
{
    int sum = 0;
    for (size_t i = 0; i < n; i++)
    {
        struct Rule rule = rules[i];
        if (strcmp(rule.person, a) == 0 && strcmp(rule.neighbor, b) == 0)
        {
            sum += rule.d_happy;
        }
        if (strcmp(rule.person, b) == 0 && strcmp(rule.neighbor, a) == 0)
        {
            sum += rule.d_happy;
        }
    }

    return sum;
}

struct GuestList score(
    struct GuestList list,
    size_t n_rules,
    struct Rule rules[n_rules])
{
    int sum = 0;
    for (size_t i = 0; i < list.number; i++)
    {
        sum += score_pair(
            list.names[i],
            list.names[(i + 1) % list.number],
            n_rules,
            rules);
    }
    list.happiness = sum;

    printf("Scored ");
    print_guests(list);
    return list;
}

struct GuestList find_best_setting(
    struct GuestList so_far,
    struct GuestList to_go,
    size_t n_rules,
    struct Rule rules[n_rules])
{
    if (to_go.number == 0)
    {
        return score(so_far, n_rules, rules);
    }

    struct GuestList best = {.happiness = -1000000};
    for (int i = 0; i < to_go.number; i++)
    {
        char *name = to_go.names[i];
        struct GuestList current = add_guest(so_far, name);
        struct GuestList rest = remove_guest(to_go, i);
        struct GuestList next = find_best_setting(current, rest, n_rules, rules);
        if (next.happiness >= best.happiness)
        {
            best = next;
        }
    }

    return best;
}

int main(int argc, char **argv)
{
    if (argc != 2)
    {
        printf("Usage: ./a.out [input-file]\n");
    }

    struct Rule *rules = NULL;
    struct GuestList guests = {0};
    size_t n_rules = read_input(argv[1], &rules, &guests);
    print_guests(guests);
    print_rules(n_rules, rules);

    struct GuestList seed = add_guest((struct GuestList){0}, guests.names[0]);
    struct GuestList rest = remove_guest(guests, 0);
    guests = find_best_setting(seed, rest, n_rules, rules);

    printf("\nBest setting: ");
    print_guests(guests);

    return 0;
}
