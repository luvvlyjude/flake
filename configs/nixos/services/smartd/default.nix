{
  services.smartd = {
    enable = true;
    # 7s ERC: bcachefs rebuilds from parity instead of stalling on a bad sector
    # APM 254: stops the HGSTs parking their heads every few seconds
    # 197+/198+: warn when bad-sector counts grow, not on every start
    defaults.autodetected = "-a -C 197+ -U 198+ -l scterc,70,70 -e apm,254";
    notifications.systembus-notify.enable = true;
  };
}
