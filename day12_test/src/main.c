#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>

char *read_input(long *out_size);
long string_utility_count_scalar(const char *input, char delimiter, long size);
long string_utility_count_two_scalar(const char *input, char delimiter,
                                     char delimiter2, long size);
long string_utility_find_scalar(const char *input, char delimiter);
long string_utility_find(const char *input, char delimiter, char delimiter2);
long string_utility_strlen(const char *input);
void utils_panic(const char *msg, long exit_code) __attribute__((noreturn));
void string_utility_copy(const char *input, long amount, char *dest);
long string_utility_split(const char *input, long input_length,
                          const char *delimiter, long delimiter_size,
                          char ***parts);
void utils_cleanup(char **arr, long amount);
typedef bool Shape[3][3];
#define PresentAmount 6
typedef Shape Shapes[PresentAmount];
void get_shapes(char **parts, Shapes *shapes);
struct Region {
  int width;
  int height;
  int presents[PresentAmount];
};

void get_region(char *part, struct Region *region);
long get_regions(char *regions_str, struct Region **regions);
long get_shape_area(Shape *shape);
long count_possible(struct Region *regions, long region_count,
                    long shape_area[6]);
void fill_shape_area(Shapes *shapes, long *shape_area);
void solve_part1(const char *input, long size);

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
