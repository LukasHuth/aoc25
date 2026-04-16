.global utils_panic
.global utils_print
.global utils_eprint
.global utils_exit
.global utils_init_heap
.global utils_free_heap
.global utils_malloc
.global utils_stoi
.global utils_cleanup

.extern string_utility_strlen

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
# rsi = exit code
#------------------------------------------------------------------------------
utils_panic:
  # save exit code
  push %rsi
  call utils_eprint
  pop %rdi
  call utils_exit
  ret

#------------------------------------------------------------------------------
# EPrint - Prints a message on stderr
#------------------------------------------------------------------------------
# Arguments:
# rdi = message
#------------------------------------------------------------------------------
# Constants:
# STDERR = 2
#------------------------------------------------------------------------------
utils_eprint:
  mov $2, %rsi
  call _utils_print
  ret

#------------------------------------------------------------------------------
# Print - Prints a message on stdout
#------------------------------------------------------------------------------
# Arguments:
# rdi = message
#------------------------------------------------------------------------------
# Constants:
# STDOUT = 1
#------------------------------------------------------------------------------
utils_print:
  mov $1, %rsi
  call _utils_print
  ret

#------------------------------------------------------------------------------
# Internal Print - Prints a message on stdout
#------------------------------------------------------------------------------
# Arguments:
# rdi = message
# rsi = fd
#------------------------------------------------------------------------------
# Constants:
# SYSCALL WRITE = 1
#------------------------------------------------------------------------------
_utils_print:
  push %rdi
  push %rsi
  call string_utility_strlen
  mov %rax, %rdx # rdx message length
  pop %rdi # rdi = fd
  pop %rsi # rsi = message

  mov $1, %rax
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
  ret

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
  push %rbp
  mov %rsp, %rbp
  test %rdi, %rdi
  jz 2f
  push %rdi
  sub $8, %rsp
  call string_utility_strlen
  mov %rax, %rsi
  add $8, %rsp
  pop %rdi
  xor %rax, %rax
  xor %r8, %r8
  xor %r9, %r9
  1:
  movzbq (%rdi, %r8, 1), %r9
  subb $'0', %r9b
  test %r9b, %r9b
  js 2f
  cmp $9, %r9b
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
  leave
  ret

# rdi = char** arr
# rsi = long amount
utils_cleanup:
  push %rbp
  mov %rsp, %rbp
  test %rdi, %rdi # if !arr
  jz 2f # return
  sub $8, %rsp
  push %r12
  
  mov %rsi, %r12
  mov %rdi, -8(%rbp)

  1:
  test %r12, %r12
  jz 1f

  mov -8(%rbp), %rdi
  mov -8(%rdi, %r12, 8), %rdi
  call free # free(arr[amount - i - 1])

  dec %r12
  jmp 1b
  1:

  mov -8(%rbp), %rdi
  call free # free(arr)

  pop %r12
  add $8, %rsp
  2:
  leave
  ret
