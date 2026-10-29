{ pkgs, username, ... }:

{
  services.greetd = {
    enable = true;

    settings = {
      # first boot: log straight into jay, no password
      initial_session = {
        command = "jay run";
        user = username;
      };

      # after logging out of jay: text login prompt
      default_session.command = "${pkgs.greetd}/bin/agreety --cmd 'jay run'";
    };
  };
}
