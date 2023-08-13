# <https://godot-rust.github.io/book/gdnative/recipes/nix-build-system.html>
let
  # Up-to-date package for enabling OpenGL support in Nix
  nixgl = import (fetchTarball "https://github.com/guibou/nixGL/archive/master.tar.gz") {};

  # Search for the commit hash of a particular package: <https://lazamar.co.uk/nix-versions>
  pkgs = import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/8ad5e8132c5dcf977e308e7bf5517cc6cc0bf7d8.tar.gz") {};
in
  pkgs.mkShell.override {stdenv = pkgs.clangStdenv;} {
    buildInputs = with pkgs; [
      # Rust related dependencies
      rustc
      cargo
      rustfmt
      clippy
      rust-analyzer
      libclang
      gcc

      # Godot Engine Editor
      godot_4

      # The support for OpenGL in Nix
      nixgl.auto.nixGLDefault
    ];

    # Point bindgen to where the clang library would be
    LIBCLANG_PATH = "${pkgs.libclang.lib}/lib";

    # Make clang aware of a few headers (stdbool.h, wchar.h)
    BINDGEN_EXTRA_CLANG_ARGS = with pkgs; ''
      -isystem ${llvmPackages.libclang.lib}/lib/clang/${lib.getVersion clang}/include
      -isystem ${llvmPackages.libclang.out}/lib/clang/${lib.getVersion clang}/include
      -isystem ${glibc.dev}/include
    '';

    # For Rust language server and rust-analyzer
    RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";

    # Alias the godot engine to use nixGL
    shellHook = ''
      alias godot="nixGL godot -e"
    '';
  }
