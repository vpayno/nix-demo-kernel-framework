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

        data = {
          usageMessage = ''
            Available flake commands:

              nix run .#usage | .#default
              nix run .#show-latest

              nix run .#fetch-gentoo-patches

              nix develop .#default
              nix develop .#linux_6_6-framework
              nix develop .#linux_6_6-gentoo
              nix develop .#linux_6_6-upstream
          '';
        };

        scripts = {
          # very odd, this doesn't work with pkgs.writeShellApplication
          # odd quoting error when the string usagemessage as new lines
          showUsage = pkgs-unstable.writeShellScriptBin "show-usage" ''
            printf "%s" "${data.usageMessage}"
          '';

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

          fetchGentooPatches = pkgs-unstable.writeShellApplication {
            name = "fetch-gentoo-patches";
            runtimeInputs = with pkgs-unstable; [
              coreutils
              curl
              gnugrep
              gnused
              jq
            ];
            text = ''
              declare src_url="https://dev.gentoo.org/~mpagano/genpatches/trunk/6.6/"
              declare data
              declare -a patches

              data="$(curl -sS "''${src_url}" | grep '[.]patch' | grep -v 'linux-6[.]6[.][0-9]' | sed -r -e 's;.*href="(.*)".*;\1;g')"

              printf "Downloading the following patches:\n"
              printf "%s\n" "''${data}"
              printf "\n"

              mapfile -t patches <<< "''${data}"

              for p in "''${patches[@]}"; do
                printf "Downloading [%s]...\n" "''${src_url}''${p}"
                curl -sS --output ./patches/6.6/"''${p}" "''${src_url}''${p}"
                printf "\n"
              done
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
          default = self.packages.${system}.linux_6_6-patched;

          inherit (pkgs-unstable)
            linux_6_6
            linux_6_6-framework
            linux_6_6-gentoo
            linux_6_6-patched
            linux_6_6-upstream
            ;

          inherit (scripts) showUsage showLatest fetchGentooPatches;
        };

        apps = {
          default = self.apps.${system}.usage;

          usage = {
            type = "app";
            program = "${pkgs-unstable.lib.getExe self.packages.${system}.showUsage}";
          };

          show-latest = {
            type = "app";
            program = "${pkgs-unstable.lib.getExe self.packages.${system}.showLatest}";
          };

          fetch-gentoo-patches = {
            type = "app";
            program = "${pkgs-unstable.lib.getExe self.packages.${system}.fetchGentooPatches}";
          };
        };
      }
    );
}
