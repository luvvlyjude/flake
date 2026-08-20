{
  home-manager.sharedModules = [
    (
      {
        config,
        inputs,
        pkgs,
        ...
      }:
      let
        mcsrPkgs = inputs.mcsr-nixos.packages.${pkgs.stdenv.hostPlatform.system};
      in
      {
        home.packages = [
          mcsrPkgs.modcheck
        ];

        home.file = {
          ".config/modcheck.json" = {
            text = builtins.toJSON {
              filepath = "${config.home.homeDirectory}/.local/share/PrismLauncher/instances";
            };
          };
        };
      }
    )
  ];
}
