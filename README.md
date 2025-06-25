# nix-demo-kernel-framework

Nix flake demo for patching a `6.6 TLS` kernel from `nixpkgs-unstable`. Using
Framework laptop patches.

## linting & formatting

Use `nix fmt` to lint and format the repo using
`github:vpayno/nix-treefmt-conf`.

## Kernel Developer Shell

The shells for development need the native build inputs for compiling the
kernel.

### Framework Kernel using nix-shell

```bash
$ nix-shell

$ pushd "$(mktemp --tmpdir=./build --directory)"

$ unpackPhase

$ cd linux-6.6*

$ patchPhase

$ make menuconfig KCONFIG_CONFIG=build/.config

$ KCONFIG_CONFIG=build/.config buildPhase
```

### Framework Kernel using nix develop

```bash
$ nix develop .#linux_6_6-framework

$ pushd "$(mktemp --tmpdir=./build --directory)"

$ unpackPhase

$ cd linux-6.6*

$ patchPhase

$ make menuconfig KCONFIG_CONFIG=build/.config

$ KCONFIG_CONFIG=build/.config buildPhase
```
