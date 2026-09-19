{ pkgs, ... }:

{
  hm = hm: {
    home.preferXdgDirectories = true;

    home.packages = [
      pkgs.xdg-utils # xdg-open
    ];

    xdg = {
      # setup xdg home directories
      enable = true;
      cacheHome = hm.config.home.homeDirectory + "/.local/cache";
      mimeApps.enable = true;

      userDirs = {
        enable = true;
        # The recommended way to get these values is via the xdg-user-dir command or by processing $XDG_CONFIG_HOME/user-dirs.dirs directly in your application. However, some legacy applications still rely on the session variables.
        setSessionVariables = true;
        extraConfig = {
          SCREENSHOTS = "${hm.config.xdg.userDirs.pictures}/Screenshots";
        };
      };
    };
  };
}
