#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>
#include <string.h>

enum Operation {
    AND,
    LITERAL,
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
        case LITERAL:
            return "LIT";
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

struct Wiring {
    enum Operation op;
    char *a;
    char *b;
    unsigned short bits;
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
        case LITERAL:
            printf("LITERAL %s (%d)\n", w.out, w.value);
            break;
        case NOT:
            printf("NOT %s -> %s (%d)\n", w.a, w.out, w.value);
            break;
        case AND:
        case OR:
            printf("%s %s %s -> %s (%d)\n", w.a, strop(w.op), w.b, w.out, w.value);
            break;
        case LSHIFT:
        case RSHIFT:
            printf("%s %s %d -> %s (%d)\n", w.a, strop(w.op), w.bits, w.out, w.value);
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

struct Wiring parse_wiring(char* line) {
    struct Wiring wiring = { 0 };
    char* tokens[5] = {0};
    int ntokens = tokenize(line, tokens);

    // printf("found %d tokens\n", ntokens);

    switch (ntokens) {
        case 3:
            wiring.op = LITERAL;
            wiring.out = tokens[2];
            wiring.has_value = true;
            wiring.value = atoi(tokens[0]);
            // printf("\tWiring {LIT %d -> %s}\n", wiring.value, wiring.out);
            break;

        case 4:
            wiring.op = NOT;
            wiring.a = tokens[1];
            wiring.out = tokens[3];
            // printf("\tWiring {NOT %s -> %s}\n", wiring.a, wiring.out);
            break;
        
        case 5:
            wiring.op = to_op(tokens[1]);
            wiring.a = tokens[0];
            if(wiring.op == AND || wiring.op == OR) {
                wiring.b = tokens[2];
            } else {
                wiring.bits = atoi(tokens[2]);
            }
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

bool not_done(struct Diagram diagram) {
    for(int i = 0; i < diagram.count; i++) {
        if(!(diagram.nodes[i].has_value)) {
            return true;
        }
    }
    return false;
}

bool try_and(struct Wiring a, struct Wiring b, unsigned short *value) {
    if(a.has_value && b.has_value) {
        *value = a.value & b.value;
        // printf("\t\t%d & %d = %d\n", a.value, b.value, *value);
        return true;
    } else {
        return false;
    }
}

bool try_lshift(struct Wiring a, unsigned int bits, unsigned short *value) {
    if(a.has_value) {
        *value = a.value << bits;
        // printf("\t\t%d << %d = %d\n", a.value, bits, *value);
        return true;
    } else {
        return false;
    }
}

bool try_not(struct Wiring a, unsigned short *value) {
    if(a.has_value) {
        *value = ~a.value;
        // printf("\t\t~%d = %d\n", a.value, *value);
        return true;
    } else {
        return false;
    }
}

bool try_or(struct Wiring a, struct Wiring b, unsigned short *value) {
    if(a.has_value && b.has_value) {
        *value = a.value | b.value;
        // printf("\t\t%d | %d = %d\n", a.value, b.value, *value);
        return true;
    } else {
        return false;
    }
}

bool try_rshift(struct Wiring a, unsigned short bits, unsigned short *value) {
    if(a.has_value) {
        *value = a.value >> bits;
        // printf("\t\t%d << %d = %d\n", a.value, bits, *value);
        return true;
    } else {
        return false;
    }
}

struct Wiring get_node(const struct Diagram *diagram, const char *id) {
    if(id != NULL) {
        for(int i = 0; i < diagram->count; i++) {
            if (strcmp(id, diagram->nodes[i].out) == 0) {
                return diagram->nodes[i];
            }
        }

        printf("ERROR: failed to find wiring %s\n", id);
    }

    struct Wiring oops = { 0 }; 
    return oops;
}

void try_evaluate(struct Wiring *node, struct Diagram *diagram) {
    // printf("\tevaluating ");
    // print_node(*node);
    struct Wiring a = get_node(diagram, node->a);
    struct Wiring b = get_node(diagram, node->b);


    switch (node->op) {
        case AND:
            node->has_value = try_and(a, b, &(node->value));
            break;
        case LITERAL:
            printf("ERROR: attempt to evaluate literal %s\n", node->out);
            break;
        case LSHIFT:
            node->has_value = try_lshift(a, node->bits, &(node->value));
            break;
        case NOT:
            node->has_value = try_not(a, &(node->value));
            break;
        case OR:
            node->has_value = try_or(a, b, &(node->value));
            break;
        case RSHIFT:
            node->has_value = try_rshift(a, node->bits, &(node->value));
    }

    if(node->has_value && (strcmp(node->out, "a") == 0)) {
        print_node(*node);
    }
}

void evaluate(struct Diagram *diagram) {
    for(int i = 0; i < diagram->count; i++) {
        struct Wiring *node = &(diagram->nodes[i]);
        if(!(node->has_value)) {
            try_evaluate(node, diagram);
        }
    }
}

int main(void) {
    char *line = NULL;
    size_t bufSize = 0;
    size_t numRead;

    struct Diagram diagram;
    diagram.count = 0;
    diagram.capacity = 100;
    diagram.nodes = calloc(100, sizeof(struct Wiring));

    struct Wiring literally_one;
    literally_one.op = LITERAL;
    literally_one.out = "1";
    literally_one.has_value = true;
    literally_one.value = 1;
    add_wiring(&diagram, literally_one);

    while(-1 != (numRead = getline(&line, &bufSize, stdin))) {
        kill_newine(line);
        // printf("\n%s\n", line);
        add_wiring(&diagram, parse_wiring(strdup(line)));
    }

    // printf("\nread:\n");
    // print_nodes(diagram);

    printf("\nevaluating...\n");
    while(not_done(diagram)) {
        evaluate(&diagram);
    }

    return 0;
}
