{
  inputs.nixpkgs.url = "nixpkgs/nixos-unstable";

  outputs = {nixpkgs, ...}: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {inherit system;};
  in {
    devShells.${system}.default = pkgs.mkShell {
      packages = with pkgs;
      with gst_all_1; [
        dwarfs
        wineWowPackages.stagingFull
        fuse-overlayfs
        bubblewrap
        gst-libav
        gst-plugins-bad
        gst-plugins-base
        gst-plugins-good
        gst-plugins-ugly
        gst-vaapi
      ];
    };
  };
}
