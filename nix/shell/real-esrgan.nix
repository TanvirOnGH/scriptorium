{pkgs ? import <nixpkgs> {}}:
(pkgs.buildFHSUserEnv {
  name = "pipzone";
  targetPkgs = pkgs: (with pkgs; [
    realesrgan-ncnn-vulkan
    ffmpeg_6-full
  ]);
  runScript = "bash";
})
.env
