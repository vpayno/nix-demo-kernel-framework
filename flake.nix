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

        scripts = {
          showLatest = pkgs-unstable.writeShellApplication {
            name = "show-latest";
            runtimeInputs = with pkgs-unstable; [
              coreutils
              curl
              jq
            ];
            text = ''
              {
                printf "Version Moniker Releaed Source Changelog\n";
                curl -s https://www.kernel.org/releases.json | jq -r '.releases[] | "\(.version) \(.moniker) \(.released.isodate) \(.source) \(.changelog)"'
              } | column -t
            '';
          };
        };
      in
      {
        formatter = treefmt-conf.formatter.${system};

        devShells = {
          default = pkgs-unstable.mkShell {
            pname = "framework patched kernel shell";

            # get added to $PATH
            packages = [
            ];

            # don't use buildInputs in mkShell

            # get added to PATH, LD_LIBRARY_PATH, include paths, pkg-config, man pages
            nativeBuildInputs = with pkgs-unstable; [
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
              export LD_LIBRARY_PATH="${
                pkgs-unstable.lib.makeLibraryPath self.devShells.${system}.framework.nativeBuildInputs
              }:$LD_LIBRARY_PATH"

              ${pkgs-unstable.lib.getExe pkgs-unstable.cowsay} "Welcome to nix develop .#default";
            '';
          };

          framework = self.devShells.${system}.default.overrideAttrs (_: {
            pname = "unpatched kernel shell";

            packages = [
              self.packages.${system}.linux_6_6-framework
            ];
          });

          upstream = self.devShells.${system}.default.overrideAttrs (_: {
            pname = "unpatched kernel shell";

            packages = [
              self.packages.${system}.linux_6_6-upstream
            ];
          });
        };

        packages = {
          default = self.packages.${system}.linux_6_6-framework;

          inherit (pkgs-unstable) linux_6_6 linux_6_6-framework linux_6_6-upstream;

          inherit (scripts) showLatest;
        };

        apps = {
          default = self.apps.${system}.show-latest;

          show-latest = {
            type = "app";
            program = "${pkgs-unstable.lib.getExe self.packages.${system}.showLatest}";
          };
        };
      }
    );
}
