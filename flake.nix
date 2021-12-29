{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }: {
    overlay = final: prev: {
      opam2json = final.ocamlPackages.callPackage ./opam2json.nix { };
    };
    packages.x86_64-linux.opam2json =
      (nixpkgs.legacyPackages.x86_64-linux.extend self.overlay).opam2json;
    defaultPackage.x86_64-linux = self.packages.x86_64-linux.opam2json;
  };
}
