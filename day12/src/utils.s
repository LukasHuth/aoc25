.global utils_panic
.global utils_print
.global utils_eprint
.global utils_exit
.global utils_init_heap
.global utils_free_heap
.global utils_malloc
.global utils_stoi

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
