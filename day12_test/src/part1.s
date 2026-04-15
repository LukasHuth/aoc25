.global count_possible
.section .data
.section .text

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
