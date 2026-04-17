.global get_shape_area
.global fill_shape_area
.global get_shapes
.section .data
.section .rodata
delimiter_newline:
  .asciz "\n"
.section .text

.type get_shape_area,@function
get_shape_area:
  xor %rax, %rax
  .set i, 0
  .rept 9
    addb i(%rdi), %al
    .set i, i + 1
  .endr
  ret

# rdi = Shape*
# rsi = *long
.type fill_shape_area,@function
fill_shape_area:
  mov %rdi, %r9
  .set i, 0
  .rept 6
    lea (9*i)(%r9), %rdi
    call get_shape_area
    mov %rax, (8*i)(%rsi)
    .set i, i + 1
  .endr
  xor %rax, %rax
  ret

# rdi = char **parts
# rsi = Shapes *shapes
.type get_shapes,@function
get_shapes:
  push %rbp
  mov %rsp, %rbp
  sub $32, %rsp
  
  mov %rdi, -8(%rbp)
  mov %rsi, -16(%rbp)

  .set i,0
  .rept 6

  mov -8(%rbp), %rdi
  mov (i * 8)(%rdi), %rdi
  call string_utility_strlen

  movq $0, -24(%rbp) # parts_part
  mov -8(%rbp), %rdi
  mov (i * 8)(%rdi), %rdi
  mov %rax, %rsi
  leaq delimiter_newline(%rip), %rdx   # rdx = delimiter (const char*)
  mov $1, %rcx
  leaq -24(%rbp), %r8
  call string_utility_split
  mov %rax, -32(%rbp) # parts_part_length
  .set BoolSize, 1
  .set ShapeSize, 3 * 3 * BoolSize
  .set j, 0
  .rept 3

  .set k, 0
  .rept 3

  mov -16(%rbp), %rdi
  // mov (%rdi), %rdi
  leaq (i * ShapeSize + j * 3 * BoolSize + k * BoolSize)(%rdi), %rdi
  # &((*shapes)[i][j][k])

  mov -24(%rbp), %rsi
  mov ((j + 1) * 8)(%rsi), %rsi
  movzbq (k)(%rsi), %rsi # parts_part[j + 1][k]

  cmp $'#', %rsi
  sete %al
  movb %al, (%rdi) # (*shapes)[i][j][k] = parts_part[j + 1][k] == '#'

  .set k, k+1
  .endr

  .set j, j+1
  .endr

  mov -24(%rbp), %rdi
  mov -32(%rbp), %rsi
  call utils_cleanup

  .set i,i+1
  .endr

  add $32, %rsp
  leave
  ret
