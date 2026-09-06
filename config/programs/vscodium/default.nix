{
  hm = { pkgs, ... }: {
    programs.vscodium = {
      enable = true;

      profiles.default = {
        extensions = [
          pkgs.vscode-extensions.vscodevim.vim
        ];
        userSettings = {
          "workbench.colorTheme" = "Default High Contrast";
          "workbench.colorCustomizations" = {
            "keybindingLabel.bottomBorder" = "#350030";
            "keybindingLabel.border" = "#350030";
            "editorSuggestWidget.selectedBackground" = "#350030";
            "editorSuggestWidget.selectedForeground" = "#FFFFFF";
            "editorSuggestWidget.foreground" = "#999999";
            "editorWidget.background" = "#000000";
            "tab.unfocusedActiveBackground" = "#250015";
            "tab.inactiveForeground" = "#999999";
            "tab.activeBackground" = "#350030";
            "contrastActiveBorder" = "#350030";
            "contrastBorder" = "#350030";
          };
          "editor.minimap.enabled" = false;
          "explorer.confirmDragAndDrop" = false;
        };
      };
    };
  };
}
