{
  services.openssh = {
    enable = true;
    openFirewall = false;
  };

  # home-manager.sharedModules = [
  #   {
  #     programs.ssh = {
  #       enable = true;
  #       addKeysToAgent = "yes";
  #     };
  #   }
  # ];
}
