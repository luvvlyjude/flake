{ pkgs, ... }:

{
  glfw-waywall = pkgs.callPackage ./glfw-waywall/package.nix { };
  jay-tray-power = pkgs.callPackage ./jay-tray-power/package.nix { };
}
