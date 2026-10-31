{ pkgs, ... }:
{
  # hosts attach their idle behavior with wantedBy + partOf idle.target
  systemd.user.targets.idle.Unit.Description = "User is idle";

  services.swayidle = {
    enable = true;
    timeouts = [
      {
        timeout = 300;
        command = "${pkgs.systemd}/bin/systemctl --user start idle.target";
        resumeCommand = "${pkgs.systemd}/bin/systemctl --user stop idle.target";
      }
    ];
  };
}
