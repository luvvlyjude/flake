{
  # i think pipewire wants rtkit for some stuff so its at:
  # config/core/rtkit

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
}
