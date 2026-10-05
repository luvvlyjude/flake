{
  # programs.ydotool doesn't load the uinput kernel module
  hardware.uinput.enable = true;

  # systemd initrd skips the stage 2 systemd-modules-load run, so uinput never
  # loads. Remove once nixpkgs fixes it.
  boot.initrd.kernelModules = [ "uinput" ];

  programs.ydotool = {
    enable = true;
  };
}
