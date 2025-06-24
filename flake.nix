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
      self,
      nixpkgs-unstable,
      flake-utils,
      treefmt-conf,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        myOverlays = import ./overlays.nix { };

        # pkgs-unstable = nixpkgs-unstable.legacyPackages.${system};
        pkgs-unstable = import nixpkgs-unstable {
          inherit system;
          inherit (myOverlays) overlays;
          config = {
            allowUnfree = true;
          };
        };
      in
      {
        formatter = treefmt-conf.formatter.${system};

        devShells = {
          default = pkgs-unstable.mkShell {
            packages = [
              self.packages.${system}.linux_6_6-framework
            ];

            inputsFrom = with pkgs-unstable; [
              bc
              bison
              cargo
              clang
              cpio
              elfutils
              flex
              git
              gmp
              gnumake
              kmod
              libmpc
              llvm
              mpfr
              ncurses
              nettools
              openssl
              pahole
              perl
              pkg-config
              python3Minimal
              rsync
              rustc
              ubootTools
              zlib
              zstd
            ];

            shellHook = ''
              ${pkgs-unstable.lib.getExe pkgs-unstable.cowsay} "Welcome to nix develop .#default";
            '';
          };
        };

        packages = {
          default = self.packages.${system}.linux_6_6-framework;

          inherit (pkgs-unstable) linux_6_6;

          linux_6_6-framework = pkgs-unstable.linux_6_6-framework;

          linux_6_6-upstream = pkgs-unstable.linux_6_6-upstream;
        };
      }
    );
}
