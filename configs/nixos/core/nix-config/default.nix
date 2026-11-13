{ lib, ... }:
{
  nix = {
    settings = {
      experimental-features = [
        "flakes"
        "nix-command"
      ];
      auto-optimise-store = true;

      # a flake's nixConfig would otherwise prompt mid-build to add caches
      accept-flake-config = false;

      # on 11/11/2026 at 7b86a8a these caches scored (misses trickle down):
      # cache:                    hits:   rate:
      # cache.nixos.org           1854    86.1%
      # nix-community.cachix.org  15      0.7%
      # cache.numtide.com         10      0.5%
      # cache.nixos-cuda.org      18      0.8%
      #
      # total hits:               1897    88.1%
      # total misses:             257     11.9%
      # total requests:           2154    100.0%
      substituters = lib.mkForce [
        # official nixpkgs cache (included by default but i set it manually here with mkForce):
        # response times: (2nd) ~75-215ms
        # overall cache hits: (1st) 86.1% 1854/2154
        "https://cache.nixos.org?priority=1"

        # nix-community cache:
        # response times: (1st) ~75ms
        # overall cache hits: (4th) 1.3% 27/2154
        "https://nix-community.cachix.org?priority=2"

        # numtide cache (for llm-agents input):
        # response times: (3rd) ~275ms
        # overall cache hits: (3rd) 53.4% 1150/2154
        "https://cache.numtide.com?priority=3"

        # nixos-cuda cache (because i have nixpkgs.config.cudaSupport enabled)
        # response times: (4th) ~750ms
        # overall cache hits: (2nd) 58.7% 1265/2154
        "https://cache.nixos-cuda.org?priority=4"
      ];
      trusted-public-keys = lib.mkForce [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
        "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
      ];
    };

    gc = {
      automatic = true;
      dates = "weekly";
      options = "-d";
    };
  };
}
