{
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware = {
    graphics.enable = true;

    nvidia = {
      branch = "latest";
      open = true;
      powerManagement.enable = true;
    };
  };

  boot = {
    initrd.kernelModules = [
      "nvidia"
      "nvidia_modeset"
      "nvidia_uvm"
      "nvidia_drm"
    ];
  };
}
