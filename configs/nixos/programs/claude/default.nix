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
      inherit (lib) genAttrs getExe getExe';
      llm-packages = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};

      workspace = "${config.xdg.stateHome}/claude/workspace";

      toLang = lang: exts: genAttrs exts (_: lang);

      # personal plugins don't get their hooks registered, so wire ponytail's by hand
      ponytailHook = event: script: {
        ${event} = [
          {
            hooks = [
              {
                type = "command";
                command = "${getExe pkgs.nodejs} ${inputs.ponytail}/hooks/${script}.js";
                timeout = 5;
              }
            ];
          }
        ];
      };

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

      xdg.configFile."ponytail/config.json".text = builtins.toJSON { defaultMode = "lite"; };

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

          hooks =
            ponytailHook "SessionStart" "ponytail-activate"
            // ponytailHook "UserPromptSubmit" "ponytail-mode-tracker"
            // ponytailHook "SubagentStart" "ponytail-subagent";

          statusLine = {
            type = "command";
            command = getExe statusline;
          };

          theme = "dark-ansi";
        };

        enableMcpIntegration = true;

        plugins = {
          ast-grep = "${inputs.ast-grep-agent-skill}/ast-grep";
          classifier = "${inputs.classifier-dev}/plugins/classifier";
          humanizer = "${inputs.humanizer}";
          ponytail = "${inputs.ponytail}";
        };

        lspServers = {
          clangd = {
            command = getExe' pkgs.clang-tools "clangd";
            extensionToLanguage = toLang "cpp" [
              ".cc"
              ".cpp"
              ".h"
              ".hpp"
            ];
          };

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
        pkgs.nodejs
        pkgs.ripgrep
        pkgs.bubblewrap
        pkgs.socat
      ];
    };
}
