global _start

section .data
filename db "input.txt", 0
filename_len equ $ - filename

section .text
extern utils_print
extern utils_exit
extern file_utility_read_file
extern file_utility_free_file_content

_start:
  lea rdi, [rel filename]
  mov rsi, filename_len
  call file_utility_read_file
  push [rax]
  push [rax + 8]

  mov rdi, [rsp]
  mov rdi, [rsp + 8]
  call utils_print

  mov rdi, [rsp]
  mov rsi, [rsp + 8]
  call file_utility_free_file_content

  mov rdi, 0
  call utils_exit
