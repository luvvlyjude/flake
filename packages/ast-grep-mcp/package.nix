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
  version = "0.1.0-unstable-2026-08-25";

  src = fetchFromGitHub {
    owner = "ast-grep";
    repo = "ast-grep-mcp";
    rev = "149e20d47bb7125fb0c1451feea2f48a98742034";
    hash = "sha256-G2bnsfmzpirQmcllr+wmrvR6n5exe/5OrHnfXDXoyPg=";
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
