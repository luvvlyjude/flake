{
  flake.nixosModules.oo7 =
    { config, pkgs, ... }:
    {
      services.oo7.enable = true;

      # oo7 prompts over org.gnome.keyring.SystemPrompter, only gcr_3 ships it
      services.dbus.packages = [ pkgs.gcr_3 ];

      # autologin gives PAM no password, so unlock the keyring from sops
      sops.secrets."oo7/keyring-password" = { };
      systemd.services."user@".serviceConfig.LoadCredential = "oo7.keyring-encryption-password:${
        config.sops.secrets."oo7/keyring-password".path
      }";
    };
}
