# <https://nixos.wiki/wiki/Packaging/Ruby>
# <https://github.com/NixOS/nixpkgs/blob/master/doc/languages-frameworks/ruby.section.md>
with import <nixpkgs> {};
  ruby.withPackages (ps: with ps; [ruby-progressbar])
