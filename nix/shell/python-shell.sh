#!/bin/sh
# shellcheck source=/dev/null

# Running as script will not work
# manually run each command in the same shell

nix-shell python-shell.nix
virtualenv venv
. venv/bin/activate # source
