# SPDX-FileCopyrightText: 2021 Serokell <https://serokell.io/>
#
# SPDX-License-Identifier: CC0-1.0

{
  description = "My haskell application";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    pandoc.url = "github:jgm/pandoc";
    pandoc.flake = false;
    pandoc-lua-marshal.url = "github:IllustratedMan-code/pandoc-lua-marshal-flake";
  };

  outputs = { self, nixpkgs, flake-utils,pandoc, pandoc-lua-marshal }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        haskellPackages = pkgs.haskellPackages;




        jailbreakUnbreak = pkg:
          pkgs.haskell.lib.doJailbreak (pkg.overrideAttrs (_: { meta = { }; }));

        # DON'T FORGET TO PUT YOUR PACKAGE NAME HERE, REMOVING `throw`
        packageName = "pandoc";
      in {
        packages.${packageName} =
          haskellPackages.callCabal2nix packageName pandoc rec {
            pandoc-types = haskellPackages.callCabal2nix "pandoc-types" cabal://pandoc-types-1.22.2;
          };

        defaultPackage = self.packages.${system}.${packageName};

        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            haskellPackages.haskell-language-server # you must build it with your ghc to work
            ghcid
            cabal-install
          ];
          inputsFrom = builtins.attrValues self.packages.${system};
        };
      });
}
