{
  home-manager.sharedModules = [
    {
      programs.neovim = {
        enable = true;
        viAlias = true;
        vimAlias = true;
        vimdiffAlias = true;

        defaultEditor = true; # set nvim default with $EDITOR session variable
      };
    }
  ];
}
