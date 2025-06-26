# nix-demo-kernel-framework

Nix flake demo for patching a `6.6 TLS` kernel from `nixpkgs-unstable`. Using
Framework laptop patches.

## Usage

```text
$ nix run .#usage
Available flake commands:

  nix run .#usage | .#default
  nix run .#show-latest

  nix develop .#default
  nix develop .#linux_6_6-framework
  nix develop .#linux_6_6-upstream
```

## Linting & Formatting

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

## Fetching the list of latest upstream kernels

You can use the `show-latest` app to fetch the list of latest upstream kernels.

```bash
nix run .#show-latest
```

For example:

```text
$ nix run .#show-latest
Version        Moniker     Releaed     Source                                                              Changelog
6.16-rc3       mainline    2025-06-22  https://git.kernel.org/torvalds/t/linux-6.16-rc3.tar.gz             null
6.15.3         stable      2025-06-19  https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.15.3.tar.xz    https://cdn.kernel.org/pub/linux/kernel/v6.x/ChangeLog-6.15.3
6.14.11        stable      2025-06-10  https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.14.11.tar.xz   https://cdn.kernel.org/pub/linux/kernel/v6.x/ChangeLog-6.14.11
6.12.34        longterm    2025-06-19  https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.12.34.tar.xz   https://cdn.kernel.org/pub/linux/kernel/v6.x/ChangeLog-6.12.34
6.6.94         longterm    2025-06-19  https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.6.94.tar.xz    https://cdn.kernel.org/pub/linux/kernel/v6.x/ChangeLog-6.6.94
6.1.141        longterm    2025-06-04  https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.1.141.tar.xz   https://cdn.kernel.org/pub/linux/kernel/v6.x/ChangeLog-6.1.141
5.15.185       longterm    2025-06-04  https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.15.185.tar.xz  https://cdn.kernel.org/pub/linux/kernel/v5.x/ChangeLog-5.15.185
5.10.238       longterm    2025-06-04  https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.10.238.tar.xz  https://cdn.kernel.org/pub/linux/kernel/v5.x/ChangeLog-5.10.238
5.4.294        longterm    2025-06-04  https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.4.294.tar.xz   https://cdn.kernel.org/pub/linux/kernel/v5.x/ChangeLog-5.4.294
next-20250625  linux-next  2025-06-25  null                                                                null
```
