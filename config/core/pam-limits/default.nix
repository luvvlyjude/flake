{
  # allow users processes to request nice or real-time priority
  # specifically for waywall requesting scheduler priority without stripping LD_PRELOAD
  security.pam.loginLimits = [
    {
      domain = "@users";
      item = "nice";
      type = "-";
      value = "-20";
    }
    {
      domain = "@users";
      item = "rtprio";
      type = "-";
      value = "99";
    }
  ];
}
