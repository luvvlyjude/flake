{
  services.tailscale = {
    enable = true;
  };

  # initrd's sysinit units stay active past switch-root, so stage 2 skips
  # modules-load and kmod-static-nodes and tun never loads. Same as ../../../programs/ydotool.
  # https://github.com/systemd/systemd/issues/3436; to test, drop this, reboot, `lsmod | grep tun`.
  boot.initrd.kernelModules = [ "tun" ];

  networking.firewall.trustedInterfaces = [
    "tailscale0"
  ];
}
