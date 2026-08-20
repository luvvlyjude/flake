{ pkgs, ... }:

{
  home-manager.sharedModules = [
    {
      programs.fuzzel = {
        enable = true;
        # uncomment when codeberg back up and shi
        package = pkgs.fuzzel-git;

        settings = {
          main = {
            horizontal-pad = 10;
            vertical-pad = 7;
            inner-pad = 5;
          };
          colors = {
            background = "000000ff";
            text = "999999ff";
            prompt = "999999ff";
            input = "999999ff";
            match = "750050ff";
            selection = "350030ff";
            selection-text = "eeeeeeff";
            selection-match = "850060ff";
            border = "350030ff";
          };
          border = {
            radius = 0;
          };
        };
      };
    }
  ];
}
