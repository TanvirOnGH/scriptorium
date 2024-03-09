# <https://nixos.wiki/wiki/Node.js>
with import <nixpkgs> {};
  stdenv.mkDerivation {
    name = "NodeJS";
    buildInputs = [
      nodejs
      yarn
      nodePackages.npm
    ];
    shellHook = ''
      export PATH="$PWD/node_modules/.bin/:$PATH"
    '';
  }
