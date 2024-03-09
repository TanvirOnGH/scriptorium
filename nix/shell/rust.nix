# Reference: <https://nixos.wiki/wiki/Rust>
{pkgs ? import <nixpkgs> {}}:
pkgs.mkShell {
  nativeBuildInputs = with pkgs; [
    # Rust related dependencies
    rustc
    cargo
    rustfmt
    clippy
    rust-analyzer
    libclang
    gcc

    # Required for the openssl-sys crate
    # <https://nixos.wiki/wiki/Rust#Building_Rust_crates_that_require_external_system_libraries>
    openssl
    pkg-config
  ];

  # Certain Rust tools won't work without this
  # This can also be fixed by using oxalica/rust-overlay and specifying the rust-src extension
  # https://discourse.nixos.org/t/rust-src-not-found-and-other-misadventures-of-developing-rust-on-nixos/11570/3?u=samuela
  RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";

  # <https://discourse.nixos.org/t/rust-openssl-woes/12340>
  PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";
}
