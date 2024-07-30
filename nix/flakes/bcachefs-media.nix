{
  description = "Bcachefs enabled installation media";
  inputs.nixos.url = "nixpkgs/nixos-23.11";
  outputs = {
    nixos,
  }: {
    nixosConfigurations = {
      exampleIso = nixos.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          "${nixos}/nixos/modules/installer/cd-dvd/installation-cd-minimal-new-kernel-no-zfs.nix"
          ({
            lib,
            pkgs,
            ...
          }: {
            boot.supportedFilesystems = ["bcachefs"];
            boot.kernelPackages = lib.mkOverride 0 pkgs.linuxPackages_latest;
          })
        ];
      };
    };
  };
}
