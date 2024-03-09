#!/bin/sh

git init
git add flake.nix
nix build .#nixosConfigurations.exampleIso.config.system.build.isoImage
