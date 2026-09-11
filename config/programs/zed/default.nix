{
  hm =
    { lib, pkgs, ... }:
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

          theme = {
            mode = "dark";
            dark = "Dark OLED";
          };
          colorize_brackets = true;

          vim_mode = true;
          relative_line_numbers = "enabled";
          vertical_scroll_margin = 10;

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

          languages = {
            Nix = {
              formatter.external = {
                command = lib.getExe pkgs.nixfmt;
              };
              format_on_save = true;
              language_servers = [
                "!nil"
                "nixd"
              ];
              tab_size = 2;
            };
          };

          lsp = {
            nixd = {
              binary.path = lib.getExe pkgs.nixd;
              settings.nixd = {
                nixpkgs.expr = "import <nixpkgs> {}";
                formatting.command = [ (lib.getExe pkgs.nixfmt) ];
                # options = {
                #   nixos = {
                #     expr = "(builtins.getFlake \"/home/lyc/flakes\").nixosConfigurations.adrastea.options";
                #   };

                #   home-manager = {
                #     expr = "(builtins.getFlake \"/home/lyc/flakes\").homeConfigurations.\"lyc@adrastea\".options";
                #   };
                # };
              };
            };
          };

          agent = {
            dock = "left";
          };

          title_bar = {
            show_sign_in = false;
          };

          ssh_connections = [
            {
              host = "luvvly-pc";
              username = "jude";
              projects = [
                {
                  paths = [
                    "/home/jude/Projects/flake"
                  ];
                }
                {
                  paths = [
                    "/home/jude/Projects/mcsr-nixos"
                  ];
                }
              ];
            }
          ];

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
