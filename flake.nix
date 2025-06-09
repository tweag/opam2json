{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default";
  };

  outputs = { self, systems, nixpkgs }:
    let
      eachSystem = nixpkgs.lib.genAttrs (import systems);
    in
    {
      overlay = final: prev: {
        opam2json = final.ocamlPackages.callPackage ./opam2json.nix { };
      };

      packages = eachSystem (system:
        let
          opam2json = (nixpkgs.legacyPackages.${system}.extend self.overlay).opam2json;
        in
        {
          inherit opam2json;
          default = opam2json;
        });
    };
}
