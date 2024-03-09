{pkgs ? import <nixpkgs> {}}:
(pkgs.buildFHSUserEnv {
  name = "img-utils";
  targetPkgs = pkgs: (with pkgs; [
    imagemagickBig
    toybox
  ]);
  runScript = "bash";
})
.env
