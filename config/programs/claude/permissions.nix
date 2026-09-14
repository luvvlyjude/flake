workspace: {
  additionalDirectories = [ workspace ];

  blockReadsOutsideWorkingDirectories = true;

  defaultMode = "acceptEdits";

  allow = [
    "WebSearch"
    "WebFetch(domain:github.com)"
    "WebFetch(domain:raw.githubusercontent.com)"
    "WebFetch(domain:docs.rs)"
    "WebFetch(domain:devenv.sh)"

    "mcp__plugin_hm_nixos__*"
  ];

  deny = [
    "Read(~/.ssh/**)"
    "Read(//run/secrets.d/**)"
    "Read(//persist/sops/**)"
  ];
}
