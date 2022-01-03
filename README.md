# opam2json: convert opam file syntax to JSON

`opam2json` reads files in the [opam
syntax](https://opam.ocaml.org/doc/Manual.html#General-syntax) and
converts them into a JSON representation. Note that the representation
is not natural, since the opam file format contains some constructs
which don't map into "native" JSON.

By default, the program reads an opam file from stdin, and writes a
JSON representation of it to stdout. See `opam2json --help` for more
options.

### JSON format

⚠️ JSON format is unstable until `opam2json` reaches 1.0.

<!-- TODO: schema -->

### Thanks

A big source of inspiration for this project was
[opam-ed](https://github.com/AltGr/opam-ed).
