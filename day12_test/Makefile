# Directories
SRC_DIR := src
OUT_DIR := out

# Tools
CC := gcc
AS_NASM := nasm
AS_GAS := as

# Flags
CFLAGS := -g -Wall -Wextra -no-pie -Wl,-z,noexecstack
ASFLAGS_NASM := -f elf64
ASFLAGS_GAS := --64

TARGET := $(OUT_DIR)/day12

C_SOURCES   := $(wildcard $(SRC_DIR)/*.c)
ASM_SOURCES := $(wildcard $(SRC_DIR)/*.s) $(wildcard $(SRC_DIR)/*.asm)

C_OBJECTS   := $(patsubst $(SRC_DIR)/%.c,$(OUT_DIR)/%.o,$(C_SOURCES))
ASM_OBJECTS := $(patsubst $(SRC_DIR)/%.s,$(OUT_DIR)/%.o,$(filter %.s,$(ASM_SOURCES))) \
               $(patsubst $(SRC_DIR)/%.asm,$(OUT_DIR)/%.o,$(filter %.asm,$(ASM_SOURCES)))

OBJECTS := $(C_OBJECTS) $(ASM_OBJECTS)

all: $(TARGET)

$(TARGET): $(OBJECTS)
	@mkdir -p $(OUT_DIR)
	$(CC) $(CFLAGS) $^ -o $@

$(OUT_DIR)/%.o: $(SRC_DIR)/%.c
	@mkdir -p $(OUT_DIR)
	$(CC) $(CFLAGS) -c $< -o $@

$(OUT_DIR)/%.o: $(SRC_DIR)/%.s
	@mkdir -p $(OUT_DIR)
	$(AS_GAS) $(ASFLAGS_GAS) $< -o $@

$(OUT_DIR)/%.o: $(SRC_DIR)/%.asm
	@mkdir -p $(OUT_DIR)
	$(AS_NASM) $(ASFLAGS_NASM) $< -o $@

PREFIX ?= /usr/local
BINDIR := $(PREFIX)/bin

install: $(TARGET)
	install -d $(DESTDIR)$(BINDIR)
	install -m 0755 $(TARGET) $(DESTDIR)$(BINDIR)

clean:
	rm -rf $(OUT_DIR)

.PHONY: all install clean
