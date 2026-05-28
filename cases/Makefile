
# Directories
SRC_DIR := src
OBJ_DIR := obj

CC      := riscv64-unknown-elf-gcc
AS      := riscv64-unknown-elf-as
LD      := riscv64-unknown-elf-ld
OBJCOPY := riscv64-unknown-elf-objcopy

ASFLAGS       := -march=rv32i -mabi=ilp32
LDFLAGS       := -m elf32lriscv -T ./korev.ld
OBJCOPYFLAGS  := -O verilog

SRCS  := $(wildcard $(SRC_DIR)/*.s)
VHXS  := $(patsubst $(SRC_DIR)/%.s, $(OBJ_DIR)/%.vhx, $(SRCS))

all: $(VHXS)

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.s
	@mkdir -p $(OBJ_DIR)
	$(AS) $(ASFLAGS) -o $@ $<

$(OBJ_DIR)/%.elf: $(OBJ_DIR)/%.o
	$(LD) $(LDFLAGS) -o $@ $<

$(OBJ_DIR)/%.vhx: $(OBJ_DIR)/%.elf
	$(OBJCOPY) $(OBJCOPYFLAGS) $< $@

clean:
	rm -rf $(OBJ_DIR)

.PHONY: all clean
