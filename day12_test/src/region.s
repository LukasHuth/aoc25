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

.extern string_utility_split
.extern utils_stoi
.extern string_utility_strlen
.extern utils_cleanup

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
  call string_utility_split
  # discard rax
  movq -24(%rbp), %rdi
  movq 0(%rdi), %rdi
  call string_utility_strlen
  movq -24(%rbp), %rdi
  movq 0(%rdi), %rdi
  mov %rax, %rsi
  leaq delimiter_x(%rip), %rdx   # rdx = delimiter (const char*)
  mov  $1, %rcx
  movq $0, -32(%rbp) # dimensions
  leaq -32(%rbp), %r8
  call string_utility_split

  movq -32(%rbp), %rdi
  movq 0(%rdi), %rdi
  call utils_stoi
  mov %eax, 0(%r12)  # regions[i]->width = atoi(dimensions[0])

  movq -32(%rbp), %rdi
  movq 8(%rdi), %rdi
  call utils_stoi
  mov %eax, 4(%r12)  # regions[i]->height = atoi(dimensions[1])

  movq -24(%rbp), %rdi
  movq 8(%rdi), %rdi
  call string_utility_strlen
  movq -24(%rbp), %rdi
  movq 8(%rdi), %rdi
  mov %rax, %rsi
  leaq delimiter_space(%rip), %rdx   # rdx = delimiter (const char*)
  mov  $1, %rcx
  movq $0, -40(%rbp)   #  amounts
  leaq -40(%rbp), %r8
  call string_utility_split
  mov %rax, -48(%rbp) # amounts_length

  .set j,0
  .rept 6
  cmpq $j, -48(%rbp) # if j >= amounts_length
  jl 2f              # break
  movq -40(%rbp), %rdi
  movq (8 * j)(%rdi), %rdi
  call string_utility_strlen
  test %rax, %rax       # if strlen(amounts[j]) == 0
  jz 1f # continue
  movq -40(%rbp), %rdi
  movq (8 * j)(%rdi), %rdi
  call utils_stoi
  mov %eax, (8 + 4 * j)(%r12) # region->presents[j] = atoi(amounts[j])
  1:
  .set j,j+1
  .endr
  2:

  movq -40(%rbp), %rdi
  movq -48(%rbp), %rsi
  call utils_cleanup
  movq -32(%rbp), %rdi
  movq $2, %rsi
  call utils_cleanup
  movq -24(%rbp), %rdi
  movq $2, %rsi
  call utils_cleanup

  mov -8(%rbp), %r12
  add $(8 * 8), %rsp
  leave
  ret

