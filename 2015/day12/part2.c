#include <limits.h>
#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>
#include <string.h>
#include "json.h"

bool is_red(struct json_value_s *value)
{
    if (value->type != json_type_string)
    {
        return false;
    }
    else
    {
        struct json_string_s *str = json_value_as_string(value);
        return strcmp("red", str->string) == 0;
    }
}

long walk_and_sum(struct json_value_s *json)
{
    if (json->type == json_type_array)
    {
        // printf("reading array\n");
        struct json_array_s *array = json_value_as_array(json);
        struct json_array_element_s *item;
        long sum = 0;
        for (item = array->start; item != NULL; item = item->next)
        {
            sum += walk_and_sum(item->value);
        }
        return sum;
    }
    else if (json->type == json_type_object)
    {
        // printf("reading object\n");
        struct json_object_s *obj = json_value_as_object(json);
        struct json_object_element_s *item;
        long sum = 0;
        for (item = obj->start; item != NULL; item = item->next)
        {
            if (is_red(item->value))
            {
                return 0;
            }
            else
            {
                sum += walk_and_sum(item->value);
            }
        }
        return sum;
    }
    else if (json->type == json_type_number)
    {
        // printf("readig number\n");
        return atoi(json_value_as_number(json)->number);
    }
    else
    {
        return 0;
    }
}

long sum_json(const char *line)
{
    struct json_value_s *json = json_parse(line, strlen(line));
    return walk_and_sum(json);
}

int main(void)
{
    size_t limit = 1024 * 1024 * 1024;
    char *buf = calloc(limit, sizeof(char));
    const char *line = NULL;
    long sum = 0;

    while ((line = fgets(buf, limit, stdin)) != NULL)
    {
        sum += sum_json(line);
    }
    printf("Total: %ld\n", sum);

    return 0;
}
