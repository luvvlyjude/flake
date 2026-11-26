{
  flake.nixosModules.audio = {
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    # i think pipewire wants this for some audio stuff
    # waywall also uses this for elevating
    security.rtkit = {
      enable = true;
    };
  };
}
