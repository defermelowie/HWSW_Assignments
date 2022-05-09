# Makefile

RISCV_GNU_TOOLCHAIN_GIT_REVISION = 411d134
RISCV_GNU_TOOLCHAIN_INSTALL_PREFIX = /home/ldefe/.programs/riscv
TOOLCHAIN_PREFIX = $(RISCV_GNU_TOOLCHAIN_INSTALL_PREFIX)/bin/riscv32-unknown-elf-
#TOOLCHAIN_PREFIX = riscv32-unknown-elf-

PYTHON = /usr/bin/python3

# GCC_WARNS  = -Werror -Wall -Wextra -Wshadow -Wundef -Wpointer-arith -Wcast-qual -Wcast-align -Wwrite-strings
# GCC_WARNS += -Wredundant-decls -Wstrict-prototypes -Wmissing-prototypes -pedantic # -Wconversion
GCC_ARGS = -mcmodel=medlow

COMPRESSED_ISA = m

CFLAGS  = -Wall -Os -o0 --std=c99 -ffreestanding -nostdlib
LDFLAGS = --std=gnu99 -Wl,-Bstatic,-T,firmware.lds,-Map,$(TARGETDIR)/firmware.map,--strip-debug -lgcc
ARCHITECTURE = rv32i$(subst C,c,$(COMPRESSED_ISA))

BUILDDIR = build
SOURCEDIR = src
TOOLSDIR = /mnt/c/Users/ldefe/Documents/IIW/HW_SW_Codesign/exercises/tools
TARGETDIR = target

SOURCES = $(wildcard $(SOURCEDIR)/*.c)
SOURCES_A = $(wildcard $(SOURCEDIR)/*.S)
OBJECTS = $(patsubst $(SOURCEDIR)/%.c, $(BUILDDIR)/%.o, $(SOURCES))
OBJECTS_A = $(patsubst $(SOURCEDIR)/%.S, $(BUILDDIR)/%.o, $(SOURCES_A))

BINARY = firmware.elf

RM = rm -rf
MKDIR = mkdir

.PHONY: all clean sizes setup

################################################################################

all: firmware.hex firmware.objdump

################################################################################

%.objdump: %.elf
	$(TOOLCHAIN_PREFIX)objdump -D $(TARGETDIR)/$< > $(TARGETDIR)/$@

%.bin: %.elf
	$(TOOLCHAIN_PREFIX)objcopy -O binary $(TARGETDIR)/$< $(TARGETDIR)/$@

%.hex: %.bin
	$(PYTHON) $(TOOLSDIR)/makehex.py $(TARGETDIR)/$^ 8196 > $(TARGETDIR)/$@

# LINKING ######################################################################
$(BINARY): $(OBJECTS) $(OBJECTS_A)
	$(TOOLCHAIN_PREFIX)gcc -ffreestanding -nostdlib -o $(TARGETDIR)/$@ $^ $(GCC_ARGS) $(LDFLAGS)

# COMPILING ####################################################################
$(BUILDDIR)/%.o: $(SOURCEDIR)/%.c
	$(TOOLCHAIN_PREFIX)gcc -c -march=$(ARCHITECTURE) $(CFLAGS) $(GCC_WARNS) -o $@ $<

# MAIN STRUCTURE
$(BUILDDIR)/start.o: $(SOURCEDIR)/start.S
	$(TOOLCHAIN_PREFIX)gcc -c -march=$(ARCHITECTURE) $(CFLAGS)  $(GCC_WARNS) -o $@ $<


################################################################################

sizes: $(TARGETDIR)/firmware.elf
	$(TOOLCHAIN_PREFIX)size $^

setup:
	$(MKDIR) -p $(BUILDDIR)

clean:
	$(RM) $(TARGETDIR)/firmware*.elf $(TARGETDIR)/firmware*.bin $(TARGETDIR)/firmware*.hex $(TARGETDIR)/firmware*.map $(TARGETDIR)/firmware*.objdump
	$(RM) $(BINARY) $(OBJECTS) $(OBJECTS_A)
