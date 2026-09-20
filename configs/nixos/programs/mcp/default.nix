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
          ast-grep.command = getExe pkgs.ast-grep-mcp;

          classifier.url = "https://classifier.dev/mcp";

          nixos.command = getExe pkgs.mcp-nixos;
        };
      };
    };
}
