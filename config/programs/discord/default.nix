{ pkgs, ... }:

{
  # for discord tts i guess
  # services.speechd.enable = true;

  home-manager.sharedModules = [
    {
      programs.discord = {
        enable = true;

        package = pkgs.discord.override {
          enableAutoscroll = true;
          withTTS = false;
        };
      };
    }
  ];
}
