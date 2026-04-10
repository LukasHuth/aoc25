#include <stdbool.h>
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

static long find_occurence(const char *input, long size, const char *delimiter,
                           long delimiter_size) {
  long offset = 0;
  int find_offset = 0;
  while (offset < size) {
    if (input[offset++] == delimiter[find_offset])
      find_offset++;
    else
      find_offset = 0;
    if (find_offset == delimiter_size)
      return offset - delimiter_size;
  }
  return offset;
}

static long count_occurence(const char *input, long size, const char *delimiter,
                            long delimiter_size) {
  long offset = 0;
  long amount = 0;
  int find_offset = 0;
  while (offset < size) {
    if (input[offset++] == delimiter[find_offset])
      find_offset++;
    else
      find_offset = 0;
    if (find_offset == delimiter_size) {
      find_offset = 0;
      amount++;
    }
  }
  return amount;
}

static long split(const char *input, long size, const char *delimiter,
                  long delimiter_size, char ***parts) {
  long occurences = count_occurence(input, size, "\n\n", 2);
  *parts = (char **)calloc(occurences, sizeof(char *));
  const char *input_temp_ptr = input;
  for (int occurence = 0; occurence < occurences + 1; occurence++) {
    long amount = find_occurence(input_temp_ptr, size, "\n\n", 2);
    char *data = (char *)malloc(amount + 1);
    data[amount - 1] = '\0';
    strncpy(data, input_temp_ptr, amount);
    (*parts)[occurence] = data;
    input_temp_ptr += amount + 2;
  }
  return occurences + 1;
}

typedef bool Shape[3][3];
typedef Shape Shapes[5];

static void get_shapes(char **parts, Shapes *shapes) {
  for (int i = 0; i < 5; i++) {
    for (int j = 0; j < 3; j++) {
      for (int k = 0; k < 3; k++) {
        char **parts_part;
        split(parts[i], strlen(parts[i]), "\n", 1, &parts_part);
        (*shapes)[i][j][k] = parts_part[j][k] == '#';
      }
    }
  }
}

static void solve_part1(const char *input, long size) {
  (void)input;
  (void)size;
  char **parts;
  long amount = split(input, size, "\n\n", 2, &parts);
  for (long i = 0; i < amount; i++) {
    printf("input: \n%s\n", parts[i]);
  }
  Shapes shapes;
  get_shapes(parts, &shapes);
  char *regions = parts[5];
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
