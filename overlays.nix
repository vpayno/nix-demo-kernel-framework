# overlays.nix
{
  ...
}:
let
  patches_6_6-framework = [
    ./patches/6.6/framework-amd-npcx_chrome_ec_linear_mmio-v3-1of4.patch
    ./patches/6.6/framework-amd-npcx_chrome_ec_linear_mmio-v3-2of4.patch
    ./patches/6.6/framework-amd-npcx_chrome_ec_linear_mmio-v3-3of4.patch
    ./patches/6.6/framework-amd-npcx_chrome_ec_linear_mmio-v3-4of4.patch
  ];

  patches_6_6-gentoo = [
    ./patches/6.6/1510_fs-enable-link-security-restrictions-by-default.patch
    ./patches/6.6/1700_sparc-address-warray-bound-warnings.patch
    ./patches/6.6/1730_parisc-Disable-prctl.patch
    ./patches/6.6/1900_btrfs-dev-mapper-name-soft-link-fix.patch
    ./patches/6.6/2000_BT-Check-key-sizes-only-if-Secure-Simple-Pairing-enabled.patch
    ./patches/6.6/2400_wifi-rtw89-88xb-firmware.patch
    ./patches/6.6/2700_ASoC_max98388_correct_includes.patch
    ./patches/6.6/2800_amdgpu-Adj-kmalloc-array-calls-for-new-Walloc-size.patch
    ./patches/6.6/2910_bfp-mark-get-entry-ip-as--maybe-unused.patch
    ./patches/6.6/2920_sign-file-patch-for-libressl.patch
    ./patches/6.6/2931_gcc14-drm-i915-Adapt-to-Walloc-size.patch
    ./patches/6.6/2932_gcc14-objtool-Fix-calloc-call-for-new-Walloc-size.patch
    ./patches/6.6/2951_libbpf-Prevent-compiler-warnings-errors.patch
    ./patches/6.6/2952_resolve-btfids-Fix-compiler-warnings.patch
    ./patches/6.6/2980_GCC15-gnu23-to-gnu11-fix.patch
    ./patches/6.6/2990_libbpf-v2-workaround-Wmaybe-uninitialized-false-pos.patch
    ./patches/6.6/2995_dtrace-6.6_p2.patch
    ./patches/6.6/3000_Support-printing-firmware-info.patch
    ./patches/6.6/4567_distro-Gentoo-Kconfig.patch
    ./patches/6.6/5010_enable-cpu-optimizations-universal.patch
  ];

  overlayLinuxPatched = self: super: {
    linux_6_6-framework = super.linux_6_6.overrideAttrs (oldAttrs: {
      patches = oldAttrs.patches ++ patches_6_6-framework;

      postPatch =
        (oldAttrs.postPatch or "")
        + ''
          echo patched kernel ${oldAttrs.pname} ${oldAttrs.version} with Framework patches
        '';
    });

    linux_6_6-gentoo = super.linux_6_6.overrideAttrs (oldAttrs: {
      patches = oldAttrs.patches ++ patches_6_6-gentoo;

      postPatch =
        (oldAttrs.postPatch or "")
        + ''
          echo patched kernel ${oldAttrs.pname} ${oldAttrs.version} with Gentoo patches
        '';
    });

    linux_6_6-patched = self.linux_6_6-framework.overrideAttrs (oldAttrs: {
      patches = oldAttrs.patches ++ patches_6_6-gentoo;

      postPatch =
        (oldAttrs.postPatch or "")
        + ''
          echo patched kernel ${oldAttrs.pname} ${oldAttrs.version} with Gentoo patches
        '';
    });

    linux_6_6 = self.linux_6_6-patched;

    linux_6_6-upstream = super.linux_6_6;
  };
in
{
  overlays = [
    overlayLinuxPatched
  ];
}
