{
  description = "Gemini-to-Gopher Proxy";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nix-gleam.url = "github:arnarg/nix-gleam";
    gitignore = {
      url = "github:hercules-ci/gitignore.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { nixpkgs, flake-utils, nix-gleam, gitignore, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            nix-gleam.overlays.default
          ];
        };
        inherit (gitignore.lib) gitignoreSource;
      in
      {
        packages.default = pkgs.buildGleamApplication {
          src = gitignoreSource ./.;
        };
        devShells.default = pkgs.mkShell {
          buildInputs = [ pkgs.gleam pkgs.erlang ];
        };
      }
    );
}
