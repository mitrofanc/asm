AS = /usr/bin/nasm
LD = /usr/bin/ld

ASFLAGS = -g -f elf64
LDFLAGS = -static

SRCS = lab2.s
OBJS = $(SRCS:.s=.o)

EXE = lab2

# Переменная ASCED определяет сортировку по возрастанию или убыванию
# Если не передано, то сортировка по возрастанию
ASC ?= 0  # 0 - по возрастанию, 1 - по убыванию

all: $(EXE)

$(EXE): $(OBJS)
	$(LD) $(LDFLAGS) $(OBJS) -o $@

$(OBJS): $(SRCS)
	$(AS) $(ASFLAGS) -DASC=$(ASC) $< -o $@

clean:
	rm -rf $(EXE) $(OBJS)
