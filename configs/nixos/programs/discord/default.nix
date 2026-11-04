{
  # for discord tts i guess
  # services.speechd.enable = true;

  hm = { config, pkgs, ... }: {
    programs.discord = {
      enable = true;

      package = pkgs.discord.override {
        enableAutoscroll = true;
        withTTS = false;
      };
    };

    # discord rewrites this at runtime and hm bitches when it's in the way
    home.file."${config.xdg.configHome}/discord/settings.json".force = true;
  };
}
