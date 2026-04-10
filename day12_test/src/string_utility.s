.global string_utility_splitstring
.global string_utility_count_scalar
.global string_utility_strlen
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
  push %rbp
  mov %rsp, %rbp
  push %rdi
  push %rsi
  push %rdx

  # count delimiters
  xor %rcx, %rcx

  # fill delimiter SSE register
  mov -24(%rbp), %r9 # load str len
  mov -16(%rbp), %rax # load delimiter
  mov -8(%rbp), %rdi # load str
  vpxor %ymm0, %ymm0, %ymm0
  movzx %sil, %rsi # clear upper bits of rsi
  vmovd %esi, %xmm1 
  vpbroadcastb %xmm1, %ymm1 # copy lowest byte everywhere
  xor %r8, %r8
  mov $-1, %r10d # create extraction mask everything (32 bytes)
  kmovq %r10, %k1 # load mask into mask reg
.Lymm_loop:
  cmp $32, %r9
  jb .Ltail_mask # if remaining < 32 do masked loading

  vmovdqu8 (%rdi), %ymm0{%k1}{z} # load with mask from mem
  vpcmpeqb %ymm1, %ymm0, %ymm0 # find equal bytes and store mask in ymm0
  vpmovmskb %ymm0, %r8d # laod mask into r8d
  popcnt %r8d, %r8d # count ones
  add %r8, %rcx

  add $32, %rdi
  sub $32, %r9
  jmp .Lymm_loop
.Ltail_mask:
  test %r9, %r9
  jz .Ldone_tail # nothing to do on 0

  mov $1, %r10
  xchg %r9, %rcx
  shl %cl, %r10d # shift by missing byte amount
  dec %r10d # dec to create mask
  xchg %r9, %rcx
  kmovq %r10, %k1 # load mask into mask reg
  vmovdqu8 (%rdi), %ymm0{%k1}{z} # load from mem via mask fill 0
  vpcmpeqb %ymm1, %ymm0, %ymm0 # find equal bytes and store mask in ymm0
  vpmovmskb %ymm0, %r8d # laod mask into r8d
  popcnt %r8d, %r8d # count ones
  add %r8, %rcx

.Ldone_tail:
  mov %rcx, %rax

  leave
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
  call string_utility_find
  ret

#------------------------------------------------------------------------------
# String find - returns the offset, when a character is found
#------------------------------------------------------------------------------
# Arguments:
# rdi = string
# rsi = character to find
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
  test %r8, %r8
  jnz .Lymm_End_find

  add $32, %rcx
  jmp .Lymm_Loop_find
.Lymm_End_find:
  tzcnt %r8, %rax # count where first hit was found
  add %rcx, %rax
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
