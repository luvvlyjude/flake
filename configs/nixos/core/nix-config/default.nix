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

      substituters = [
        # prebuilt cudaSupport packages, cache.nixos.org skips them
        "https://cache.nixos-cuda.org"
        # llm-agents; its own priority is 30, which would beat cache.nixos.org (40)
        "https://cache.numtide.com?priority=45"
      ];
      trusted-public-keys = [
        "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
        "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
      ];
    };

    gc = {
      automatic = true;
      dates = "weekly";
      options = "-d";
    };
  };
}
