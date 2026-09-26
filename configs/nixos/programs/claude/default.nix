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
          awaySummaryEnabled = false;
          spinnerTipsEnabled = false;
          syncClaudeAiSkills = false;

          env.TMPDIR = workspace;

          sandbox = import ./sandbox.nix workspace;
          permissions = import ./permissions.nix workspace;

          theme = "dark";
        };

        enableMcpIntegration = true;

        skills = import ./skills.nix {
          inherit inputs lib pkgs;
        };

        plugins.ponytail = "${inputs.ponytail}";

        lspServers = {
          nixd = {
            command = getExe pkgs.nixd;
            extensionToLanguage = toLang "nix" [ ".nix" ];
          };
        };

        rules = import ./rules.nix;
      };

      home.packages = [
        llm-packages.ccusage

        # extra utilities
        pkgs.ast-grep
        pkgs.classifier-dev
        pkgs.nodejs
        pkgs.ripgrep
        pkgs.bubblewrap
        pkgs.socat
      ];
    };
}
