{
  hm.programs.satty = {
    enable = true;

    settings = {
      general = {
        copy-command = "wl-copy";
        disable-notifications = true;
        default-hide-toolbars = true;
        initial-tool = "brush";
        actions-on-escape = [
          "save-to-clipboard"
          "exit"
        ];
      };
    };
  };
}
