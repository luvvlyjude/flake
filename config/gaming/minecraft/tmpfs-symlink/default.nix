let
  worlds = "mcsr/worlds/maps";
in
{
  services.tmpfs-symlink = {
    enable = true;

    instances = [
      {
        saves = ".local/share/PrismLauncher/instances/seedqueue/minecraft/saves";
        size = "15%";
        tmpfs = true;
        user = "jude";
        worlds = map (world: "${worlds}/${world}") [
          "Z__1.16"
          "Z__allalalalal"
          "Z__bella world"
          "Z__Builds"
          "Z__Crafting Practice"
          "Z__Crafting Practice v2"
          "Z__FARM_WITH_DOOG"
          "Z__friend smp 1"
          "Z__friend smp 2"
          "Z__friend smp 3"
          "Z__friend smp 4"
          "Z__friend smp 5"
          "Z__friend smp 6"
          "Z__Hardcore 3_0"
          "Z__Lama's Practice Map"
          "Z__lava room mansion portal"
          "Z__LBP 3.14.0"
          "Z__Mine a Chunk 1 51 28 200"
          "Z__Overworld Practice v1"
          "Z__OW crafting Practice V2"
          "Z__PerchPractice"
          "Z__Portal Practice"
          "Z__Portal Practice v2"
          "Z__REDSTONE"
          "Z__Ryguy2k4 End Practice v3.4.0-1.16.1"
          "Z__Speedcrafting"
          "Z__zero_cycle_practice_astraf_nayoar"
        ];
      }
    ];
  };
}
