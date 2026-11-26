{ self, ... }:
let
  inherit (self.lib.jay) jumpToMark;
in
{
  flake.homeModules.jay.wayland.windowManager.jay.settings = {
    actions = {
      switch-monitor = jumpToMark "right-monitor";
    };
  };
}
