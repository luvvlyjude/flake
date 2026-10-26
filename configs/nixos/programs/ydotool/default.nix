{
  # programs.ydotool doesn't load the uinput kernel module
  hardware.uinput.enable = true;

  # initrd's sysinit units stay active past switch-root, so stage 2 skips
  # modules-load and uinput never loads. Same as ../../core/network/tailscale.
  # https://github.com/systemd/systemd/issues/3436; to test, drop this, reboot, `lsmod | grep uinput`.
  boot.initrd.kernelModules = [ "uinput" ];

  programs.ydotool = {
    enable = true;
  };
}
