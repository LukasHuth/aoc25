.global read_input
.section .data
.section .rodata
filename:
  .asciz "input.txt"
filemode:
  .asciz "r"
failed_to_open:
  .asciz "Failed to open input.txt\n"
failed_to_allocate:
  .asciz "Failed to allocate memory\n"
failed_to_read:
  .asciz "Failed to read input.txt\n"
.section .text

.set SEEKEND, 2
.set SEEKSET, 0

.extern fopen
.extern fclose
.extern fread
.extern free
.extern malloc
.extern utils_panic

.type read_input,@function
read_input:
  push %rbp
  mov %rsp, %rbp
  sub $64, %rsp
  mov %rdi, -8(%rbp)

  leaq filename(%rip), %rdi
  leaq filemode(%rip), %rsi
  call fopen

  test %rax, %rax
  jnz 1f

  leaq failed_to_open(%rip), %rdi
  mov $1, %rsi
  call utils_panic
  1:

  movq %rax, -16(%rbp) # f
  mov %rax, %rdi
  xor %rsi, %rsi
  mov $SEEKEND, %rdx
  call fseek

  movq -16(%rbp), %rdi
  call ftell
  movq %rax, -24(%rbp) # size

  movq -16(%rbp), %rdi
  xor %rsi, %rsi
  mov $SEEKSET, %rdx
  call fseek

  movq -24(%rbp), %rdi
  inc %rdi
  call malloc
  test %rax, %rax
  jnz 1f

  movq -16(%rbp), %rdi
  call fclose

  leaq failed_to_allocate(%rip), %rdi
  mov $2, %rsi
  call utils_panic

  1:
  movq %rax, -32(%rbp) # buf

  movq %rax, %rdi
  movq $1, %rsi
  movq -24(%rbp), %rdx
  movq -16(%rbp), %rcx
  call fread
  movq %rax, -40(%rbp) # nread

  movq -16(%rbp), %rdi
  call fclose

  movq -24(%rbp), %rdi
  movq -40(%rbp), %rsi
  cmp %rdi, %rsi
  je 1f

  movq -32(%rbp), %rdi
  call free

  leaq failed_to_read(%rip), %rdi
  mov $3, %rsi
  call utils_panic

  1:

  movq -32(%rbp), %rdi
  movq -40(%rbp), %rsi
  add %rsi, %rdi
  movb $'\0', (%rdi)

  movq -24(%rbp), %rdi
  movq -8(%rbp), %rsi
  movq %rdi, (%rsi)

  movq -32(%rbp), %rax
  add $64, %rsp
  leave
  ret
