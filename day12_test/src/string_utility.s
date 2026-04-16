.global string_utility_count_scalar
.global string_utility_count_two_scalar
.global string_utility_strlen
.global string_utility_find_scalar
.global string_utility_find
.global string_utility_copy
.global string_utility_split
.section .data
.section .text

.extern string_utility_count_two_scalar
.extern calloc

#------------------------------------------------------------------------------
# Count Scalar - Counts a Scalar in a string
#------------------------------------------------------------------------------
# Arguments:
# rdi = string
# rsi = delimiter
# rdx = string len
#------------------------------------------------------------------------------
# Returns: The amount the scalar was detected in the string
#------------------------------------------------------------------------------
  .type string_utility_count_scalar,@function
  string_utility_count_scalar:
  xor   %ecx, %ecx              # count = 0
  test  %rdx, %rdx
  jz    .done

  movzx %sil, %esi
  vmovd %esi, %xmm1
  vpbroadcastb %xmm1, %ymm1

  .loop32:
  cmp   $32, %rdx
  jb    .tail

  vmovdqu   (%rdi), %ymm0
  vpcmpeqb  %ymm1, %ymm0, %ymm0
  vpmovmskb %ymm0, %r8d
  popcnt    %r8d, %r8d
  add       %r8, %rcx

  add   $32, %rdi
  sub   $32, %rdx
  jmp   .loop32

  .tail:
  test  %rdx, %rdx
  jz    .done
  movb  (%rdi), %al
  cmpb  %sil, %al
  jne   1f
  inc   %rcx
  1:
  inc   %rdi
  dec   %rdx
  jmp   .tail

  .done:
  mov   %rcx, %rax
  vzeroupper
  ret

#------------------------------------------------------------------------------
# Count two Scalar - Counts a Scalar in a string
#------------------------------------------------------------------------------
# Arguments:
# rdi = string
# rsi = delimiter 1
# rdx = delimiter 2
# rcx = string len
#------------------------------------------------------------------------------
# Returns: The amount the scalar was detected in the string
#------------------------------------------------------------------------------
.type string_utility_count_scalar,@function
string_utility_count_two_scalar:
  xchg %rdx, %rcx
  test %rcx, %rcx
  jnz .two_delimiters

  call string_utility_count_scalar
  ret

.two_delimiters:
  # rdi = string
  # rsi = delimiter 1
  # rdx = string len
  # rcx = delimiter 2
  mov %rcx, %r9
  xor   %ecx, %ecx              # count = 0
  test  %rdx, %rdx
  jz    .done_2

  movzx %sil, %esi
  vmovd %esi, %xmm2
  vpbroadcastb %xmm2, %ymm2
  movzx %r9b, %r9d
  vmovd %r9d, %xmm3
  vpbroadcastb %xmm3, %ymm3

  .loop32_2:
  cmp   $32, %rdx
  jb    .tail_2

  vmovdqu   (%rdi), %ymm0
  vmovaps %ymm0, %ymm1
  vpcmpeqb  %ymm3, %ymm1, %ymm1
  vpmovmskb %ymm1, %r10d
  vpcmpeqb  %ymm2, %ymm0, %ymm0
  vpmovmskb %ymm0, %r8d
  shl $1, %r10d
  and %r10d, %r8d
  popcnt    %r8d, %r8d
  add       %r8, %rcx

  add   $32, %rdi
  sub   $32, %rdx
  jmp   .loop32_2

  .tail_2:
  test  %rdx, %rdx
  jz    .done_2
  movb  (%rdi), %al
  cmpb  %sil, %al
  jne   1f
  movb  1(%rdi), %al
  cmpb  %r9b, %al
  jne   1f
  inc   %rcx
  1:
  inc   %rdi
  dec   %rdx
  jmp   .tail_2

  .done_2:
  mov   %rcx, %rax
  vzeroupper
  ret

#------------------------------------------------------------------------------
# String length - returns the number of chars until \0 is read
#------------------------------------------------------------------------------
# Arguments:
# rdi = string
#------------------------------------------------------------------------------
# Returns: The length of the string
#------------------------------------------------------------------------------
.type string_utility_strlen,@function
string_utility_strlen:
  xor %rsi, %rsi
  call string_utility_find_scalar
  ret

#------------------------------------------------------------------------------
# String find - returns the offset, when a character is found
#------------------------------------------------------------------------------
# Arguments:
# rdi = string
# rsi = character to find
# rdx = 2 character to find
#------------------------------------------------------------------------------
# Returns: The offset, when a char is found.
#   When nothing is found the amount until the string end is returned.
#------------------------------------------------------------------------------
string_utility_find_scalar:
  xor %rdx, %rdx
  call string_utility_find
  ret

#------------------------------------------------------------------------------
# String find - returns the offset, when a character is found
#------------------------------------------------------------------------------
# Arguments:
# rdi = string
# rsi = character to find
# rdx = 2 character to find
#------------------------------------------------------------------------------
# Returns: The offset, when a char is found.
#   When nothing is found the amount until the string end is returned.
#------------------------------------------------------------------------------
string_utility_find:
  xor %rcx, %rcx
  test %rdi, %rdi
  jz .Lend_zero
  vpxor %ymm1, %ymm1, %ymm1
  vpxor %ymm2, %ymm2, %ymm2

  movzx %sil, %rsi # clear upper bits of rsi
  vmovd %esi, %xmm1 
  vpbroadcastb %xmm1, %ymm1 # copy lowest byte everywhere
.Lymm_Loop_find:
  vmovdqu (%rdi, %rcx), %ymm0
  vpcmpeqb %ymm1, %ymm0, %ymm3 # find char
  vpcmpeqb %ymm2, %ymm0, %ymm4 # find string end
  vpor %ymm3, %ymm4, %ymm5 # combine findings

  vpmovmskb %ymm5, %r8d # extract findings as mask
.Lfind_loop:
  test %r8, %r8
  jz .Lnext

  # if first found is null return i
  tzcnt %r8, %rax # count where first hit was found
  lea (%rax, %rcx), %rax
  movb (%rdi, %rax), %al
  test %al, %al
  jz .Lreturn_i

  # if next char is null return i
  cmp $0, %rdx
  je .Lreturn_i
  # if next char is equal return i
  tzcnt %r8, %rax # count where first hit was found
  lea 1(%rax, %rcx), %rax
  movb (%rdi, %rax), %al
  cmpb %dl, %al
  je .Lreturn_i

  tzcnt %r8, %rax # count where first hit was found
  btr     %eax, %r8d
  jmp .Lfind_loop

.Lnext:
  add $32, %rcx
  jmp .Lymm_Loop_find

.Lend_zero:
  xor %rax, %rax
.Lreturn_i:
  tzcnt %r8, %rax # count where first hit was found
  add %rcx, %rax
.Lend:
  vzeroupper
  ret

#------------------------------------------------------------------------------
# String copy - copies the string into the ptr
#------------------------------------------------------------------------------
# Arguments:
# rdi = string
# rsi = amount to copy
# rdx = destination ptr
#------------------------------------------------------------------------------
# Returns: Nothing
#------------------------------------------------------------------------------
string_utility_copy:
  push %rcx

  xor %rcx, %rcx

.Loop_full:
  cmp $32, %rsi
  jl .Loop_tail

  vmovdqu (%rdi), %ymm0
  vmovdqu %ymm0, (%rdx)

  add $32, %rdi
  add $32, %rdx
  sub $32, %rsi
  jmp .Loop_full
.Loop_tail:
  test %rsi, %rsi
  jz .Loop_end

  movb (%rdi), %r9b
  movb %r9b, (%rdx)

  inc %rdi
  inc %rdx
  dec %rsi
  jmp .Loop_tail

.Loop_end:

  pop %rcx
  vzeroupper
  ret

#------------------------------------------------------------------------------
# String split - splits the string at a delimiter
#------------------------------------------------------------------------------
# Arguments:
# rdi = char* input
# rsi = long input_length
# rdx = char* delimiter
# rcx = long delimiter_size
# r8 = char ***parts
#------------------------------------------------------------------------------
# Returns: amount of elements that where split into
#------------------------------------------------------------------------------
string_utility_split:
  push %rbp
  mov %rsp, %rbp
  
  test %rdi, %rdi # if !input
  jnz 1f # return 0
  xor %rax, %rax
  leave
  ret

1:
  sub $96, %rsp
  # save r12, r13
  push %r12
  push %r13

  mov %rdi, -8(%rbp)
  mov %rsi, -16(%rbp)
  mov %rdx, -24(%rbp)
  mov %rcx, -32(%rbp)
  mov %r8, -40(%rbp)

  # rdi = input
  xchg %rsi, %rcx # rcx = input_length
  movzbq 0(%rdx), %rsi
  movzbq 1(%rdx), %rdx
  call string_utility_count_two_scalar
  mov %rax, -48(%rbp) # occurences = count(input, input_length, delimiter, delimiter_size)

  leaq 1(%rax), %rdi
  mov $8, %rsi
  call calloc
  
  mov -40(%rbp), %rdi
  mov %rax, (%rdi) # *parts = calloc(occurences + 1, sizeof(char *))

  mov -8(%rbp), %rsi
  mov %rsi, -56(%rbp) # temp_input = input

  mov -48(%rbp), %r13 # occurences
  inc %r13
  xor %r12, %r12 # occurence
  1:#loop_start
  cmpq %r13, %r12
  jge 1f # if i >= occurences end loop

  movq -56(%rbp), %rdi
  movq -24(%rbp), %rdx
  movzbq 0(%rdx), %rsi
  movzbq 1(%rdx), %rdx
  call string_utility_find
  mov %rax, -72(%rbp) # amount = find(temp_input, delimiter, delimiter_size)

  leaq 1(%rax), %rdi
  movq $1, %rsi
  call calloc
  mov %rax, -80(%rbp) # data = calloc(amount + 1, sizeof(char*))

  mov -56(%rbp), %rdi
  mov -72(%rbp), %rsi
  mov %rax, %rdx
  call string_utility_copy # copy(temp_input, amount, data)

  mov -80(%rbp), %rdi
  mov -72(%rbp), %rdx
  movb $0, (%rdi, %rdx) # data[amount] = '\0'

  mov -40(%rbp), %rsi
  mov (%rsi), %rsi
  mov %rdi, (%rsi, %r12, 8) # (*parts)[occurence] = data

  mov -56(%rbp), %rdi
  add %rdx, %rdi
  add -32(%rbp), %rdi
  mov %rdi, -56(%rbp) # temp_input += amount + delimiter_size

  inc %r12

  jmp 1b
  1:#loop_end

  # return occurences + 1
  mov %r13, %rax

  # restore r12, r13
  pop %r13
  pop %r12

  add $96, %rsp
  leave
  ret
