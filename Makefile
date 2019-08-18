
# Perform dependency tracking on all source files in root folder
SRCS := $(wildcard *.s)

# intermediate directory for generated object files
OBJDIR := .o
# intermediate directory for generated dependency files
DEPDIR := .d
# intermediate directory for executables
BINDIR := bin
# intermediate directory for test results
TESTDIR := junit

# object files, auto generated from source files
OBJS := $(patsubst %,$(OBJDIR)/%.o,$(basename $(SRCS)))
# dependency files, auto generated from source files
DEPS := $(patsubst %,$(DEPDIR)/%.d,$(basename $(SRCS)))

# Implicit rule for assembling individual assembly source files

$(OBJDIR)/%.o : %.s $(DEPDIR)/%.d | $(DEPDIR) $(OBJDIR)
	# Generate dependency information
	echo "$@ : $(shell vasmm68k_mot -quiet -depend=make $<)" > $(DEPDIR)/$*.d
	echo "$(shell vasmm68k_mot -quiet -depend=make $<):" >> $(DEPDIR)/$*.d

	# Assemble file
	vasmm68k_mot -quiet -Fhunk -o $@ $<

# Default rule

all : test

# Clean all intermediates

.PHONY: clean
clean:
	$(RM) -r $(OBJDIR) $(DEPDIR) $(BINDIR)

# Link executables and run tests

test : $(BINDIR)/test_DecodeBitStream_3Bits.exe

$(BINDIR)/test_DecodeBitStream_3Bits.exe : $(OBJDIR)/test_DecodeBitStream_3Bits.o $(OBJDIR)/DecodeBitStream_3Bits.o | $(BINDIR)
	# Link executable
	vlink -bamigahunk -o $@ $^

	# Run tests
	testrunner-68k --junit $(TESTDIR)/test_DecodeBitStream_3Bits.xml $(BINDIR)/test_DecodeBitStream_3Bits.exe

# Rules for creating intermediate folders, when necessary

$(DEPDIR): ; @mkdir -p $@
$(OBJDIR): ; @mkdir -p $@
$(BINDIR): ; @mkdir -p $@
$(TESTDIR): ; @mkdir -p $@

# Dependency handling

DEPS := $(SRCS:%.s=$(DEPDIR)/%.d)
$(DEPS):

include $(wildcard $(DEPS))
