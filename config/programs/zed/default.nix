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
      inherit (lib) getExe;

      llm-packages = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
    in
    {
      programs.zed-editor = {
        enable = true;

        installRemoteServer = true;

        extensions = [
          "dark-oled"
          "nix"
        ];

        userKeymaps = [
          {
            context = "VimControl && !menu";
            unbind = {
              ctrl-q = "vim::ToggleVisualBlock";
            };
          }
          {
            context = "Editor && showing_completions";
            unbind = {
              shift-enter = "editor::ConfirmCompletionReplace";
            };
          }
        ];

        userSettings = {
          base_keymap = "VSCode";
          vim_mode = true;
          middle_click_paste = false;

          theme = "Dark OLED";
          colorize_brackets = true;

          relative_line_numbers = "enabled";
          vertical_scroll_margin = 10;

          agent = {
            dock = "right";
          };
          project_panel = {
            dock = "right";
          };
          outline_panel = {
            dock = "right";
          };
          collaboration_panel = {
            dock = "right";
          };
          git_panel = {
            dock = "right";
          };

          agent_servers = {
            claude-acp = {
              type = "custom";
              command = getExe llm-packages.claude-agent-acp;
              env = {
                # use wrapped claude code package to make configured plugins (e.g. language servers) available
                CLAUDE_CODE_EXECUTABLE = getExe llm-packages.claude-code;
                TMPDIR = config.programs.claude-code.settings.env.TMPDIR;
              };
            };
          };

          languages = {
            Nix = {
              formatter.external = {
                command = getExe pkgs.nixfmt;
              };
              format_on_save = "on";
              language_servers = [
                "!nil"
                "nixd"
                "..."
              ];
              tab_size = 2;
            };
          };

          lsp = {
            nixd = {
              binary.path = getExe pkgs.nixd;
              settings = {
                nixpkgs.expr = "import <nixpkgs> {}";
                formatting.command = [ (getExe pkgs.nixfmt) ];
                options = {
                  nixos = {
                    expr = "(builtins.getFlake \"/home/jude/Projects/flake\").nixosConfigurations.luvvly-pc.options";
                  };

                  home-manager = {
                    expr = "(builtins.getFlake \"/home/jude/Projects/flake\").nixosConfigurations.luvvly-pc.options.home-manager.users.type.getSubOptions []";
                  };
                };
              };
            };
          };

          title_bar = {
            show_sign_in = false;
          };

          which_key = {
            enabled = true;
            delay_ms = 750;
          };

          show_edit_predictions = false;

          telemetry = {
            diagnostics = false;
            metrics = false;
            anthropic_retention = false;
          };
        };
      };
    };
}
