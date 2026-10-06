workspace: {
  additionalDirectories = [
    workspace
    "/nix/store"
  ];

  blockReadsOutsideWorkingDirectories = true;

  defaultMode = "acceptEdits";

  allow = [
    "WebSearch"
    "WebFetch(domain:github.com)"
    "WebFetch(domain:raw.githubusercontent.com)"
    "WebFetch(domain:docs.rs)"
    "WebFetch(domain:devenv.sh)"
    "WebFetch(domain:classifier.dev)"
    "mcp__plugin_classifier_classifier__*"
    "mcp__plugin_classifier_classifier-docs__*"
    "mcp__plugin_hm_ast-grep__*"
    "mcp__plugin_hm_nixos__*"
  ];

  deny = [
    "Read(~/.config/gh/**)"
    "Read(~/.ssh/**)"
    "Read(//run/secrets.d/**)"
    "Read(//persist/sops/**)"
  ];
}
