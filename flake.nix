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
              nix develop .#linux_6_6-patched
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
              # lts kernel series
              declare -a kernel_versions=( "5.10" "5.15" "6.1" "6.6" "6.12" "6.18" )
              declare kernel_version

              for kernel_version in "''${kernel_versions[@]}"; do
                [[ -d ./patches/"''${kernel_version}"/ ]] || mkdir -pv ./patches/"''${kernel_version}"/

                declare src_url="https://dev.gentoo.org/~mpagano/genpatches/trunk/''${kernel_version}/"

                declare -a data
                declare -a patches

                mapfile -t data <<< "$(curl -sS "''${src_url}" | grep -e '[.]patch' -e '0000_README' | sed -r -e 's;.*href="(.*)".*;\1;g')"

                printf "\n"
                printf "Downloading the following Gentoo %s kernel patches:\n" "''${kernel_version}"
                printf "\n"
                printf "\t%s\n" "''${data[@]}"
                printf "\n"

                read -r -a patches <<< "''${data[@]}"

                for p in "''${patches[@]}"; do
                  printf "Downloading [%s]...\n" "''${src_url}''${p}"
                  curl -sS --output ./patches/"''${kernel_version}"/"''${p}" "''${src_url}''${p}"
                  printf "\n"
                done

                git add ./patches/"''${kernel_version}"/
                git commit -m "nix(overlay): update gentoo ''${kernel_version} kernel patches" ./patches/"''${kernel_version}"/ || true
                printf "\n"
              done

              printf "Finished downloading Gentoo kernel patches.\n"
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
                pkgs-unstable.lib.makeLibraryPath self.devShells.${system}.default.nativeBuildInputs
              }:$LD_LIBRARY_PATH"

              ${pkgs-unstable.lib.getExe pkgs-unstable.cowsay} "Welcome to nix develop .#default";
            '';
          };
        };

        packages = {
          default = self.packages.${system}.linux_6_6-patched;

          inherit (pkgs-unstable)
            linux_6_6
            linux_6_6-framework
            linux_6_6-gentoo
            linux_6_6-patched
            linux_6_6-upstream
            linux_6_18-gentoo
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
