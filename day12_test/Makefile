# Directories
SRC_DIR := src
OUT_DIR := out

# Tools
AS_NASM := nasm
AS_GAS := as
LD := ld

# Flags
ASFLAGS_NASM := -f elf64
ASFLAGS_GAS := --64
LDFLAGS := -m elf_x86_64

TARGET := $(OUT_DIR)/day12

SOURCES := $(wildcard $(SRC_DIR)/*.s) $(wildcard $(SRC_DIR)/*.asm)

OBJECTS := $(patsubst $(SRC_DIR)/%.s,$(OUT_DIR)/%.o,$(filter %.s,$(SOURCES))) \
					 $(patsubst $(SRC_DIR)/%.asm,$(OUT_DIR)/%.o,$(filter %.asm,$(SOURCES)))

add: $(TARGET)

$(TARGET): $(OBJECTS)
	@mkdir -p $(OUT_DIR)
	$(LD) $(LDFLAGS) $^ -o $@

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
