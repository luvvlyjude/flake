{ pkgs, ... }:

{
  glfw-waywall = pkgs.callPackage ./glfw-waywall/package.nix { };
}
