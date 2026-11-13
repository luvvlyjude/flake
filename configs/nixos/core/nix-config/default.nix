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

      # on 11/12/2026 at nixpkgs d4f25a3 these caches scored (misses trickle down):
      # cache:                    hits:   rate:
      # cache.nixos.org           1843    86.0%
      # cache.numtide.com         12      0.6%
      # nix-community.cachix.org  13      0.6%
      # cache.nixos-cuda.org      18      0.8%
      #
      # total hits:               1886    88.0%
      # total misses:             256     12.0%
      # total requests:           2142    100.0%
      #
      # imap index from 1 and append priority string so order applies priority order
      substituters = lib.mkForce (
        lib.imap (i: url: "${url}?priority=${toString i}") [
          # official nixpkgs cache (included by default but i set it manually here with mkForce):
          # response times: (2nd) ~66ms
          # parallel speed: (3rd) ~116 MB/s nar, 38 MB/s wire
          # overall cache hits: (1st) 86.0% 1843/2142
          "https://cache.nixos.org"

          # numtide cache (for llm-agents input):
          # response times: (1st) ~22ms
          # parallel speed: (1st) ~179 MB/s nar, 52 MB/s wire
          # overall cache hits: (3rd) 58.9% 1261/2142
          "https://cache.numtide.com"

          # nix-community cache:
          # response times: (3rd) ~109ms
          # parallel speed: (2nd) ~120 MB/s nar, 36 MB/s wire
          # overall cache hits: (4th) 1.5% 32/2142
          "https://nix-community.cachix.org"

          # nixos-cuda cache (because i have nixpkgs.config.cudaSupport enabled)
          # response times: (4th) ~185ms
          # parallel speed: (4th) ~14 MB/s nar, 14 MB/s wire
          # overall cache hits: (2nd) 59.7% 1278/2142
          "https://cache.nixos-cuda.org"
        ]
      );
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
