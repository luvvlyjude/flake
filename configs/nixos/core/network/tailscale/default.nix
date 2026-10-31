{
  services.tailscale = {
    enable = true;
  };

  # load early: stage 2 skips modules-load on this machine (systemd#3436)
  boot.initrd.kernelModules = [ "tun" ];

  networking.firewall.trustedInterfaces = [
    "tailscale0"
  ];
}
