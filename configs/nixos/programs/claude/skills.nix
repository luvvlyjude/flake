{ lib, pkgs }:

let
  inherit (lib) genAttrs;

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
  ast-grep = ''
    ---
    name: ast-grep
    description: Use ast-grep for structural, language-aware code search instead of grep/manual file reads whenever navigating or refactoring code across a codebase. Triggers on "find all callers of X", "find every place that does Y pattern", "rename/refactor across files", "structural search", or before reaching for grep on anything more than a literal string. Falls back to ripgrep for pure text/comment/string searches ast-grep can't express.
    ---

    # ast-grep navigation

    `ast-grep` parses code into an AST and matches structural patterns, so it finds real occurrences of a construct instead of text that happens to look like it (skips comments/strings, respects language syntax). It is on `PATH` and runs inside the bash sandbox, so it needs no approval.

    ## When to reach for it
    - Locating a function/method definition or every call site across many files
    - Refactoring searches: "every place a struct/component is constructed with these fields"
    - Any pattern with "shape" (call with N args, import of X, JSX element with a prop) rather than a literal string

    Use plain `rg`/`grep` instead for literal strings, comments, config files, or one-off greps — don't reach for ast-grep just because it's available.

    ## Core commands

    Search without writing a config file:
    ```
    ast-grep run -p '<pattern>' [-l <lang>] [<path>]
    ```

    Metavariables in patterns:
    - `$NAME` matches a single node (identifier, expression, etc.)
    - `$$$ARGS` matches zero or more nodes (argument lists, statement lists)
    - Reuse the same `$NAME` twice in a pattern to require the same node in both places

    Examples:
    ```
    ast-grep run -p 'console.log($$$ARGS)' -l js
    ast-grep run -p 'def $NAME($$$ARGS):' -l python
    ast-grep run -p 'useState($$$ARGS)' -l tsx
    ```

    Add `--json` when you need to post-process matches (counts, dedupe, feed into another step) instead of reading raw text — keeps result parsing cheap.

    Rewriting across a codebase:
    ```
    ast-grep run -p '<pattern>' -r '<rewrite>' [-l <lang>] --update-all
    ```
    Only pass `--update-all` after confirming the plain search results look right — treat it like any other bulk edit that needs review.

    ## Efficiency notes
    - One `ast-grep run` over the whole repo replaces many rounds of `grep` + manual `Read` of candidate files — prefer it when a task would otherwise mean opening several files just to check "does this match the pattern."
    - Scope with `<path>` or `--globs` when the repo is large, rather than grepping the whole tree and filtering by hand afterward.
    - `-l <lang>` is optional (ast-grep infers it from the file extension) but pin it when scanning mixed-language directories to avoid cross-language false matches.
  '';
}
