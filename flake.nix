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

    # source only, for claude plugins (see ./modules/pieces/development/ai/claude)
    ast-grep-agent-skill = {
      url = "github:ast-grep/agent-skill";
      flake = false;
    };
    classifier-dev = {
      url = "github:mrmps/classifier-dev";
      flake = false;
    };
    humanizer = {
      url = "github:blader/humanizer";
      flake = false;
    };
    ponytail = {
      url = "github:DietrichGebert/ponytail";
      flake = false;
    };

    # bcachefs-tools = {
    #   url = "github:koverstreet/bcachefs-tools/v1.39.7";
    #   inputs = {
    #     nixpkgs.follows = "nixpkgs";
    #     crane.follows = "crane";
    #     rust-overlay.follows = "rust-overlay";
    #     treefmt-nix.follows = "treefmt-nix";
    #   };
    # };

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    import-tree.url = "github:denful/import-tree";

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

    sops-nix = {
      url = "github:Mic92/sops-nix";
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

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);
}
