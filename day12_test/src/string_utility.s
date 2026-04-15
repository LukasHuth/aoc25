.global string_utility_splitstring
.global string_utility_count_scalar
.global string_utility_count_two_scalar
.global string_utility_strlen
.global string_utility_find_scalar
.global string_utility_find
.section .data
.section .text
#------------------------------------------------------------------------------
# Split String - Splits a string at the specified delimiter
#------------------------------------------------------------------------------
# Arguments:
# rdi = string:0
# rsi = delimiter
# rdx = ptr to store the string vector ptr
#------------------------------------------------------------------------------
# Returns: The amount of elements, the string got split into
#------------------------------------------------------------------------------
.type string_utility_splitstring,@function
string_utility_splitstring:
  push %rbp
  mov %rsp, %rbp
  push %rdi # 0 = string
  push %rsi # 1 = delimiter
  push %rdx # 2 = vec return ptr

  call string_utility_strlen
  push %rax # 3 = str len

  mov -8(%rbp), %rdi
  mov -16(%rbp), %rsi
  mov -32(%rbp), %rdx
  call string_utility_count_scalar
  push %rax # 4 = delimiter occurences

  # TODO: use counted delimiter to alloc vector for each part, split and save (with null terminator)
  # allocate vector
  mov -40(%rbp), %rax
  mov $8, %rcx
  mul %rcx
  mov %rax, %rdi
  call utils_malloc
  push %rax

  # Store string vec
  mov -24(%rbp), %rdi
  lea 0(%rdi), %rdi
  mov %rax, (%rdi)

  xor %rcx, %rcx

  leave
  ret

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

  mov $-1, %r10d # create extraction mask everything (32 bytes)
  kmovq %r10, %k1 # load mask into mask reg

.Loop_full:
  cmp $32, %rsi
  jl .Loop_tail

  jmp .Loop_full
.Loop_tail:
  test %rsi, %rsi
  jz .Loop_end

  mov $1, %r10d # create extraction mask
  xchg %rcx, %rsi
  shl %cl, %r10d
  xchg %rcx, %rsi
  kmovq %r10, %k1 # load mask into mask reg
  vmovdqu8 (%rdi, %rcx), %ymm0{%k1}{z} # load with mask from mem
  vmovdqu8 %ymm0, (%rdi){%k1}

.Loop_end:

  pop %rcx
  vzeroupper
  ret
