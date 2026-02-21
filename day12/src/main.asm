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
  push rbp
  mov rbp, rsp
  sub rsp, 16

  lea rdi, [rel filename]
  mov rsi, filename_len
  call file_utility_read_file
  mov rcx, [rax]
  mov [rbp - 8], rcx
  mov rcx, [rax + 8]
  mov [rbp - 16], rcx

  mov rdi, [rbp - 8]
  mov rsi, [rbp - 16]
  call utils_print

  mov rdi, [rbp - 8]
  mov rsi, [rbp - 16]
  call file_utility_free_file_content

  mov rdi, 0
  call utils_exit
