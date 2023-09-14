# flakelight -- Framework for simplifying flake setup
# Copyright (C) 2023 Archit Gupta <archit@accelbread.com>
# SPDX-License-Identifier: MIT

{
  description =
    "A modular Nix flake framework for simplifying flake definitions";
  inputs.nixpkgs.url = "nixpkgs/nixos-unstable";
  outputs = { nixpkgs, ... }:
    let lib = import ./. nixpkgs; in
    lib.mkFlake ./. {
      inherit lib;
      functor = _: lib.mkFlake;
      templates = import ./templates;
      checks.statix = pkgs: "${pkgs.statix}/bin/statix check";
    };
}
