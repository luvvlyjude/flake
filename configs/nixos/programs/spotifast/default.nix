{
  hm ={ pkgs, ... }: {
    home.packages = with pkgs; [
      spotifast
    ];
  };
}
