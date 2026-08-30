{ inputs, ... }:

{
  nixpkgs = {
    overlays = [
      # Add overlays this flake exports (from overlays and pkgs dir):
      # Modifications after additions so that we can modify packages we add
      inputs.self.overlays.additions
      inputs.self.overlays.modifications

      inputs.ktrompfl-old.overlays.additions
      inputs.ktrompfl.overlays.default
    ];
  };
}
