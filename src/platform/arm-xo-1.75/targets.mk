# Makefile fragment for the final target application

# This generic version is quite abbreviated, assuming nothing about
# the CPU or the I/O system.  A typical real version would include
# various object files, some from appropriate src/cpu/* directories
# and some from the platform-specific directory (src/platform/*).


DUMPFLAGS = --disassemble-all -z -x

VPATH += $(SRC)/cpu/arm $(SRC)/platform/arm-xo-1.75 $(SRC)/lib
# VPATH += $(SRC)/cpu/<whatever> $(SRC)/platform/<whatever>
# INC += -I$(SRC)/cpu/<whatever> -I$(SRC)/platform/<whatever>

# Platform-specific object files for low-level startup and platform I/O
# Add more as needed

PLAT_OBJS = start.o


# Object files for the Forth system and application-specific extensions

# FORTH_OBJS = tmain.o embed.o textend.o  spiread.o consoleio.o
FORTH_OBJS = tmain.o embed.o textend.o  spiread-simpler.o consoleio.o inflate.o

SHIM_OBJS = shimmain.o spiread.o

# Recipe for linking the final image

RAMBASE  = 0xd1000000
RAMTOP   = 0xd1020000
SHIMBASE = 0xd1018000

TSFLAGS += -DRAMTOP=${RAMTOP}

LIBGCC= -lgcc

app.elf: $(PLAT_OBJS) $(FORTH_OBJS)
	@echo Linking $@ ... 
	$(TLD) -N  -o $@  $(TLFLAGS) -Ttext $(RAMBASE) \
	    $(PLAT_OBJS) $(FORTH_OBJS) \
	    $(LIBDIRS) $(LIBGCC) -lc
	@$(TOBJDUMP) $(DUMPFLAGS) $@ >$(@:.elf=.dump)
	@nm -n $@ >$(@:.elf=.nm)

shim.elf: $(PLAT_OBJS) $(SHIM_OBJS)
	@echo Linking $@ ... 
	$(TLD) -N  -o $@  $(TLFLAGS) -Ttext $(SHIMBASE) \
	    $(PLAT_OBJS) $(SHIM_OBJS) \
	    $(LIBDIRS) $(LIBGCC) -lc
	@$(TOBJDUMP) $(DUMPFLAGS) $@ >$(@:.elf=.dump)
	@nm -n $@ >$(@:.elf=.nm)


# This rule extracts the executable bits from an ELF file, yielding raw binary.

%.img: %.elf
	@$(TOBJCOPY) -O binary $< $@
	date  "+%F %H:%M" >>$@
	@ls -l $@

# This rule builds a date stamp object that you can include in the image
# if you wish.

.PHONY: date.o

date.o:
	echo 'const char version[] = "'`cat version`'" ;' >date.c
	echo 'const char build_date[] = "'`date  --iso-8601=minutes`'" ;' >>date.c
	echo "const unsigned char sw_version[] = {" `cut -d . --output-delimiter=, -f 1,2 version` "};" >>date.c
	$(TCC) -c date.c -o $@

EXTRA_CLEAN += *.elf *.dump *.nm *.img date.c $(FORTH_OBJS) $(PLAT_OBJS)
