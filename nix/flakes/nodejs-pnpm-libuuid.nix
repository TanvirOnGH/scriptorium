{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    systems.url = "github:nix-systems/default";
  };

  outputs = {
    systems,
    nixpkgs,
    ...
  }: let
    eachSystem = f: nixpkgs.lib.genAttrs (import systems) (system: f nixpkgs.legacyPackages.${system});
  in {
    devShells = eachSystem (pkgs: {
      default = pkgs.mkShell {
        buildInputs = [
          pkgs.libuuid
          pkgs.nodejs
          pkgs.nodePackages.pnpm
        ];
        env = {
          LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [pkgs.libuuid];
        };
      };
    });
  };
}
