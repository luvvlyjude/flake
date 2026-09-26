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

      # icons colored like the bash PS1 in ../bash, plus ponytail's mode badge
      statusline = pkgs.writeShellApplication {
        name = "claude-statusline";
        runtimeInputs = [ pkgs.jq ];
        text = ''
          IFS=$'\t' read -r model effort project ctx five < <(jq -r '[
            .model.display_name,
            (.effort.level // "-"),
            (.workspace.project_dir | split("/") | last),
            "\(.context_window.used_percentage // 0 | floor)%",
            (.rate_limits.five_hour.used_percentage | if . then "\(floor)%" else "-" end)
          ] | @tsv')
          seg() { printf '\033[1;38;5;53m%s \033[0;38;2;255;255;255m%s\033[0m ' "$1" "$2"; }
          seg 🤖 "$model"
          seg 🧠 "$effort"
          seg 📁 $'\033[1m'"$project"
          seg 📊 "$ctx"
          seg ⏳ "$five"
          bash ${inputs.ponytail}/hooks/ponytail-statusline.sh
        '';
      };
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

          statusLine = {
            type = "command";
            command = getExe statusline;
          };

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

        rules = import ./rules.nix;
      };

      # hooks end up outside plugin dir so just link full folder
      home.file.".claude/skills/ponytail".source = inputs.ponytail;

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
