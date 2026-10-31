{
  ast-grep,
  fetchFromGitHub,
  lib,
  makeWrapper,
  python3,
  stdenvNoCC,
}:

let
  python = python3.withPackages (ps: [
    ps.mcp
    ps.pydantic
    ps.pyyaml
  ]);
in

stdenvNoCC.mkDerivation (_finalAttrs: {
  pname = "ast-grep-mcp";
  version = "0-unstable-2026-10-28";

  src = fetchFromGitHub {
    owner = "ast-grep";
    repo = "ast-grep-mcp";
    rev = "1e41164726d7ead57c8aa25f74946c4badba7f8a";
    hash = "sha256-ojES2CjlN2bTEfGmZJO4gj+juuRF8808kn6YuDpqnxQ=";
  };

  strictDeps = true;
  __structuredAttrs = true;

  nativeBuildInputs = [ makeWrapper ];

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    install -Dm644 main.py $out/lib/ast-grep-mcp/main.py

    # Without AST_GREP_PATH the server resolves a bare `ast-grep` off whatever
    # PATH it inherits.
    makeWrapper ${python.interpreter} $out/bin/ast-grep-mcp \
      --add-flags $out/lib/ast-grep-mcp/main.py \
      --set AST_GREP_PATH ${lib.getExe ast-grep}

    runHook postInstall
  '';

  meta = {
    description = "MCP server exposing ast-grep structural search and rule debugging";
    homepage = "https://github.com/ast-grep/ast-grep-mcp";
    license = lib.licenses.mit;
    mainProgram = "ast-grep-mcp";
    platforms = lib.platforms.all;
  };
})
