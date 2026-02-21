#include <stdio.h>
#include <stdlib.h>
#include <string.h>

long long int calculate_overall_joltage(int depth);

void part1() {
  long long int result = calculate_overall_joltage(2);
  if(result < -1) return;
  printf("%lld\n", result);
}

void part2() {
  long long int result = calculate_overall_joltage(12);
  if(result < -1) return;
  printf("%lld\n", result);
}

int main(int argc, char** argv) {
  if(argc >= 2 && *argv[1] == '2') {
    part2();
  } else {
    part1();
  }
  return 0;
}

static inline long long int ipow(long long int base, int pow) {
  if (pow == 0) return 1;
  return base * ipow(base, pow - 1);
}

long long int get_highest_joltage(char* line, int offset, int depth, int string_size, long long int **lookup_table) {
  if(depth == 0) return 0;
  if(lookup_table[offset][depth] != 0) return lookup_table[offset][depth];
  long long int result = 0;
  int int_offset = 0;
  long long int current;
  long long int highest_possible;
  while(offset + int_offset + depth < string_size) {
    current = ((long long int)(*(line + offset + int_offset++) - '0')) * ipow(10, depth - 1);
    highest_possible = current + ipow(10, depth - 1) - 1;
    if(highest_possible < result) continue;
    current += get_highest_joltage(line, offset + int_offset, depth - 1, string_size, lookup_table);
    if(current > result) result = current;
  }
  lookup_table[offset][depth] = result;
  return result;
}

long long int calculate_overall_joltage(int depth) {
  FILE* fptr = fopen("input.txt", "r");
  if(fptr == NULL) {
    printf("Failed to open input");
    return -1;
  }
  long long int result = 0;
  char line_buffer[102];
  while (fgets(line_buffer, sizeof(line_buffer), fptr)) {
    int line_length = strlen(line_buffer);
    long long int** lookup_table = malloc((line_length + 2) * sizeof(long long int *));
    for(int i = 0; i < line_length; i++) {
      lookup_table[i] = calloc((depth + 1), sizeof(long long int));
    }
    result += get_highest_joltage(line_buffer, 0, depth, line_length, lookup_table);
  }
  fclose(fptr);
  return result;
}
