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
.Lymm_loop:
  cmp $32, %r9
  jb .Ltail_mask # if remaining < 32 do masked loading

  mov $-1, %r10d # create extraction mask everything (32 bytes)
  kmovq %r10, %k1 # load mask into mask reg
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
  mov %rdi, %rcx # load str ptr into rcx
  and $0xF, %rcx # mask rcx to 0-15
  mov $0x10, %rdx 
  sub %rcx, %rdx 
  mov %rdx, %rcx # rcx = 16 - (str & 0xF)
  xor %rax, %rax # clear rax
  .LalignmentLoop:
  movzbq (%rdi, %rax, 1), %rdx # load char at str[rax] -> rdx
  test %dl, %dl # test rdx
  jz .Lexit  # jump to exit if 0 is hit
  inc %rax # rax++
  cmp %rax, %rcx # rax < rcx repeat
  jl .LalignmentLoop

  # SSE start
  mov %rdi, %rax # save str ptr in rax
  add %rcx, %rdi # advance str ptr by the amount needed 
  xor %rcx, %rcx
  pxor %xmm0, %xmm0 # initiate the "compare" value to \0
.Lloop:
  movdqa (%rdi), %xmm1 # load the next 16 bytes (alignment required. This should be because of the earlier code)
  pcmpistri $0x08, %xmm0, %xmm1 # extract first index that is equal into 
  jc .Lfound
  add $16, %rdi # advance by 16
  jmp .Lloop
.Lfound:
  add %rcx, %rdi # add index to get end ptr
  sub %rax, %rdi # end - start to get size
  mov %rdi, %rax # return size
.Lexit:
  ret

