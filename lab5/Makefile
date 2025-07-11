CC      := gcc
NASM    := nasm

CFLAGS_BASE := -std=c17 -Wall -Wextra -pedantic -O0
LDFLAGS     := -lpng -lz

SRC_MAIN := inv.c
OBJ_MAIN := inv.o

SRC_C := invert_c.c
OBJ_C := invert_c.o

ASM_SRC := invert_colors.s
ASM_OBJ := invert_colors.o

TARGET   := invert

.PHONY: all bench_c bench_nasm clean

all: bench_c bench_nasm

bench_c: bench_c_O0 bench_c_O1 bench_c_O2 bench_c_O3 bench_c_Ofast

bench_c_O0: CFLAGS := -std=c17 -Wall -Wextra -pedantic -O0
bench_c_O0:
	@echo "===== C -O0 ====="
	@rm -f $(OBJ_MAIN) $(OBJ_C) $(TARGET)
	@$(CC) $(CFLAGS) -c inv.c    -o $(OBJ_MAIN)
	@$(CC) $(CFLAGS) -c invert_c.c -o $(OBJ_C)
	@$(CC) $(CFLAGS) $(OBJ_MAIN) $(OBJ_C) -o $(TARGET) $(LDFLAGS)
	@./$(TARGET) $(INPUT_IMG) $(OUTPUT_IMG)

bench_c_O1: CFLAGS := -std=c17 -Wall -Wextra -pedantic -O1
bench_c_O1:
	@echo "===== C -O1 ====="
	@rm -f $(OBJ_MAIN) $(OBJ_C) $(TARGET)
	@$(CC) $(CFLAGS) -c inv.c    -o $(OBJ_MAIN)
	@$(CC) $(CFLAGS) -c invert_c.c -o $(OBJ_C)
	@$(CC) $(CFLAGS) $(OBJ_MAIN) $(OBJ_C) -o $(TARGET) $(LDFLAGS)
	@./$(TARGET) $(INPUT_IMG) $(OUTPUT_IMG)

bench_c_O2: CFLAGS := -std=c17 -Wall -Wextra -pedantic -O2
bench_c_O2:
	@echo "===== C -O2 ====="
	@rm -f $(OBJ_MAIN) $(OBJ_C) $(TARGET)
	@$(CC) $(CFLAGS) -c inv.c    -o $(OBJ_MAIN)
	@$(CC) $(CFLAGS) -c invert_c.c -o $(OBJ_C)
	@$(CC) $(CFLAGS) $(OBJ_MAIN) $(OBJ_C) -o $(TARGET) $(LDFLAGS)
	@./$(TARGET) $(INPUT_IMG) $(OUTPUT_IMG)

bench_c_O3: CFLAGS := -std=c17 -Wall -Wextra -pedantic -O3
bench_c_O3:
	@echo "===== C -O3 ====="
	@rm -f $(OBJ_MAIN) $(OBJ_C) $(TARGET)
	@$(CC) $(CFLAGS) -c inv.c    -o $(OBJ_MAIN)
	@$(CC) $(CFLAGS) -c invert_c.c -o $(OBJ_C)
	@$(CC) $(CFLAGS) $(OBJ_MAIN) $(OBJ_C) -o $(TARGET) $(LDFLAGS)
	@./$(TARGET) $(INPUT_IMG) $(OUTPUT_IMG)

bench_c_Ofast: CFLAGS := -std=c17 -Wall -Wextra -pedantic -Ofast
bench_c_Ofast:
	@echo "===== C -Ofast ====="
	@rm -f $(OBJ_MAIN) $(OBJ_C) $(TARGET)
	@$(CC) $(CFLAGS) -c inv.c    -o $(OBJ_MAIN)
	@$(CC) $(CFLAGS) -c invert_c.c -o $(OBJ_C)
	@$(CC) $(CFLAGS) $(OBJ_MAIN) $(OBJ_C) -o $(TARGET) $(LDFLAGS)
	@./$(TARGET) $(INPUT_IMG) $(OUTPUT_IMG)

bench_nasm:
	@echo "===== NASM (C -O0 + USE_NASM) ====="
	@rm -f $(OBJ_MAIN) $(OBJ_C) $(ASM_OBJ) $(TARGET)
	@$(CC) -DUSE_NASM $(CFLAGS_BASE) -c inv.c      -o $(OBJ_MAIN)
	@$(NASM) -f elf64 $(ASM_SRC) -o $(ASM_OBJ)
	@$(CC) $(CFLAGS_BASE) $(OBJ_MAIN) $(ASM_OBJ) -o $(TARGET) $(LDFLAGS)
	@./$(TARGET) $(INPUT_IMG) $(OUTPUT_IMG)

clean:
	rm -f $(OBJ_MAIN) $(OBJ_C) $(ASM_OBJ) $(TARGET)

