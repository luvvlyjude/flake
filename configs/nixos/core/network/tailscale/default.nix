{
  services.tailscale = {
    enable = true;
  };

  # systemd initrd skips the stage 2 systemd-modules-load run, so tun never
  # loads. Remove once nixpkgs fixes it.
  boot.initrd.kernelModules = [ "tun" ];

  networking.firewall.trustedInterfaces = [
    "tailscale0"
  ];
}
