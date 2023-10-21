#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>
#include <string.h>

enum Operation {
    AND,
    ASSIGN,
    LSHIFT,
    NOT,
    OR,
    RSHIFT,
};

enum Operation to_op(const char* op) {
    if (strcmp(op, "AND") == 0) {
        return AND;
    } else if (strcmp(op, "LSHIFT") == 0) {
        return LSHIFT;
    } else if (strcmp(op, "OR") == 0) {
        return OR;
    } else if (strcmp(op, "RSHIFT") == 0) {
        return RSHIFT;
    } else {
        return 0;
    }
}

char* strop(enum Operation op) {
    switch(op) {
        case AND:
            return "AND";
        case ASSIGN:
            return "LET";
        case LSHIFT:
            return "LSHIFT";
        case NOT:
            return "NOT";
        case OR:
            return "OR";
        case RSHIFT:
            return "RSHIFT";
    } 
}

struct Value {
    char *wire;
    unsigned short value;
    char *repr;
};

bool is_literal(struct Value value) {
    return value.wire == NULL;
}

struct Wiring {
    enum Operation op;
    struct Value a;
    struct Value b;
    char *out;
    bool has_value;
    unsigned short value;
};

struct Diagram {
    int count;
    int capacity;
    struct Wiring *nodes;
};

void print_node(struct Wiring w) {
    switch(w.op) {
        case ASSIGN:
            printf("ASSIGN %s -> %s (%d)\n", w.a.repr, w.out, w.value);
            break;
        case NOT:
            printf("NOT %s -> %s (%d)\n", w.a.repr, w.out, w.value);
            break;
        case AND:
        case OR:
        case LSHIFT:
        case RSHIFT:
            printf(
                "%s %s %s -> %s (%d)\n", 
                w.a.repr, strop(w.op), w.b.repr, w.out, w.value
            );
    } 
}

void print_nodes(struct Diagram diagram) {
    for(int i = 0; i < diagram.count; i++) {
        printf("\t");
        print_node(diagram.nodes[i]);
    }
}

int tokenize(char* line, char* tokens[5]) {
    int ntokens = 0;

    for(char* tok = strtok(line, " "); tok != NULL; tok = strtok(NULL, " ")) {
        tokens[ntokens] = tok;
        ntokens += 1;
    }

    return ntokens;
}

struct Value parse_value(char* str) {
    struct Value value = { 0 };
    char *end = NULL;
    value.repr = str;
    value.value = (int) strtol(str, &end, 10);
    if(str == end) {
        // not an int; value remains 0 and plug in wire name
        value.wire = str;
    } 
    return value;
}

struct Wiring parse_wiring(char* line) {
    struct Wiring wiring = { 0 };
    char* tokens[5] = {0};
    int ntokens = tokenize(line, tokens);

    // printf("found %d tokens\n", ntokens);

    switch (ntokens) {
        case 3:
            wiring.op = ASSIGN;
            wiring.out = tokens[2];
            wiring.a = parse_value(tokens[0]);
            if(is_literal(wiring.a)) {
                wiring.has_value = true;
                wiring.value = wiring.a.value;
            }
            // printf("\tWiring {LIT %d -> %s}\n", wiring.value, wiring.out);
            break;

        case 4:
            wiring.op = NOT;
            wiring.a = parse_value(tokens[1]);
            wiring.out = tokens[3];
            // printf("\tWiring {NOT %s -> %s}\n", wiring.a, wiring.out);
            break;
        
        case 5:
            wiring.op = to_op(tokens[1]);
            wiring.a = parse_value(tokens[0]);
            wiring.b = parse_value(tokens[2]);
            wiring.out = tokens[4];
            // printf("\tWiring ");
            // print_node(wiring);
    }

    return wiring;
}

void add_wiring(struct Diagram *diagram, struct Wiring wiring) {
    if(diagram->count == diagram->capacity) {
        diagram->capacity += 100;
        printf(
            "\t(expanding diagram capacity to %d)\n", 
            diagram->capacity
        );
        diagram->nodes = 
            realloc(
                diagram->nodes, 
                diagram->capacity * sizeof(struct Wiring)
            );
    }

    diagram->nodes[diagram->count] = wiring;
    diagram->count += 1;
    // printf("\t(%d nodes)\n", diagram->count);
}

void kill_newine(char *str) {
    for(int i = 0; i < strlen(str); i++) {
        if (str[i] == '\n') {
            str[i] = '\0';
        }
    }
}

struct Wiring *get_node(const struct Diagram *diagram, const char *id) {
    if(id != NULL) {
        for(int i = 0; i < diagram->count; i++) {
            if (strcmp(id, diagram->nodes[i].out) == 0) {
                return &(diagram->nodes[i]);
            }
        }

        printf("ERROR: failed to find wiring %s\n", id);
    }

    return NULL;
}

unsigned short execute(enum Operation op, unsigned short a, unsigned short b) {
    switch (op) {
        case AND:
            return a & b;
        case ASSIGN:
            return a;
        case LSHIFT:
            return a << b;
        case NOT:
            return ~a;
        case OR:
            return a | b;
        case RSHIFT:
            return a >> b;
    }
}

unsigned short evaluate(struct Wiring *node, struct Diagram *diagram);
unsigned short get_value(struct Value val, struct Diagram *diagram) {
    if(val.wire == NULL) {
        return val.value;
    } else {
        return evaluate(get_node(diagram, val.wire), diagram);
    }
}

unsigned short evaluate(struct Wiring *node, struct Diagram *diagram) {
    if(node == NULL) {
        printf("ERROR: node is null, returning 0\n");
        return 0;
    }
    if(!(node->has_value)) {
        unsigned short a = get_value(node->a, diagram);
        unsigned short b = get_value(node->b, diagram);
        node->value = execute(node->op, a, b);
        node->has_value = true;
        print_node(*node);
    }
    return node->value;
}

int main(void) {
    char *line = NULL;
    size_t bufSize = 0;
    size_t numRead;

    struct Diagram diagram;
    diagram.count = 0;
    diagram.capacity = 100;
    diagram.nodes = calloc(100, sizeof(struct Wiring));

    while(-1 != (numRead = getline(&line, &bufSize, stdin))) {
        kill_newine(line);
        // printf("\n%s\n", line);
        add_wiring(&diagram, parse_wiring(strdup(line)));
    }

    struct Wiring *b = get_node(&diagram, "b");
    b->a.value = 956;
    b->a.repr = "956";
    b->value = 956;
    print_node(*b);

    printf("\nread:\n");
    print_nodes(diagram);

    printf("\nevaluating...\n");
    char* target = "a";
    unsigned short target_value = evaluate(get_node(&diagram, target), &diagram);
    printf("%s's value is %d\n", target, target_value);

    return 0;
}
