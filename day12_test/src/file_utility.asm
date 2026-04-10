global file_utility_read_file
global file_utility_free_file_content

section .data
OPEN_FILE_FAILED db "Failed to open file", 10, 0
OPEN_FILE_FAILED_LEN equ $ - OPEN_FILE_FAILED
STAT_FILE_FAILED db "Failed to stat file", 10, 0
STAT_FILE_FAILED_LEN equ $ - STAT_FILE_FAILED
READ_FILE_FAILED db "Failed to read file", 10, 0
READ_FILE_FAILED_LEN equ $ - READ_FILE_FAILED
FREE_FILE_FAILED db "Failed to free file", 10, 0
FREE_FILE_FAILED_LEN equ $ - FREE_FILE_FAILED
CLOSE_FILE_FAILED db "Failed to close file", 10, 0
CLOSE_FILE_FAILED_LEN equ $ - CLOSE_FILE_FAILED
RETURN_DATA dq 0, 0

section .text
extern utils_panic

;------------------------------------------------------------------------------
; Read File - Read a file by its name
;------------------------------------------------------------------------------
; Arguments:
; rdi = filename
; rsi = filename length
;------------------------------------------------------------------------------
; Returns: an pointer to an array, first element is the pointer to the data,
;         the second element is the size of the string
; [rax] = string
; [rax + 8] = string length
;------------------------------------------------------------------------------
file_utility_read_file:
  call _open_file
  mov r15, rax ; save fd
  mov rdi, rax
  call _get_filesize
  lea rdx, [rel RETURN_DATA + 8]
  mov [rdx], rax ; store data in [RETURN_DATA + 8]
  mov rdi, r15 ; load fd from stack
  mov rsi, rax ; load file size as 2nd arg
  call _mmap_file
  lea rdx, [rel RETURN_DATA] ; load return data addr
  mov [rdx], rax ; store data in [RETURN_DATA]
  mov rdi, r15 ; restore fd
  call _close_file
  lea rax, [rel RETURN_DATA] ; return ptr to data (ik not best solution)
  ret

;------------------------------------------------------------------------------
; Free File Content - Frees the mmap'ed file content
;------------------------------------------------------------------------------
; Arguments:
; rdi = data ptr
; rsi = data length
;------------------------------------------------------------------------------
; Returns: Nothing
;------------------------------------------------------------------------------
; Constants:
; SYSCALL MUNMAP = 11
;------------------------------------------------------------------------------
file_utility_free_file_content:
  mov rax, 11 ; SYSCALL MUNMAP
  syscall
  cmp rax, 0
  jge .success

  lea rdi, [rel FREE_FILE_FAILED]
  mov rsi, FREE_FILE_FAILED_LEN
  mov rdx, rax
  neg rdx
  call utils_panic ; never returns

  .success:
  ret
  
;------------------------------------------------------------------------------
; Open File - Open a file by its name
;------------------------------------------------------------------------------
; Arguments:
; rdi = filename
; rsi = filename length
;------------------------------------------------------------------------------
; Returns: The opened fd
;------------------------------------------------------------------------------
; Panics: On open failure
;------------------------------------------------------------------------------
; Constants:
; SYSCALL OPEN = 2
; O_RDONLY = 0
;------------------------------------------------------------------------------
_open_file:
  mov rax, 2 ; SYSCALL OPEN
  mov rsi, 0 ; O_RDONLY
  xor rdx, rdx
  syscall
  test rax, rax
  jns .success

  lea rdi, [rel OPEN_FILE_FAILED]
  mov rsi, OPEN_FILE_FAILED_LEN
  mov rdx, rax
  call utils_panic ; never returns

  .success:
  ret

;------------------------------------------------------------------------------
; Close File - Close a file discriptor
;------------------------------------------------------------------------------
; Arguments:
; rdi = fd
;------------------------------------------------------------------------------
; Panics: On close failure
;------------------------------------------------------------------------------
; Constants:
; SYSCALL CLOSE = 3
;------------------------------------------------------------------------------
_close_file:
  mov rax, 3 ; SYSCALL CLOSE
  syscall
  cmp rax, 0
  jge .success

  lea rdi, [rel CLOSE_FILE_FAILED]
  mov rsi, CLOSE_FILE_FAILED_LEN
  mov rdx, 4
  call utils_panic ; never returns

  .success:
  ret

;------------------------------------------------------------------------------
; Get Filesize - Uses stat to get the size of a file with its fd
;------------------------------------------------------------------------------
; Arguments:
; rdi = fd
;------------------------------------------------------------------------------
; Returns: The size of the file in bytes
;------------------------------------------------------------------------------
; Panics: When fstat fails
;------------------------------------------------------------------------------
; Constants:
; STAT SIZE = 144
; FILE SIZE OFFSET = 48
; SYSCALL FSTAT = 5
;------------------------------------------------------------------------------
_get_filesize:
  push rbp
  mov rbp, rsp

  sub rsp, 144 ; STAT SIZE
  ; rdi is already fd
  mov rsi, rsp
  mov rax, 5 ; SYSCALL FSTAT
  syscall
  cmp rax, 0
  jge .success

  lea rdi, [rel STAT_FILE_FAILED]
  mov rsi, STAT_FILE_FAILED_LEN
  mov rdx, 2
  call utils_panic ; never returns

  .success:
  mov rax, [rsi + 48] ; FILE SIZE OFFSET

  leave
  ret

;------------------------------------------------------------------------------
; MMAP File - Maps a file with its fd into memory
;------------------------------------------------------------------------------
; Arguments:
; rdi = fd
; rsi = file_size
;------------------------------------------------------------------------------
; returns an memory pointer to the file content
;------------------------------------------------------------------------------
; Panics: When mmap syscall fails
;------------------------------------------------------------------------------
; Constants:
; PROT READ = 1
; PRIVATE = 2
; SYSCALL MMAP = 9
;------------------------------------------------------------------------------
_mmap_file:
  mov r8, rdi
  mov rdi, 0 ; addr
  mov rdx, 1 ; PROT READ
  mov r10, 2 ; PRIVATE
  mov r9, 0 ; offset
  mov rax, 9 ; SYSCALL MMAP
  syscall
  cmp rax, 0
  jge .success

  lea rdi, [rel READ_FILE_FAILED]
  mov rsi, READ_FILE_FAILED_LEN
  mov rdx, rax
  neg rdx
  call utils_panic ; never returns

  .success:
  ret
