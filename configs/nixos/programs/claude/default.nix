{
  hm =
    {
      config,
      inputs,
      lib,
      pkgs,
      ...
    }:

    let
      inherit (lib) genAttrs getExe;
      llm-packages = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};

      workspace = "${config.xdg.stateHome}/claude/workspace";

      toLang = lang: exts: genAttrs exts (_: lang);
    in
    {
      systemd.user.tmpfiles.rules = [ "d ${workspace} 0700 - - 7d" ];

      programs.claude-code = {
        enable = true;
        package = llm-packages.claude-code;

        settings = {
          env.TMPDIR = workspace;

          sandbox = import ./sandbox.nix workspace;
          permissions = import ./permissions.nix workspace;

          theme = "dark";
        };

        enableMcpIntegration = true;

        skills = import ./skills.nix {
          inherit inputs lib pkgs;
        };

        lspServers = {
          nixd = {
            command = getExe pkgs.nixd;
            extensionToLanguage = toLang "nix" [ ".nix" ];
          };
        };

        context = ''
          # Scratch files

          `/tmp` and `/var/tmp` are a 2 GB tmpfs shared with the root filesystem.
          Put build output, unpacked archives, checkouts, logs and anything else of
          unbounded size under `$TMPDIR` instead, one subdirectory per task; it is
          on disk and cleaned after 7 days. Never pass `/tmp` as an output
          directory.
        '';
      };

      home.packages = [
        llm-packages.ccusage

        # extra utilities
        pkgs.ast-grep
        pkgs.classifier-dev
        pkgs.ripgrep
        pkgs.bubblewrap
        pkgs.socat
      ];
    };
}
