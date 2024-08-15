with import <nixpkgs> {};
with pkgs;
  stdenv.mkDerivation {
    name = "screenpipe-runner";

    buildInputs = [
      ffmpeg-full
      tesseract
    ];

    shellHook = ''
      ./result/bin/screenpipe
    '';
    # ./target/release/screenpipe
    # sha1sum ./result/bin/screenpipe
    # sha1sum ./target/release/screenpipe
  }
