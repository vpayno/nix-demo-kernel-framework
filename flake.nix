{
  "description" = "Nix flake demo for kernel patching";

  inputs = {
    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    systems.url = "github:vpayno/nix-systems-default";

    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };

    treefmt-conf = {
      url = "github:vpayno/nix-treefmt-conf";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs =
    {
      nixpkgs-unstable,
      flake-utils,
      treefmt-conf,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs-unstable = nixpkgs-unstable.legacyPackages.${system};

        kernelDevTools = (
          with pkgs-unstable;
          [
            bc
            bintools
            bison
            cargo
            clang
            cpio
            elfutils
            flex
            gitFull
            global
            gmp
            gnumake
            kmod
            libmpc
            llvm
            mpfr
            ncurses
            nettools
            # openssl
            pahole
            perl
            python3Minimal
            rsync
            rustc
            ubootTools
            zlib
            zstd
          ]
        );
      in
      {
        formatter = treefmt-conf.formatter.${system};

        devShells = {
          default = pkgs-unstable.mkShell {
            packages = kernelDevTools;
          };
        };
      }
    );
}
