{
  inputs,
  lib,
  pkgs,
}:

let
  inherit (lib) genAttrs;

  astGrepSkills = "${inputs.ast-grep-agent-skill}/ast-grep/skills";

  # Listed by hand rather than read off the store path: `builtins.readDir` on a
  # derivation output is import-from-derivation, which `nix flake check` refuses.
  # A subset: upstream ships 19, the rest assume a helpdesk, a marketplace or a
  # security team. Every name here costs its description in every session.
  classifierSkills = genAttrs [
    "downloads-and-inbox-sorter"
    "headline-filter-map-reduce"
    "log-and-error-bucketing"
    "model-and-skill-router"
    "prompt-injection-guard"
    "semantic-ci-lint"
    "tool-call-permission-gate"
  ] (name: "${pkgs.classifier-dev}/share/classifier-dev/skills/${name}");
in

classifierSkills
// {
  ast-grep = "${astGrepSkills}/ast-grep";
  ast-grep-outline = "${astGrepSkills}/outline";
}
