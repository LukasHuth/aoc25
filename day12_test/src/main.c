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

long string_utility_count_scalar(const char *input, char delimiter, long size);
long string_utility_count_two_scalar(const char *input, char delimiter,
                                     char delimiter2, long size);
long string_utility_find_scalar(const char *input, char delimiter);
long string_utility_find(const char *input, char delimiter, char delimiter2);
long string_utility_strlen(const char *input);
// long string_utility_count_scalar(const char *input, long size,
// char delimiter);
/* */
static void panic(const char *msg) __attribute__((noreturn));
static void panic(const char *msg) {
  printf("%s\n", msg);
  exit(1);
}
static long find_occurence(const char *input, long size, const char *delimiter,
                           long delimiter_size) {
  if (delimiter_size <= 2)
    return string_utility_find(input, delimiter[0], delimiter[1]);
  panic("Can only handle delimiter with size 2 or less");
}
/* */

/* */
static long count_occurence(const char *input, long size, const char *delimiter,
                            long delimiter_size) {
  if (delimiter_size <= 2)
    return string_utility_count_two_scalar(input, delimiter[0], delimiter[1],
                                           size);
  panic("Can only handle delimiter with size 2 or less");
}
/* */

static long split(const char *input, long size, const char *delimiter,
                  long delimiter_size, char ***parts) {
  long occurences = count_occurence(input, size, delimiter, delimiter_size);
  *parts = (char **)calloc(occurences + 1, sizeof(char *));
  const char *input_temp_ptr = input;
  long remaining = size;
  for (int occurence = 0; occurence < occurences + 1; occurence++) {
    long amount =
        find_occurence(input_temp_ptr, remaining, delimiter, delimiter_size);
    char *data = (char *)calloc(amount + 1, sizeof(char));
    strncpy(data, input_temp_ptr, amount);
    data[amount] = '\0';
    (*parts)[occurence] = data;
    input_temp_ptr += amount + delimiter_size;
    remaining -= amount + delimiter_size;
    if (remaining < 0)
      remaining = 0;
  }
  return occurences + 1;
}

static void cleanup(char **arr, long amount) {
  return;
  if (!arr)
    return;
  for (long i = 0; i < amount; i++) {
    free(arr[i]);
  }
  free(arr);
}

typedef bool Shape[3][3];
#define PresentAmount 6
typedef Shape Shapes[PresentAmount];

static void get_shapes(char **parts, Shapes *shapes) {
  for (int i = 0; i < PresentAmount; i++) {
    char **parts_part;
    long parts_part_length =
        split(parts[i], string_utility_strlen(parts[i]), "\n", 1, &parts_part);
    for (int j = 0; j < 3; j++) {
      for (int k = 0; k < 3; k++) {
        (*shapes)[i][j][k] = parts_part[j + 1][k] == '#';
      }
    }
    cleanup(parts_part, parts_part_length);
  }
}

struct Region {
  int width;
  int height;
  int presents[PresentAmount];
};

static void get_region(char *part, struct Region *region) {
  char **left_right;
  split(part, string_utility_strlen(part), ": ", 2, &left_right);
  char **dimensions;
  split(left_right[0], string_utility_strlen(left_right[0]), "x", 1,
        &dimensions);
  region->width = atoi(dimensions[0]);
  region->height = atoi(dimensions[1]);
  char **amounts;
  long amounts_length = split(
      left_right[1], string_utility_strlen(left_right[1]), " ", 1, &amounts);
  for (int j = 0; j < PresentAmount; j++) {
    if (j >= amounts_length)
      break;
    if (string_utility_strlen(amounts[j]) == 0)
      continue;
    region->presents[j] = atoi(amounts[j]);
  }
  cleanup(amounts, amounts_length);
  cleanup(dimensions, 2);
  cleanup(left_right, 2);
}
static long get_regions(char *regions_str, struct Region **regions) {
  char **parts;
  long region_count =
      split(regions_str, string_utility_strlen(regions_str), "\n", 1, &parts);
  *regions = calloc(region_count, sizeof(struct Region));
  for (long i = 0; i < region_count; i++) {
    if (string_utility_strlen(parts[i]) == 0) {
      region_count--;
      continue;
    }
    get_region(parts[i], &((*regions)[i]));
  }
  cleanup(parts, region_count);
  return region_count;
}

long get_shape_area(Shape *shape);
/*
static long get_shape_area(Shape *shape) {
  return (*shape)[0][0] + (*shape)[0][1] + (*shape)[0][2] + (*shape)[1][0] +
         (*shape)[1][1] + (*shape)[1][2] + (*shape)[2][0] + (*shape)[2][1] +
         (*shape)[2][2];
}
/* */

long count_possible(struct Region *regions, long region_count,
                    long shape_area[6]);
/*
static long count_possible(struct Region *regions, long region_count,
                           long (shape_area)[6]) {
  long possible = 0;
  long possible_area, needed_area;
  for (long i = 0; i < region_count; i++) {
    possible_area = regions[i].width * regions[i].height;
    needed_area = 0;
    for (long j = 0; j < PresentAmount; j++) {
      needed_area += regions[i].presents[j] * shape_area[j];
    }
    if (needed_area <= possible_area)
      possible++;
    printf("I: %ld needed: %ld possible: %ld\n", i, needed_area, possible_area);
  }
  return possible;
}
/* */
void fill_shape_area(Shapes *shapes, long *shape_area);
/*
static void fill_shape_area(Shapes *shapes, long *shape_area) {
  for (int i = 0; i < PresentAmount; i++) {
    shape_area[i] = get_shape_area(&(*shapes)[i]);
  }
}
*/
static void solve_part1(const char *input, long size) {
  (void)input;
  (void)size;
  char **parts;
  long amount = split(input, size, "\n\n", 2, &parts);
  for (long i = 0; i < amount; i++) {
    printf("input: \n%s\n", parts[i]);
  }
  // printf("a\n");
  Shapes *shapes = calloc(1, sizeof(Shapes));
  get_shapes(parts, shapes);
  // printf("b\n");
  for (int i = 0; i < PresentAmount; i++) {
    printf("Shape %d:\n", i);
    for (int j = 0; j < 3; j++) {
      printf("%c%c%c\n", ((*shapes)[i][j][0]) ? '#' : '.',
             ((*shapes)[i][j][1]) ? '#' : '.',
             ((*shapes)[i][j][2]) ? '#' : '.');
    }
  }
  struct Region *regions;
  long shape_area[6];
  fill_shape_area(shapes, shape_area);
  free(shapes);
  long region_count = get_regions(parts[6], &regions);
  // long possible = count_possible(regions, region_count, &shape_area);
  long possible = count_possible(regions, region_count, shape_area);
  free(regions);
  // printf("TODO\n");
  printf("Possible: %ld\n", possible);
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
