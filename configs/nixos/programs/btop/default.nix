{
  hm = { pkgs, ... }: {
    programs.btop = {
      enable = true;
      package = pkgs.btop-cuda;
      settings = {
        disks_filter = "exclude=/boot";
        shown_boxes = "cpu proc mem";
        swap_disk = false;
        update_ms = 500;
      };
    };
  };
}
