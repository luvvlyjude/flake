workspace: {
  enabled = true;
  autoAllowBashIfSandboxed = true;

  excludedCommands = [
    "sudo *"
    "nixos-rebuild *"
    "nh *"
    "systemctl *"
    "wl-copy *"
    "wl-paste *"
  ];

  network = {
    allowedDomains = [
      "cache.nixos.org"
      "cache.numtide.com"
      "channels.nixos.org"
      "nixos.org"
      "search.nixos.org"
      "*.cachix.org"

      "github.com"
      "api.github.com"
      "codeload.github.com"
      "*.githubusercontent.com"

      "crates.io"
      "*.crates.io"
      "docs.rs"
      "doc.rust-lang.org"
      "registry.npmjs.org"
      "pypi.org"
      "files.pythonhosted.org"

      "classifier.dev"
      "context7.com"
      "*.context7.com"
      "devenv.sh"
    ];

    allowAllUnixSockets = true;
  };

  filesystem = {
    denyRead = [ "/" ];

    allowRead = [
      "/nix"
      "/bin"
      "/etc"
      "/run"
      "/usr"
      workspace

      "~/.config/git"
      "~/.config/direnv"
      "~/.cargo"
    ];

    allowWrite = [
      workspace
      "~/.cache/nix"
      "~/.cargo"
      "~/.cache/uv"
      "~/.cache/ruff"
      "~/.julia"
    ];
  };
}
