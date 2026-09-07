{ pkgs, ... }:

let
  inherit (pkgs) callPackage;
  jayScripts = callPackage ./jay-scripts { };
in
{
  inherit (jayScripts) jay-screenshot-tool jay-tray-power;

  glfw-waywall = callPackage ./glfw-waywall { };
}
