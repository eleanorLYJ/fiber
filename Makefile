TESTS = \
	sem \
	mutex \
	cond
TESTS := $(addprefix tests/test-,$(TESTS))
deps := $(TESTS:%=%.o.d)

.PHONY: all check clean
all: $(TESTS)

include common.mk

CFLAGS = -I./include
CFLAGS += -std=gnu99 -Wall -W
LDFLAGS = -lpthread

TESTS_OK = $(TESTS:=.ok)
check: $(TESTS_OK)

$(TESTS_OK): %.ok: %
	$(Q)$(PRINTF) "*** Validating $< ***\n"
	$(Q)./$< && $(PRINTF) "\t$(PASS_COLOR)[ Verified ]$(NO_COLOR)\n"
	@touch $@

# standard build rules
.SUFFIXES: .o .c
.c.o:
	$(VECHO) "  CC\t$@\n"
	$(Q)$(CC) -o $@ $(CFLAGS) -c -MMD -MF $@.d $<

OBJS = \
       src/fiber.o \
       src/sem.o \
       src/mutex.o \
       src/cond.o
deps += $(OBJS:%.o=%.o.d)

$(TESTS): %: %.o $(OBJS)
	$(VECHO) "  LD\t$@\n"
	$(Q)$(CC) -o $@ $^ $(LDFLAGS)

clean:
	$(VECHO) "  Cleaning...\n"
	$(Q)$(RM) $(TESTS) $(TESTS_OK) $(TESTS:=.o) $(OBJS) $(deps)

-include $(deps)