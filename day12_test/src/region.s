.global get_region
.section .data
.section .rodata
delimiter_colon_space:
  .asciz ": "              # bytes: 0x3a 0x20 0x00
delimiter_x:
  .asciz "x"
delimiter_space:
  .asciz " "
.section .text

.extern split
.extern utils_stoi
.extern string_utility_strlen
.extern cleanup

# rdi = char* part
# rsi = struct Region *region
.type get_region,@function
get_region:
  push %rbp
  mov %rsp, %rbp
  # local0 = -8(%rbp)
  # local1 = -16(%rbp)
  # local2 = -24(%rbp)
  # local3 = -32(%rbp)
  # local4 = -40(%rbp)
  # local5 = -48(%rbp)
  # local6 = -56(%rbp)
  # local7 = -64(%rbp)
  sub $(8 * 8), %rsp # keep 32 byte alignment
  movq %r12, -8(%rbp)
  mov %rsi, %r12
  movq %rdi, -16(%rbp)
  call string_utility_strlen
  movq -16(%rbp), %rdi
  mov %rax, %rsi
  leaq delimiter_colon_space(%rip), %rdx   # rdx = delimiter (const char*)
  mov  $2, %rcx
  movq $0, -24(%rbp) # local2 = char** left_right
  leaq -24(%rbp), %r8
  call split
  # discard rax
  movq -24(%rbp), %rdi
  movq 0(%rdi), %rdi
  call string_utility_strlen
  movq -24(%rbp), %rdi
  movq 0(%rdi), %rdi
  mov %rax, %rsi
  leaq delimiter_x(%rip), %rdx   # rdx = delimiter (const char*)
  mov  $1, %rcx
  movq $0, -32(%rbp) 
  leaq -32(%rbp), %r8
  call split

  movq -32(%rbp), %rdi
  movq 0(%rdi), %rdi
  call utils_stoi
  mov %eax, 0(%r12)

  movq -32(%rbp), %rdi
  movq 8(%rdi), %rdi
  call utils_stoi
  mov %eax, 4(%r12)

  movq -24(%rbp), %rdi
  movq 8(%rdi), %rdi
  call string_utility_strlen
  movq -24(%rbp), %rdi
  movq 8(%rdi), %rdi
  mov %rax, %rsi
  leaq delimiter_space(%rip), %rdx   # rdx = delimiter (const char*)
  mov  $1, %rcx
  movq $0, -40(%rbp) 
  leaq -40(%rbp), %r8
  call split
  mov %rax, -48(%rbp)

  .set j,0
  .rept 6
  cmpq $j, -48(%rbp)
  jge 1f
  movq -40(%rbp), %rdi
  movq (8 * j)(%rdi), %rdi
  call string_utility_strlen
  test %rax, %rax
  jz 1f
  movq -40(%rbp), %rdi
  movq (8 * j)(%rdi), %rdi
  mov %eax, (8 + 4 * j)(%r12)
# TODO: missing stoi and store xD
  1:
  .endr

  movq -40(%rbp), %rdi
  movq -48(%rbp), %rsi
  call cleanup
  movq -32(%rbp), %rdi
  movq $2, %rsi
  call cleanup
  movq -24(%rbp), %rdi
  movq $2, %rsi
  call cleanup

  mov -8(%rbp), %r12
  add $(8 * 8), %rsp
  leave
  ret

