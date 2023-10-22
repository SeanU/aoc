#include <limits.h>
#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>
#include <string.h>

#define PAGE 10

void chop_newline(char *line)
{
    for (int i = 0; i < strlen(line); i++)
    {
        if (line[i] == '\n')
        {
            line[i] = '\0';
        }
    }
}

struct CityList
{
    int count;
    int capacity;
    char **cities;
};

bool list_contains(int n, char *cities[n], const char *name)
{
    for (int i = 0; i < n; i++)
    {
        if (strcmp(cities[i], name) == 0)
        {
            return true;
        }
    }
    return false;
}

void add_city(struct CityList *cities, char *name)
{
    if (list_contains(cities->count, cities->cities, name))
    {
        return;
    }
    // printf("\t(adding %s to city list)\n", name);

    if (cities->count == cities->capacity)
    {
        cities->cities = realloc(
            cities->cities,
            (cities->capacity + PAGE) * sizeof(char **));
        cities->capacity += PAGE;
        // printf("\t(expanded city list capacity to %d)\n", cities->capacity);
    }

    int index;
    for (index = 0; index < cities->count; index++)
    {
        if (strcmp(cities->cities[index], name) > 0)
        {
            break;
        }
    }
    // make room
    for (int j = cities->count; j >= index; j--)
    {
        cities->cities[j + 1] = cities->cities[j];
    }

    cities->cities[index] = name;
    cities->count += 1;

    // printf("\tnew city list:\n");
    // for(int i = 0; i < cities->count; i++) {
    //     printf("\t\t%s\n", cities->cities[i]);
    // }
}

struct CityList clone(struct CityList cities)
{
    struct CityList c = cities;
    c.cities = calloc(c.count, sizeof(char *));
    memcpy(c.cities, cities.cities, cities.count * sizeof(char *));
    return c;
}

struct Distance
{
    char *a;
    char *b;
    int miles;
};

void print_distance(struct Distance d)
{
    printf("%s to %s: %d\n", d.a, d.b, d.miles);
}

struct Distance parse_distance(const char *line)
{
    struct Distance d = {0};
    char a[16];
    char b[16];
    sscanf(line, "%15s to %15s = %d", a, b, &(d.miles));
    d.a = malloc(strlen(a) + 1);
    d.b = malloc(strlen(b) + 1);
    // alphabetize
    if (strcmp(a, b) < 0)
    {
        strcpy(d.a, a);
        strcpy(d.b, b);
    }
    else
    {
        strcpy(d.a, b);
        strcpy(d.b, a);
    }
    return d;
}

struct Map
{
    int count;
    int capacity;
    struct Distance *distances;
};

void add_distance(struct Map *map, struct Distance distance)
{
    if (map->count == map->capacity)
    {
        map->distances = realloc(
            map->distances,
            (map->capacity + PAGE) * sizeof(struct Distance));
        map->capacity += PAGE;
    }

    map->distances[map->count] = distance;
    map->count += 1;
}

int distance_from(struct Map map, char *here, char *there)
{
    if (strcmp(here, there) > 0)
    {
        return distance_from(map, there, here);
    }
    else
    {
        for (int i = 0; i < map.count; i++)
        {
            if ((strcmp(map.distances[i].a, here) == 0) && (strcmp(map.distances[i].b, there) == 0))
            {
                return map.distances[i].miles;
            }
        }
    }
    printf("ERROR: Distance from %s to %s no found\n", here, there);
    return INT_MAX;
}

int shortest_route_from(struct CityList cities, struct Map map, char *here)
{
    // printf("visiting %s with remaining cities:\n", here);

    int shortest = INT_MAX;

    for (int i = 0; i < cities.count; i++)
    {
        char *there = cities.cities[i];
        // printf("\t%s: ", there);
        if (there != NULL)
        {
            int dist = distance_from(map, here, there);

            struct CityList rest = clone(cities);
            rest.cities[i] = NULL;
            dist += shortest_route_from(rest, map, there);
            // printf("%d\n", dist);
            if (dist < shortest)
            {
                // printf("\t%s to %s is new shortest (%d)\n", here, there, dist);
                shortest = dist;
            }
        }
        else
        {
            // printf("\n");
        }
    }

    if (shortest == INT_MAX)
    {
        return 0;
    }
    else
    {
        return shortest;
    }
}

int shortest_route(struct CityList cities, struct Map map)
{
    int shortest = INT_MAX;

    for (int i = 0; i < cities.count; i++)
    {
        char *here = cities.cities[i];
        struct CityList rest = clone(cities);
        rest.cities[i] = NULL;
        int dist = shortest_route_from(rest, map, here);
        if (dist < shortest)
        {
            shortest = dist;
        }
    }

    return shortest;
}

int main(void)
{
    char *line = NULL;
    size_t bufSize = 0;
    size_t numRead;

    struct CityList cities = {0};
    struct Map map = {0};

    while (-1 != (numRead = getline(&line, &bufSize, stdin)))
    {
        chop_newline(line);
        struct Distance d = parse_distance(line);
        // printf("Loaded ");
        // print_distance(d);

        add_city(&cities, d.a);
        add_city(&cities, d.b);
        add_distance(&map, d);
    }

    // for(int i = 0; i < map.count; i++) {
    //     print_distance(map.distances[i]);
    // }
    int shortest = shortest_route(cities, map);
    printf("Shortest route length: %d\n", shortest);

    return 0;
}
