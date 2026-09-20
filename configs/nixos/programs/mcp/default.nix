{
  hm =
    { lib, pkgs, ... }:

    let
      inherit (lib) getExe;
    in
    {
      # enabled in claude and zed with `enableMcpIntegration`.
      programs.mcp = {
        enable = true;

        servers = {
          classifier.url = "https://classifier.dev/mcp";

          nixos.command = getExe pkgs.mcp-nixos;
        };
      };
    };
}
