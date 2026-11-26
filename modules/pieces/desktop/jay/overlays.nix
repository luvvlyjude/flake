{ inputs, ... }:
{
  flake.overlays = {
    jay = inputs.jay.overlays.default;
    jay-screenshot = inputs.jay-screenshot.overlays.default;
    jay-tray-item = inputs.jay-tray-item.overlays.default;
  };
}
