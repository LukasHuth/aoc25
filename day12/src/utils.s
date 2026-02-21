.global utils_panic
.global utils_print
.global utils_eprint
.global utils_exit
.global utils_init_heap
.global utils_free_heap
.global utils_malloc
.global utils_stoi
.global utils_splitstring
.global utils_strlen

.section .data
heap:
  .quad 0
heap_offset:
  .quad 0
heap_size:
  .quad 0
heap_init_failed:
  .asciz "Failed to initialize Heap\n"
heap_init_failed_len = . - heap_init_failed - 1
heap_free_failed:
  .asciz "Failed to free Heap\n"
heap_free_failed_len = . - heap_free_failed - 1
guard_page_creation_failed:
  .asciz "Failed to create a guard page\n"
guard_page_creation_failed_len = . - guard_page_creation_failed - 1
stoi_failed:
  .asciz "Failed to parse number\n"
stoi_failed_len = . - stoi_failed - 1
heap_page_size = 4096

.section .text

#------------------------------------------------------------------------------
# Panic - Prints an error message and exits with specified error message
#------------------------------------------------------------------------------
# Arguments:
# rdi = message
# rsi = message len
# rdx = exit code
#------------------------------------------------------------------------------
utils_panic:
  # save exit code
  push %rdx
  call utils_eprint
  pop %rdi
  call utils_exit

#------------------------------------------------------------------------------
# EPrint - Prints a message on stderr
#------------------------------------------------------------------------------
# Arguments:
# rdi = message
# rsi = message len
#------------------------------------------------------------------------------
# Constants:
# STDERR = 2
#------------------------------------------------------------------------------
utils_eprint:
  mov $2, %rdx
  call _utils_print
  ret

#------------------------------------------------------------------------------
# Print - Prints a message on stdout
#------------------------------------------------------------------------------
# Arguments:
# rdi = message
# rsi = message len
#------------------------------------------------------------------------------
# Constants:
# STDOUT = 1
#------------------------------------------------------------------------------
utils_print:
  mov $1, %rdx
  call _utils_print
  ret

#------------------------------------------------------------------------------
# Internal Print - Prints a message on stdout
#------------------------------------------------------------------------------
# Arguments:
# rdi = message
# rsi = message len
# rdx = fd
#------------------------------------------------------------------------------
# Constants:
# SYSCALL WRITE = 1
#------------------------------------------------------------------------------
_utils_print:
  mov $1, %rax
  xchg %rsi, %rdx # (rsi = message len, rdx = fd) -> (rdx = message len, rsi = fd)
  xchg %rsi, %rdi # (rsi = fd, rdi = message) -> (rsi = message, rdi = fd)
  syscall
  ret

#------------------------------------------------------------------------------
# Exit - Exits the program with a speciified error code
#------------------------------------------------------------------------------
# Arguments:
# rdi = error code
#------------------------------------------------------------------------------
# Constants:
# SYSCALL EXIT = 60
#------------------------------------------------------------------------------
utils_exit:
  mov $60, %rax
  syscall

#------------------------------------------------------------------------------
# Init Heap - Initiates the heap with a Specified size in MB
#------------------------------------------------------------------------------
# Arguments:
# rdi = heap size in MB
#------------------------------------------------------------------------------
# Constants:
# SYSCALL MMAP = 9
# PROT_READ = 1
# PROT_WRITE = 2
# PRIVATE = 2
# ANONYMOUS = 0x20
# to mb size = n * 2^20
#------------------------------------------------------------------------------
utils_init_heap:
  push %rbp
  mov %rsp, %rbp
  test %rdi, %rdi
  jz 2f
  mov %rdi, %rsi # length
  shl $20, %rsi # length to mb
  push %rsi
  mov $0, %rdi # addr
  mov $3, %rdx # PROT_READ | PROT_WRITE
  mov $0x22, %r10 # PRIVATE | ANONYMOUS
  movabs $-1, %r8 # no fd
  mov $0, %r9 # no offset
  mov $9, %rax
  syscall
  test %rax, %rax # test success
  jns 1f

  2:
  lea heap_init_failed(%rip), %rdi
  mov heap_init_failed_len, %rsi
  mov %rax, %rdx
  neg %rdx
  call utils_panic

  1:
  mov %rax, heap(%rip) # save heap ptr
  pop %rax
  mov %rax, heap_size(%rip) # save heap size
  xor %rax, %rax
  mov %rax, heap_offset(%rip) # clear heap offset
  # create guard at start
  call _create_guard
  leave
  ret

#------------------------------------------------------------------------------
# Free Heap - Frees the heap
#------------------------------------------------------------------------------
# Arguments:
#------------------------------------------------------------------------------
# Constants:
# SYSCALL MUNMAP = 11
#------------------------------------------------------------------------------
utils_free_heap:
  mov heap(%rip), %rdi
  mov heap_size(%rip), %rsi
  mov $11, %rax
  syscall
  test %rax, %rax # test success
  jns 1f

  lea heap_free_failed(%rip), %rdi
  mov $heap_free_failed_len, %rsi
  mov %rax, %rdx
  neg %rdx
  call utils_panic

  1:
  ret


#------------------------------------------------------------------------------
# Malloc - Returns an useable are from the heap
#------------------------------------------------------------------------------
# Arguments:
# rdi = requested minimum size
#------------------------------------------------------------------------------
# Info: heap_offset should only be edited by malloc
# Heap is always page aligned since it is from mmap
#------------------------------------------------------------------------------
utils_malloc:
  mov heap(%rip), %rax
  add heap_offset(%rip), %rax
  mov $heap_page_size, %rsi
  neg %rsi
  and %rsi, %rdi
  # size page allignedd
  add $heap_page_size, %rdi
  add %rdi, heap_offset(%rip)
  call _create_guard
  ret

#------------------------------------------------------------------------------
# Create Guard - creates a guard at the current heap position and advances it
#                 by one page
#------------------------------------------------------------------------------
# Arguments
#------------------------------------------------------------------------------
# Constants:
# SYSCALL MPROTECT = 10
# PROT_NONE = 0
#------------------------------------------------------------------------------
# Info: does not change any register
#------------------------------------------------------------------------------
_create_guard:
  push %rax
  push %rdi
  push %rsi
  push %rdx
  mov heap(%rip), %rdi
  add heap_offset(%rip), %rdi
  mov $heap_page_size, %rsi
  mov $0, %rdx # PROT_NONE
  mov $10, %rax # SYSCALL MPROTECT
  syscall
  test %rax, %rax
  jns 1f

  lea guard_page_creation_failed(%rip), %rdi
  mov $guard_page_creation_failed_len, %rsi
  mov %rax, %rdx
  neg %rdx
  call utils_panic

  1:
  addq $heap_page_size, heap_offset(%rip)
  pop %rdx
  pop %rsi
  pop %rdi
  pop %rax
  ret

#------------------------------------------------------------------------------
# stoi - String to Integer
#------------------------------------------------------------------------------
# Arguments:
# rdi = string
# rsi = length
#------------------------------------------------------------------------------
# Returns: The number extracted from the string
#------------------------------------------------------------------------------
# Panics: When string is empty or unknown character is read
#------------------------------------------------------------------------------
utils_stoi:
  test %rsi, %rsi
  jz 2f
  xor %rax, %rax
  xor %r8, %r8
  xor %r9, %r9
  1:
  movzbq (%rdi, %r8, 1), %r9
  subb $'0', %r9b
  test %r9b, %r9b
  js 2f
  cmp %r9b, 9
  jg 2f
  lea (%rax, %rax, 4), %rax # rax *= 5
  lea (%r9, %rax, 2), %rax # rax *= 2 rax += (char - '0')
  inc %r8
  cmp %rsi, %r8
  jl 1b
  jmp 1f
  2:

  lea stoi_failed(%rip), %rdi
  mov $stoi_failed_len, %rsi
  mov %rax, %rdx
  neg %rdx
  call utils_panic

  1:
  ret

#------------------------------------------------------------------------------
# Split String - Splits a string at the specified delimiter
#------------------------------------------------------------------------------
# Arguments:
# rdi = string:0
# rsi = ptr to store the string vector ptr
#------------------------------------------------------------------------------
# Returns: The amount of elements, the string got split into
#------------------------------------------------------------------------------
utils_splitstring:
  push %rbp
  mov %rsp, %rbp
  # TODO: implement with SSE
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
utils_strlen:
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
