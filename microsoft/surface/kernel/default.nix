{ config, lib, pkgs, ... }:

# To test the kernel build:
# nix-build -E "with import <nixpkgs> {}; (pkgs.callPackage ./. {}).boot.kernelPackages.kernel"

let
  inherit (lib) kernel recurseIntoAttrs;
  inherit (pkgs) buildLinux linuxPackagesFor;
  repos = pkgs.callPackage ../repos.nix {};

  linuxPackage =
    { version,
      modDirVersion ? version,
      branch,
      src,
      kernelPatches ? [],
      ...
    }: let
      buildLinux' = buildLinux {
        inherit version src kernelPatches;
        modDirVersion = version;
        extraMeta.branch = branch;
      };
      linuxPackagesFor' = linuxPackagesFor buildLinux';
    in recurseIntoAttrs linuxPackagesFor';

  linux-5_16_11 = linuxPackage (
    pkgs.callPackage ./linux-5.16.11.nix { inherit repos; }
  );

in {
  boot.kernelPackages = linux-5_16_11;
}
