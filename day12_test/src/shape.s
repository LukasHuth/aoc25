.global get_shape_area
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
