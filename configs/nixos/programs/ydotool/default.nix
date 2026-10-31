{
  # programs.ydotool doesn't load the uinput kernel module
  hardware.uinput.enable = true;

  # load early: stage 2 skips modules-load on this machine (systemd#3436)
  boot.initrd.kernelModules = [ "uinput" ];

  programs.ydotool = {
    enable = true;
  };
}
