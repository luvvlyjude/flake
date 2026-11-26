{
  flake.nixosModules.ssh =
    { config, ... }:
    {
      services.openssh = {
        enable = true;
        openFirewall = false;
      };

      networking.firewall.interfaces.tailscale0.allowedTCPPorts = config.services.openssh.ports;
    };
}
