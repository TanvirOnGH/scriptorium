# Reference: <https://nixos.wiki/wiki/Python>

{pkgs ? import <nixpkgs> {}}:
(pkgs.buildFHSUserEnv {
  name = "pipzone";
  targetPkgs = pkgs: (with pkgs; [
    python310
    python310Packages.pip
    python310Packages.virtualenv
  ]);
  runScript = "bash";
})
.env
