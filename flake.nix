{
  description = "A very basic flake";
  inputs.haskellNix.url = "github:input-output-hk/haskell.nix";
  inputs.nixpkgs.follows = "haskellNix/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.pandoc.url = "github:jgm/pandoc";
  inputs.pandoc.flake = false;
  outputs = { self, nixpkgs, flake-utils, haskellNix, pandoc}:
    flake-utils.lib.eachSystem [ "x86_64-linux" "x86_64-darwin" ] (system:
    let
      overlays = [ haskellNix.overlay
        (final: prev: {
          # This overlay adds our project to pkgs
          pandoc-flake =
            final.haskell-nix.project' {
              src = pandoc;
              compiler-nix-name = "ghc8107";
              #name = "pandoc";
              # This is used by `nix develop .` to open a shell for use with
              # `cabal`, `hlint` and `haskell-language-server`
              projectFileName = "cabal.project";
              shell.tools = {
                cabal = {};
                hlint = {};
                haskell-language-server = {};
              };
              # Non-Haskell shell tools go here
              shell.buildInputs = with pkgs; [
                nixpkgs-fmt
              ];
              #shell.crossPlatforms = p: [p.ghcjs];
              # This adds `js-unknown-ghcjs-cabal` to the shell.
            };
        })
      ];
      pkgs = import nixpkgs { inherit system overlays; inherit (haskellNix) config; };
      flake = pkgs.pandoc-flake.flake{
        # This adds support for `nix build .#js-unknown-ghcjs-cabal:hello:exe:hello`
        #crossPlatforms = p: [p.ghcjs];
      };
    in flake // {
      # Built by `nix build .`
      defaultPackage = flake.packages."pandoc:exe:pandoc";
    });
}

