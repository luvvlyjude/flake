{
  services.smartd = {
    enable = true;
    # 7s ERC: bcachefs rebuilds from parity instead of stalling on a bad sector
    # APM 254: stops the HGSTs parking their heads every few seconds
    # standby off: never spin down, spin-ups wear more than spinning
    # 197+/198+: warn when bad-sector counts grow, not on every start
    defaults.autodetected = "-a -C 197+ -U 198+ -l scterc,70,70 -e apm,254 -e standby,off";
    notifications.systembus-notify.enable = true;
  };
}
