{
  home-manager.sharedModules = [
    {
      programs.btop = {
        enable = true;
        settings = {
          disks_filter = "exclude=/boot";
          shown_boxes = "cpu proc mem";
          swap_disk = false;
          update_ms = 500;
        };
      };
    }
  ];
}
