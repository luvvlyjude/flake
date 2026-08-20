let
  user = "jude";
  instances = ".local/share/PrismLauncher/instances";
  worlds = "mcsr/worlds/maps";
in
{
  # fileSystems."/home/${user}/mcsr/worlds/tmpfs" = {
  #   device = "tmpfs";
  #   fsType = "tmpfs";
  #   options = [
  #     "size=15%"
  #     "mode=0755"
  #     "uid=${user}"
  #     "gid=users"
  #   ];
  # };

  #  services.symlink-worlds = {
  #    enable = true;
  #
  #    users = {
  #      jude = {
  #        tmpfs = {
  #   enable = true;
  #   mount = "mcsr/worlds/tmpfs";
  #   size = "15%";
  # };
  #        instances = {
  #          seedqueue = {
  #            tmpfs = true;
  #            worlds = [
  #            ];
  #          };
  #        };
  #        common-worlds = [
  #          "${worlds}/Z__1.16"
  #          "${worlds}/Z__allalalalal"
  #          "${worlds}/Z__bella world"
  #          "${worlds}/Z__Builds"
  #          # "${worlds}/Z__Crafting Practice"
  #          # "${worlds}/Z__Crafting Practice v2"
  #          # "${worlds}/Z__FARM_WITH_DOOG"
  #          # "${worlds}/Z__friend smp 1"
  #          "${worlds}/Z__friend smp 2"
  #          "${worlds}/Z__friend smp 3"
  #          "${worlds}/Z__friend smp 4"
  #          # "${worlds}/Z__friend smp 5"
  #          "${worlds}/Z__friend smp 6"
  #          # "${worlds}/Z__Hardcore 3_0"
  #          "${worlds}/Z__Lama's Practice Map"
  #          # "${worlds}/Z__lava room mansion portal"
  #          # "${worlds}/Z__LBP 3.14.0"
  #          "${worlds}/Z__Mine a Chunk 1 51 28 200"
  #          # "${worlds}/Z__Overworld Practice v1"
  #          "${worlds}/Z__OW crafting Practice V2"
  #          "${worlds}/Z__PerchPractice"
  #          "${worlds}/Z__Portal Practice"
  #          "${worlds}/Z__Portal Practice v2"
  #          # "${worlds}/Z__REDSTONE"
  #          "${worlds}/Z__Ryguy2k4 End Practice v3.4.0-1.16.1"
  #          # "${worlds}/Z__Speedcrafting"
  #          "${worlds}/Z__zero_cycle_practice_astraf_nayoar"
  #        ];
  #      };
  #    };
  #  };
}
