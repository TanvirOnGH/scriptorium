#!/bin/sh

# Running as script will not work
# manually run each command in the same shell

nix-shell python-shell.nix
virtualenv venv
source venv/bin/activate
