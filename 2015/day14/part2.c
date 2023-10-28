#include <limits.h>
#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>
#include <string.h>

struct Deer
{
    char *name;
    int speed;
    int endurance;
    int recovery;
};

void print_deer(struct Deer deer)
{
    printf(
        "%s (%dkm/s for %ds, rest %d)\n",
        deer.name, deer.speed, deer.endurance, deer.recovery);
}

void print_herd(size_t n, struct Deer herd[n])
{
    printf("Herd:\n");
    for (size_t i = 0; i < n; i++)
    {
        printf("\t");
        print_deer(herd[i]);
    }
    printf("\n");
}

struct Deer parse_deer(const char *buf)
{
    struct Deer deer = {0};
    deer.name = calloc(16, sizeof(char));

    sscanf(buf,
           "%s can fly %d km/s for %d seconds, but then must rest for %d seconds.",
           deer.name, &(deer.speed), &(deer.endurance), &(deer.recovery));

    return deer;
}

enum Activity
{
    FLY,
    REST
};

struct Racer
{
    struct Deer deer;
    int distance_flown;
    enum Activity doing;
    int countdown;
    int points;
};

void print_racer(struct Racer racer)
{
    printf(
        "%s (%dkm/s for %ds, rest %d): flown %dkm, %sing %ds, %d points\n",
        racer.deer.name, racer.deer.speed, racer.deer.endurance, racer.deer.recovery,
        racer.distance_flown, racer.doing == FLY ? "fly" : "rest", racer.countdown, racer.points);
}

void print_racers(size_t n, struct Racer racers[n])
{
    printf("Race:\n");
    for (size_t i = 0; i < n; i++)
    {
        printf("\t");
        print_racer(racers[i]);
    }
    printf("\n");
}

struct Racer racer_for_deer(struct Deer deer)
{
    return (struct Racer){
        .deer = deer,
        .doing = FLY,
        .countdown = deer.endurance};
}

struct Racer *racers_for_deer(size_t n, struct Deer herd[n])
{
    struct Racer *racers = calloc(n, sizeof(struct Racer));

    for (size_t i = 0; i < n; i++)
    {
        racers[i] = racer_for_deer(herd[i]);
    }

    return racers;
}

size_t read_input(const char *path, struct Deer **herd)
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
    *herd = calloc(nlines + 1, sizeof(struct Deer));

    fseek(fp, 0, SEEK_SET);
    size_t i = 0;
    while (fgets(buf, size, fp) != NULL)
    {
        (*herd)[i] = parse_deer(buf);
        i++;
    }

    fclose(fp);
    return i;
}

void update_racer(struct Racer *deer)
{
    if (deer->doing == FLY)
    {
        deer->distance_flown += deer->deer.speed;
        deer->countdown -= 1;
        if (deer->countdown == 0)
        {
            deer->doing = REST;
            deer->countdown = deer->deer.recovery;
        }
    }
    else
    {
        deer->countdown -= 1;
        if (deer->countdown == 0)
        {
            deer->doing = FLY;
            deer->countdown = deer->deer.endurance;
        }
    }
}

void update_race(size_t n, struct Racer race[n])
{
    int farthest = 0;
    for (size_t i = 0; i < n; i++)
    {
        update_racer(&(race[i]));
        if (race[i].distance_flown > farthest)
        {
            farthest = race[i].distance_flown;
        }
    }

    for (size_t i = 0; i < n; i++)
    {
        if (race[i].distance_flown == farthest)
        {
            race[i].points += 1;
        }
    }
}

int main(int argc, char **argv)
{
    if (argc != 2)
    {
        printf("Usage: ./a.out [input-file]\n");
    }

    struct Deer *herd = NULL;
    size_t n_deer = read_input(argv[1], &herd);
    print_herd(n_deer, herd);

    struct Racer *racers = racers_for_deer(n_deer, herd);

    for (int i = 0; i <= 2503; i++)
    {
        printf("State at %d seconds:\n", i);
        print_racers(n_deer, racers);
        update_race(n_deer, racers);
    }

    return 0;
}
