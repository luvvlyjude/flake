{ lib, pkgs, ... }:

{
  show-bar = true;

  status = {
    format = "i3bar";
    exec = [
      (lib.getExe pkgs.i3status-rust)
      "config-jay.toml"
    ];
    i3bar-separator = "";
  };
}
