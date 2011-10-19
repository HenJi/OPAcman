EXE = opacman.exe

all: $(EXE)

$(EXE): src/*.opa #resources/*
	opa src/*.opa -o $(EXE)

clean:
	rm -Rf *.exe _build _tracks *.log **/#*#
