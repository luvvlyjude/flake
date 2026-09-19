{
  description = "Jude's Flake :3";

  inputs = {
    self.submodules = true;

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/x86_64-linux";

    crane.url = "github:ipetkov/crane";

    # source only, for pkgs/ninjabrain-box (see ./overlays)
    ktrompfl = {
      url = "github:Ktrompfl/nix-config";
      flake = false;
    };

    # used for quickly getting new features after a release before it hits nixpkgs
    bcachefs-tools = {
      url = "github:koverstreet/bcachefs-tools/v1.39.6";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        crane.follows = "crane";
        rust-overlay.follows = "rust-overlay";
        treefmt-nix.follows = "treefmt-nix";
      };
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    jay = {
      url = "github:mahkoh/jay";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        crane.follows = "crane";
        rust-overlay.follows = "rust-overlay";
      };
    };

    jay-screenshot = {
      url = "github:Ktrompfl/jay-screenshot";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.jay.follows = "jay";
    };

    jay-tray-item = {
      url = "github:luvvlyjude/jay-tray-item";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # omitting follows costs a second nixpkgs evaluation but guarantees binary cache hits
    llm-agents.url = "github:numtide/llm-agents.nix";

    mcsr-nixos = {
      url = "https://git.uku3lig.net/luvvlyjude/mcsr-nixos/archive/tmpfs-symlink.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs =
    inputs:
    let
      baseArgs = {
        inherit inputs;
        inherit (inputs) self;
        inherit (inputs.nixpkgs) lib;
      };

      # built before others so they can comsum it :3
      luvvlyLib = import ./lib baseArgs;

      commonArgs = baseArgs // {
        inherit luvvlyLib;
      };

      # attr set here saves reevaluating in each use of perSystem if it had been a function
      # applies flake's overlays and some config so that everything agrees on what pkgs is
      systemsPkgsMap = inputs.nixpkgs.lib.genAttrs (import inputs.systems) (
        system:
        import inputs.nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [ inputs.self.overlays.default ];
        }
      );

      importOutput = luvvlyLib.importWith commonArgs;

      importPerSystemOutput =
        file:
        inputs.nixpkgs.lib.mapAttrs (
          system: pkgs: luvvlyLib.importWith (commonArgs // { inherit pkgs system; }) file
        ) systemsPkgsMap;
    in
    {
      # custom lib functions
      # imported/passed basically everywhere through args or specialArgs or callPackage
      lib = luvvlyLib;

      checks = importPerSystemOutput ./checks;
      formatter = importPerSystemOutput ./formatter;

      # custom packages
      # auto discovered from ./packages
      # accessible through 'nix build', 'nix shell', etc
      # packages r sourced from this flake's overlays output so all overlays apply
      packages = importPerSystemOutput ./packages;

      # custom packages, package additions, and modifications exported as overlays
      # 'default' combines all overlays, 'additions' and 'modifications' r separated
      overlays = importOutput ./overlays;

      # all nixos configurations
      # auto discovered from ./configs/nixos/systems
      nixosConfigurations = importOutput ./configs/nixos;

      # custom modules
      # auto discovered from ./modules/{nixos,home}
      # '.default' combines all modules for each, all exposed separately as well
      nixosModules = importOutput ./modules/nixos;
      homeModules = importOutput ./modules/home;
    };
}
