global _start

section .data
filename db "input.txt", 0
filename_len equ $ - filename

section .text
extern utils_print
extern utils_exit
extern file_utility_read_file
extern file_utility_free_file_content
extern utils_init_heap
extern utils_free_heap
extern utils_malloc

%define argv_reg r15
%define old_rbp_reg r14
%define argc_reg r12

_start:
  mov rdi, rsp
  push rbp
  mov rbp, rsp
  
  push rdi
  mov rdi, 128
  call utils_init_heap
  pop old_rbp_reg
  
  sub rsp, 16
  mov r12, [old_rbp_reg]
  mov [rbp - 8], r12
  lea rdi, [r12 * 8]
  call utils_malloc
  mov argv_reg, rax
  mov [rbp - 16], rax

  xor rcx, rcx
  mov argc_reg, [old_rbp_reg]
  test argc_reg, argc_reg
  jz .argv_loop_end
  .argv_loop:
  add old_rbp_reg, 8
  mov r11, [old_rbp_reg]
  mov [argv_reg + rcx * 8], r11
  inc rcx
  cmp argc_reg, rcx
  jge .argv_loop
  .argv_loop_end:
  
  mov rdi, [rbp - 16]
  mov rdi, [rdi + 8]
  mov rsi, 5
  call utils_print

  lea rdi, [rel filename]
  mov rsi, filename_len
  call file_utility_read_file
  mov rcx, [rax]
  sub rsp, 16
  mov [rbp - 24], rcx
  mov rcx, [rax + 8]
  mov [rbp - 32], rcx

  mov rdi, [rbp - 24]
  mov rsi, [rbp - 32]
  call utils_print

  mov rdi, [rbp - 24]
  mov rsi, [rbp - 32]
  call file_utility_free_file_content

  call utils_free_heap

  mov rdi, 0
  call utils_exit
