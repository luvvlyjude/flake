{
  home-manager.sharedModules = [
    ({ config, inputs, ... }: {
      imports = [
        inputs.zen-browser.homeModules.beta
      ];

      programs.zen-browser = {
        enable = true;
        setAsDefaultBrowser = true;

        profiles.${config.home.username} = {
          isDefault = true;

          # declaring entire browser config is a bit too much rn
          # containersForce = true; # delete containers not declared
          # pinsForce = true;
          # pinsForceAction = "demote"; # demote undeclared pinned tabs to normal tabs
          # spacesForce = true; # delete spaces not declared

          settings = {
            "general.autoScroll" = true;
            "zen.pinned-tab-manager.restore-pinned-tabs-to-pinned-url" = true;
            "zen.tabs.show-newtab-vertical" = false;
            "zen.theme.content-element-separation" = 0;
            "zen.view.compact.enable-at-startup" = true;
            "zen.view.compact.hide-toolbar" = true;
            "zen.view.sidebar-expanded" = false;
            "zen.welcome-screen.seen" = true;
          };
        };
      };
    })
  ];
}
