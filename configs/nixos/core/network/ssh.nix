{
  services.openssh = {
    enable = true;
    openFirewall = false;
  };

  # hm.imports = [
  #   {
  #     programs.ssh = {
  #       enable = true;
  #       addKeysToAgent = "yes";
  #     };
  #   }
  # ];
}
