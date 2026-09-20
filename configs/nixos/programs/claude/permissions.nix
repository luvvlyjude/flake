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
    "WebFetch(domain:classifier.dev)"

    "mcp__ast-grep__*"
    "mcp__classifier__*"
    "mcp__nixos__*"
  ];

  deny = [
    "Read(~/.ssh/**)"
    "Read(//run/secrets.d/**)"
    "Read(//persist/sops/**)"
  ];
}
