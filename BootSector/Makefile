NASM ?= nasm
MKDIR ?= mkdir
RM ?= /bin/rm

BINDIR=bin
PRODUCTS32=$(BINDIR)/StartIA32.com $(BINDIR)/EfiIA32.com
PRODUCTS64=$(BINDIR)/StartX64.com $(BINDIR)/EfiX64.com

all: $(PRODUCTS32) $(PRODUCTS64)

clean:
	$(RM) -f $(PRODUCTS32) $(PRODUCTS64)

$(BINDIR)/StartIA32.com: start.nasm
	@$(MKDIR) -p bin
	$(NASM) -f bin -o $@ $<

$(BINDIR)/EfiIA32.com: efi32.nasm
	@$(MKDIR) -p bin
	$(NASM) -f bin -o $@ $<

$(BINDIR)/StartX64.com: start.nasm
	@$(MKDIR) -p bin
	$(NASM) -DX64 -DUSE_LOW_EBDA -f bin -o $@ $<

$(BINDIR)/EfiX64.com: efi64.nasm
	@$(MKDIR) -p bin
	$(NASM) -f bin -o $@ $<
