# <https://nixos.wiki/wiki/Using_Clang_instead_of_GCC#With_nix-shell>
with import <nixpkgs> {};
  clangStdenv.mkDerivation {
    name = "clang-shell";
    buildInputs = [
      /*
      libraries ...
      */
    ];
  }
