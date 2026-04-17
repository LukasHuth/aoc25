.global get_region
.global get_regions
.section .data
.section .rodata
delimiter_colon_space:
  .asciz ": "              # bytes: 0x3a 0x20 0x00
delimiter_x:
  .asciz "x"
delimiter_space:
  .asciz " "
delimiter_newline:
  .asciz "\n"
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

# rdi = char* regions
# rsi = struct Rection ** regions
.type get_regions,@function
get_regions:
  push %rbp
  mov %rsp, %rbp
  sub $32, %rsp
  push %r12
  push %r13

  mov %rdi, -8(%rbp)
  mov %rsi, -16(%rbp)

  movq $0, -24(%rbp) # parts

  call string_utility_strlen
  mov %rax, %rsi

  mov -8(%rbp), %rdi
  leaq delimiter_newline(%rip), %rdx
  mov $1, %rcx
  leaq -24(%rbp), %r8
  call string_utility_split

  mov %rax, %r13 # region_count
  mov %rax, %rdi
  mov $32, %rsi # sizeof(struct Region)
  call calloc

  mov -16(%rbp), %rdi
  mov %rax, (%rdi) # *regions = calloc(region_count, sizeof(struct Region))

  xor %r12, %r12
.LregionsLoop:
  cmp %r13, %r12
  jge .LregionsLoopEnd # for(i = 0; i < region_count; i++)

  movq -24(%rbp), %rdi
  movq (%rdi, %r12, 8), %rdi
  test %rdi, %rdi
  jz 1f # if !parts[i] region_count-- continue
  call string_utility_strlen

  test %rax, %rax
  jz 1f # if strlen(parts[i]) == 0 region_count-- continue

  movq -24(%rbp), %rdi
  movq (%rdi, %r12, 8), %rdi

  mov -16(%rbp), %rsi
  mov (%rsi), %rsi
  leaq (, %r12, 4), %rcx
  leaq (%rsi, %rcx, 8), %rsi
  call get_region # get_region(parts[i], &((*regions)[i]))

  jmp 2f
  1:
  dec %r13
  2:
  inc %r12
  jmp .LregionsLoop
.LregionsLoopEnd:

  movq -24(%rbp), %rdi
  movq -32(%rbp), %rsi
  call utils_cleanup

  mov %r13, %rax

  pop %r13
  pop %r12
  add $32, %rsp
  leave
  ret
