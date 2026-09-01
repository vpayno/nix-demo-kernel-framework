# nix-demo-kernel-framework

Nix flake demo for patching a `6.6 TLS` kernel from `nixpkgs-unstable`. Using
Framework laptop patches.

## Usage

```text
$ nix run .#usage
Available flake commands:

  nix run .#usage | .#default
  nix run .#show-latest

  nix run .#fetch-gentoo-patches

  nix develop .#default
  nix develop .#linux_6_6-framework
  nix develop .#linux_6_6-gentoo
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
7.3-rc1        mainline    2026-08-30  https://git.kernel.org/torvalds/t/linux-7.3-rc1.tar.gz              null
7.2.2          stable      2026-08-28  https://cdn.kernel.org/pub/linux/kernel/v7.x/linux-7.2.2.tar.xz     https://cdn.kernel.org/pub/linux/kernel/v7.x/ChangeLog-7.2.2
7.1.12         stable      2026-08-28  https://cdn.kernel.org/pub/linux/kernel/v7.x/linux-7.1.12.tar.xz    https://cdn.kernel.org/pub/linux/kernel/v7.x/ChangeLog-7.1.12
6.18.48        longterm    2026-08-28  https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.18.48.tar.xz   https://cdn.kernel.org/pub/linux/kernel/v6.x/ChangeLog-6.18.48
6.12.107       longterm    2026-08-28  https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.12.107.tar.xz  https://cdn.kernel.org/pub/linux/kernel/v6.x/ChangeLog-6.12.107
6.6.155        longterm    2026-08-28  https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.6.155.tar.xz   https://cdn.kernel.org/pub/linux/kernel/v6.x/ChangeLog-6.6.155
6.1.186        longterm    2026-08-28  https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.1.186.tar.xz   https://cdn.kernel.org/pub/linux/kernel/v6.x/ChangeLog-6.1.186
5.15.219       longterm    2026-08-28  https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.15.219.tar.xz  https://cdn.kernel.org/pub/linux/kernel/v5.x/ChangeLog-5.15.219
5.10.268       longterm    2026-08-28  https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.10.268.tar.xz  https://cdn.kernel.org/pub/linux/kernel/v5.x/ChangeLog-5.10.268
next-20260831  linux-next  2026-08-31  null                                                                null
```
