.global count_possible
.global solve_part1
.section .data
.section .rodata
delimiter_double_newline:
  .asciz "\n\n"
possible_printf:
  .asciz "Possible: %ld\n"
.section .text

.extern printf
.extern free

# rdi = regions*
# rsi = region_count
# rdx = *shape_area
.type count_possible,@function
count_possible:
  push %r12
  push %r13
  xor %rcx, %rcx
  xor %r10, %r10
  .region_loop:
  xor %r11, %r11
  cmp $0, %rsi
  je .region_loop_end
  mov 0(%rdi), %r10d
  mov 4(%rdi), %r12d
  imul %r12d, %r10d
  .set j, 0
  .rept 6
    mov (8 + 4 * j)(%rdi), %r12d
    mov (8 * j)(%rdx), %r13d
    imul %r13, %r12
    add %r12, %r11
    .set j, j+1
  .endr
  cmp %r10, %r11
  jg .region_loop_impossible
  inc %rcx
  .region_loop_impossible:
  dec %rsi
  add $(4 + 4 + 6 * 4), %rdi
  jmp .region_loop
  .region_loop_end:
  mov %rcx, %rax
  pop %r13
  pop %r12
  ret


# rdi = char* input
# rsi = long size
.type solve_part1,@function
solve_part1:
  push %rbp
  mov %rsp, %rbp
  .set variables, 64
  .set ShapeAreaSize, 48
  sub $variables + ShapeAreaSize, %rsp

  mov %rdi, -8(%rbp) # input
  mov %rsi, -16(%rbp) # size

  leaq delimiter_double_newline(%rip), %rdx
  mov $2, %rcx
  movq $0, -24(%rbp)
  leaq -24(%rbp), %r8 # parts
  call string_utility_split

  mov $1, %rdi
  mov $54, %rsi
  call calloc
  mov %rax, -32(%rbp) # shapes = calloc(1, sizeof(Shapes))

  mov -24(%rbp), %rdi
  mov %rax, %rsi
  call get_shapes # get_shapes(parts, shapes)

  mov -32(%rbp), %rdi
  leaq -(ShapeAreaSize + variables)(%rbp), %rsi # shape_area
  call fill_shape_area # fill_shape_area(shapes, shape_area)
  mov -32(%rbp), %rdi
  call free # free(shapes)

  movq $0, -40(%rbp) # regions
  mov -24(%rbp), %rdi
  mov (6 * 8)(%rdi), %rdi
  leaq -40(%rbp), %rsi
  call get_regions # get_regions(parts[6], &regions)
  mov %rax, -48(%rbp) # region_count

  movq -40(%rbp), %rdi
  mov %rax, %rsi
  leaq -(ShapeAreaSize + variables)(%rbp), %rdx # shape_area
  call count_possible # possible = count_possible(regions, region_count, shape_area)

  leaq possible_printf(%rip), %rdi
  mov %rax, %rsi
  xor %rax, %rax
  call printf

  movq -40(%rbp), %rdi
  call free # free(regions)

  add $variables + ShapeAreaSize, %rsp
  leave
  ret
