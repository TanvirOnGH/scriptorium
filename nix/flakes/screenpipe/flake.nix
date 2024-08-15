{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    naersk.url = "github:nix-community/naersk";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = {
    self,
    flake-utils,
    naersk,
    nixpkgs,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = (import nixpkgs) {
          inherit system;
          config.allowUnfree = true;
          config.cudaSupport = true;
        };
        naersk' = pkgs.callPackage naersk {};
      in rec {
        # For `nix build` & `nix run`
        defaultPackage = naersk'.buildPackage {
          src = ./.;
          compressTarget = false;

          cargoBuildOptions = x: x ++ ["--features" "cuda"];

          nativeBuildInputs = with pkgs; [
            pkg-config
            cudaPackages.cudatoolkit
          ];

          buildInputs = with pkgs; [
            alsaLib
            llvmPackages.clang
            llvmPackages.libclang
            openssl
            xorg.libxcb
          ];

          propagatedBuildInputs = with pkgs; [
            ffmpeg
            tesseract
          ];

          LIBCLANG_PATH = "${pkgs.llvmPackages.libclang.lib}/lib";
          CUDA_PATH = "${pkgs.cudaPackages.cudatoolkit}";
          LD_LIBRARY_PATH = "${pkgs.lib.makeLibraryPath [
            pkgs.cudaPackages.cudatoolkit
            pkgs.cudaPackages.cuda_cudart
          ]}";
        };

        # For `nix develop`
        devShell =
          pkgs.mkShell.override {
            stdenv =
              if pkgs.config.cudaSupport
              then pkgs.cudaPackages.backendStdenv
              else pkgs.stdenv;
          } {
            packages = with pkgs; [rustc cargo];
            nativeBuildInputs = with pkgs; [
              pkg-config
              cudaPackages.cudatoolkit
              cudaPackages.cuda_cudart
            ];

            buildInputs = with pkgs; [
              alsaLib
              llvmPackages.clang
              llvmPackages.libclang
              openssl
              xorg.libxcb
            ];

            propagatedBuildInputs = with pkgs; [
              ffmpeg
              tesseract
            ];

            shellHook = ''
              export CUDA_PATH=${pkgs.cudaPackages.cudatoolkit}
              export LIBCLANG_PATH=${pkgs.llvmPackages.libclang.lib}/lib;
              export LD_LIBRARY_PATH=${pkgs.lib.makeLibraryPath [
                pkgs.cudaPackages.cudatoolkit
                pkgs.cudaPackages.cuda_cudart
              ]};
            '';
          };
      }
    );
}
