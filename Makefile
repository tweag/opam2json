all: opam2json opam2json.1

PACKAGES = cmdliner opam-file-format yojson

COMP ?= ocamlopt

PREFIX ?= /usr/local

opam2json: src/opam2json.ml
	ocamlfind $(COMP) $(patsubst %,-package %,$(PACKAGES)) -linkpkg $^ -o $@

opam2json.1: opam2json
	./$< --help=groff >$@

install: opam2json opam2json.1 opam2json.install
	opam-installer --prefix=$(PREFIX) opam2json.install

clean:
	rm -f src/*.cm* src/*.o

distclean: clean
	rm -f opam2json opam2json.1 opam2json.install
