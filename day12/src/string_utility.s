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
  mov -8(%rbp), %rsi # load str
  mov %rdi, %r10 # load end
  sub %rsi, %r10 # (end - start) = checked_len
  add $15, %r10
  cmp %r9, %r10 # strlen <= checked_len + 15; end loop
  jge .LcountLoopEnd
  movzx %al, %rax # clear upper bytes
  pxor %xmm1, %xmm1
  movd %eax, %xmm1 # load esi into xmm1
  pxor %xmm2, %xmm2
  pshufb %xmm2, %xmm1 # use the indices in xmm2 to shuffle xmm1, eferything is 0 in xmm2 therefore everything in xmm1 = xmm1[0]

.LcountLoop:
  movdqu (%rdi), %xmm0 # load first 16 bytes
  pcmpistrm $00, %xmm0, %xmm1 # strcmp bytes with equ any and store mask in xmm0
  jnc .LcountLoopCheck # c is on when hit, if nothing is hit, just check whether we reached the string end
  xor %r8, %r8
  movq %xmm0, %r8
  # pmovmskb %xmm0, %r8d # load the mask from xmm0 into r8
  popcnt %r8d, %r8d # count active bits and store in r8
  add %r8, %rcx # add counted bits to the counter
.LcountLoopCheck:
  add $16, %rdi
  mov %rdi, %r10 # load end
  sub %rsi, %r10 # (end - start) = checked_len
  add $15, %r10
  cmp %r9, %r10 # strlen <= checked_len + 15; end loop
  jge .LcountLoopEnd
  jmp .LcountLoop
.LcountLoopEnd:

  mov %rdi, %r10 # load end
  sub %rsi, %r10 # (end - start) = checked_len
  sub %r10, %r9 # missing bytes
  test %r9, %r9
  jz .LtailCountLoopEnd # if missing bytes is 0 end
.LtailCountLoop: # order doesn't matter
  movzbq (%rdi, %r9, 1), %rdx # load char at str[r10] -> rdx
  cmp %dl, %al
  jne .LtailCountLoopCheck # if not delimier repeat loop if neccesarry
  inc %rcx
.LtailCountLoopCheck:
  dec %r9
  test %r9, %r9
  js .LtailCountLoopEnd # if missing bytes is 0 end
  jmp .LtailCountLoop
.LtailCountLoopEnd:
  
  # AVX-512 alternative
  # r10 = missing bytes
  # r9 = (1 << missingbytes) - 1
  # kmovw %r9w, %k1
  # vmovdqu8 (%rdi), %xmm0{%k1}{z}

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

