# { pkgs, ... }:

{
  # for discord tts i guess
  # services.speechd.enable = true;

  hm = { pkgs, ... }: {
    programs.discord = {
      enable = true;

      package = pkgs.discord.override {
        enableAutoscroll = true;
        withTTS = false;
      };
    };
  };
}
