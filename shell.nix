let
  nixpkgs = fetchTarball "https://github.com/NixOS/nixpkgs/tarball/nixos-unstable";

  myOverlays = import ./overlays.nix { };

  pkgs = import nixpkgs {
    config = { };
    inherit (myOverlays) overlays;
  };
in
pkgs.linux_6_6-framework.overrideAttrs (oldAttrs: {
  nativeBuildInputs =
    oldAttrs.nativeBuildInputs
    ++ (with pkgs; [
      pkg-config
      ncurses
    ]);

  shellHook = ''
    ${pkgs.lib.getExe pkgs.cowsay} "Welcome to nix-shell";
  '';
})
