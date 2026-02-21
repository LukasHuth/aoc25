.global utils_panic
.global utils_print
.global utils_eprint
.global utils_exit

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
