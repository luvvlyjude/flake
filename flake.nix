{
  description = "Jude's Flake :3";

  inputs = {
    self.submodules = true;

    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/x86_64-linux";

    ktrompfl-old = {
      url = "github:Ktrompfl/nix-config/88b987fd205e956037e7ab1471fdd7261a808bad";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      inputs.crane.follows = "crane";
      inputs.flake-parts.follows = "flake-parts";
      inputs.rust-overlay.follows = "rust-overlay";
      inputs.jay.follows = "jay";
      inputs.systems.follows = "systems";
    };
    ktrompfl = {
      url = "github:Ktrompfl/nix-config";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      inputs.crane.follows = "crane";
      inputs.flake-parts.follows = "flake-parts";
      inputs.rust-overlay.follows = "rust-overlay";
      inputs.jay.follows = "jay";
      inputs.systems.follows = "systems";
    };

    # used right now
    # used for quickly getting new features after a release before it hits nixpkgs
    bcachefs-tools = {
      url = "github:koverstreet/bcachefs-tools/v1.39.4";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      inputs.crane.follows = "crane";
      inputs.flake-parts.follows = "flake-parts";
      inputs.rust-overlay.follows = "rust-overlay";
      inputs.treefmt-nix.follows = "treefmt-nix";
    };

    crane = {
      url = "github:ipetkov/crane";
    };

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs-unstable";
    };

    home-manager = {
      # home-manager/master for unstable | home-manager/nixos-##.## for stable
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    jay = {
      url = "github:mahkoh/jay";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      inputs.crane.follows = "crane";
      inputs.rust-overlay.follows = "rust-overlay";
    };

    jay-tray-item = {
      url = "github:luvvlyjude/jay-tray-item";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    mcsr-nixos = {
      url = "https://git.uku3lig.net/luvvlyjude/mcsr-nixos/archive/tmpfs-symlink.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs-unstable,
      systems,
      treefmt-nix,
      ...
    }:
    let
      inherit (nixpkgs-unstable) lib;
      eachSystem = lib.genAttrs (import systems);

      user = "jude";
      mapNixosSystems =
        nixosSystems:
        lib.mapAttrs (
          name:
          { extraModules }:
          lib.nixosSystem {
            specialArgs = { inherit inputs user; };

            modules = [
              { networking.hostName = name; }
              ./config/core
              ./systems/${name}
            ]
            ++ extraModules;
          }
        ) nixosSystems;

      # nixpkgs with this flake's overlays applied. The `packages` output goes
      # through it so that `nix build .#foo` and the hosts, which apply the
      # same overlay in ./system, cannot disagree about what `foo` is.
      pkgsFor =
        system:
        import nixpkgs-unstable {
          inherit system;
          config.allowUnfree = true;
          overlays = [ self.overlays.default ];
        };

      treefmt =
        system:
        treefmt-nix.lib.evalModule nixpkgs-unstable.legacyPackages.${system} {
          projectRootFile = "flake.nix";
          programs.nixfmt.enable = true;
          programs.stylua.enable = true;
        };
    in
    {
      formatter = eachSystem (system: (treefmt system).config.build.wrapper);

      # Custom modules
      nixosModules.default = import ./modules/nixos;
      homeManagerModules.default = import ./modules/home-manager;

      # Your custom packages and modifications, exported as overlays
      overlays.default = import ./overlays { inherit inputs; };

      # Your custom packages
      # Accessible through 'nix build', 'nix shell', etc
      packages = eachSystem (
        system:
        import ./pkgs {
          inherit inputs;
          pkgs = pkgsFor system;
        }
      );

      nixosConfigurations = mapNixosSystems {
        luvvly-pc = {
          extraModules = [ ];
        };
      };
    };
}
