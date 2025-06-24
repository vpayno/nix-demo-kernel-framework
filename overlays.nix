# overlays.nix
{
  ...
}:
let
  patches_6_6 = [
    ./patches/6.6/framework-amd-npcx_chrome_ec_linear_mmio-v3-1of4.patch
    ./patches/6.6/framework-amd-npcx_chrome_ec_linear_mmio-v3-2of4.patch
    ./patches/6.6/framework-amd-npcx_chrome_ec_linear_mmio-v3-3of4.patch
    ./patches/6.6/framework-amd-npcx_chrome_ec_linear_mmio-v3-4of4.patch
  ];

  overlayLinuxPatched = self: super: {
    linux_6_6-framework = super.linux_6_6.overrideAttrs (oldAttrs: {
      patches = oldAttrs.patches ++ patches_6_6;

      postPatch =
        (oldAttrs.postPatch or "")
        + ''
          echo patched kernel ${oldAttrs.pname} ${oldAttrs.version} with framework patches
        '';
    });

    linux_6_6 = self.linux_6_6-framework;

    linux_6_6-upstream = super.linux_6_6;
  };
in
{
  overlays = [
    overlayLinuxPatched
  ];
}
