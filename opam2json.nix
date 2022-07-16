{ stdenv, fetchFromGitHub, opam-installer, ocaml, findlib, yojson, opam-file-format, cmdliner }:
stdenv.mkDerivation {
  pname = "opam2json";
  version = "dev";

  src = ./.;

  buildInputs = [ yojson opam-file-format cmdliner ];
  nativeBuildInputs = [ ocaml findlib opam-installer ];

  preInstall = "export PREFIX=$out";
}
