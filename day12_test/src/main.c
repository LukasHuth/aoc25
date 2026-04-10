#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static char *read_input(long *out_size) {
    FILE *f = fopen("input.txt", "r");
    if (!f) {
        fprintf(stderr, "Failed to open input.txt\n");
        exit(1);
    }
    fseek(f, 0, SEEK_END);
    long size = ftell(f);
    fseek(f, 0, SEEK_SET);
    char *buf = malloc(size + 1);
    if (!buf) {
        fprintf(stderr, "Failed to allocate memory\n");
        fclose(f);
        exit(1);
    }
    size_t nread = fread(buf, 1, size, f);
    fclose(f);
    if ((long)nread != size) {
        fprintf(stderr, "Failed to read input.txt\n");
        free(buf);
        exit(1);
    }
    buf[nread] = '\0';
    *out_size = size;
    return buf;
}

static void solve_part1(const char *input, long size) {
    (void)input;
    (void)size;
    /* TODO: implement part 1 */
    printf("TODO\n");
}

static void solve_part2(const char *input, long size) {
    (void)input;
    (void)size;
    /* TODO: implement part 2 */
    printf("TODO\n");
}

int main(int argc, char *argv[]) {
    if (argc < 2) {
        fprintf(stderr, "Usage: %s <part>\n", argv[0]);
        return 1;
    }
    int part = atoi(argv[1]);

    long size = 0;
    char *input = read_input(&size);

    if (part == 1) {
        solve_part1(input, size);
    } else if (part == 2) {
        solve_part2(input, size);
    } else {
        fprintf(stderr, "Unknown part: %d\n", part);
        free(input);
        return 1;
    }

    free(input);
    return 0;
}
