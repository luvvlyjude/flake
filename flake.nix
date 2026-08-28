{
  description = "Jude's NixOS and Home-Manager Flake";

  inputs = {
    self.submodules = true;

    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/x86_64-linux";

    # unused right now
    # used for quickly getting new features after a release before it hits nixpkgs
    bcachefs-tools = {
      url = "github:koverstreet/bcachefs-tools";
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

    mcsr-nixos = {
      url = "https://git.uku3lig.net/uku/mcsr-nixos/archive/main.tar.gz";
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

      # copied from Ktrompfl's flake

      # Custom modules
      nixosModules = import ./modules/nixos;
      homeManagerModules = import ./modules/home-manager;

      # Your custom packages and modifications, exported as overlays
      overlays = import ./overlays { inherit inputs; };

      # Your custom packages
      # Accessible through 'nix build', 'nix shell', etc
      packages = eachSystem (
        system:
        import ./pkgs {
          inherit inputs;
          pkgs = nixpkgs-unstable.legacyPackages.${system};
        }
      );

      nixosConfigurations = {
        luvvly-pc = lib.nixosSystem {
          specialArgs = { inherit inputs; };

          modules = [
            ./systems/luvvly-pc
            inputs.self.nixosModules
          ];
        };
      };
    };
}
