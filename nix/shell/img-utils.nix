{pkgs ? import <nixpkgs> {}}:
(pkgs.buildFHSUserEnv {
  name = "img-utils";
  targetPkgs = pkgs: (with pkgs; [
    imagemagickBig
    file
  ]);
  runScript = "bash";
})
.env
