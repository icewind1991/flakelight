# flakelight -- Framework for simplifying flake setup
# Copyright (C) 2023 Archit Gupta <archit@accelbread.com>
# SPDX-License-Identifier: MIT

{ config, lib, flakelight, moduleArgs, ... }:
let
  inherit (builtins) isAttrs mapAttrs;
  inherit (lib) foldl mapAttrsToList mergeOneOption mkIf mkOption mkOptionType
    recursiveUpdate;
  inherit (lib.types) lazyAttrsOf;
  inherit (flakelight.types) optFunctionTo;

  nixosConfiguration = mkOptionType {
    name = "nixosConfiguration";
    description = "nixosConfiguration";
    descriptionClass = "noun";
    check = x: isAttrs x
      && x ? config.nixpkgs.system
      && x ? config.system.build.toplevel;
    merge = mergeOneOption;
  };

  configs = mapAttrs (_: f: f moduleArgs) config.nixosConfigurations;
in
{
  options.nixosConfigurations = mkOption {
    type = lazyAttrsOf (optFunctionTo nixosConfiguration);
    default = { };
  };

  config.outputs = mkIf (config.nixosConfigurations != { }) {
    nixosConfigurations = configs;
    checks = foldl recursiveUpdate { } (mapAttrsToList
      (n: v: {
        ${v.config.nixpkgs.system}."nixos-${n}" = v.pkgs.runCommand
          "check-nixos-${n}"
          { } "echo ${v.config.system.build.toplevel} > $out";
      })
      configs);
  };
}
