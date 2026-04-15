.global get_shape_area
.global fill_shape_area
.section .data
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
