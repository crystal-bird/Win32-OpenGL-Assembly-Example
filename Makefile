flags = -g -Wall -m64 -mwindows -nostdlib -e Main -O2
link = -lkernel32 -luser32 -lgdi32 -lopengl32

rwildcard = $(foreach d,$(wildcard $(1:=/*)),$(call rwildcard,$d,$2) $(filter $(subst *,%,$2),$d))

source = $(call rwildcard, ., *.asm)
header = $(call rwildcard, ., *.i)

object = $(source:.asm=.o)

exec = a.exe

run: $(exec)
	./$(exec)

$(exec): $(object)
	gcc $(flags) $^ $(link) -o $@

%.o: %.asm $(header)
	nasm -f win64 -iinclude $< -o $@

clean:
	rm $(object) $(exec)