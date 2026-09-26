workspace:
let
  mcpTools = [
    "ast-grep__*"
    "classifier__*"
    "nixos__*"
  ];
in
{
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
  ]
  # cli/zed name them differently
  ++ builtins.concatMap (tool: [
    "mcp__${tool}"
    "mcp__plugin_hm_${tool}"
  ]) mcpTools;

  deny = [
    "Read(~/.ssh/**)"
    "Read(//run/secrets.d/**)"
    "Read(//persist/sops/**)"
  ];
}
