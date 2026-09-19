{
  fetchFromGitHub,
  lib,
  makeWrapper,
  nodejs,
  stdenvNoCC,
}:

# Pinned past cli-v0.1.3: the skills/ tree only exists on newer commits.
stdenvNoCC.mkDerivation (_finalAttrs: {
  pname = "classifier-dev";
  version = "0.1.3-unstable-2026-09-19";

  src = fetchFromGitHub {
    owner = "mrmps";
    repo = "classifier-dev";
    rev = "94f3b56a9353f53540f640e4336008dbcb1ed85e";
    hash = "sha256-3Ammv4Sh/O6dOB8OVfYnb32opMlVTuj9kwgqk8oFHKY=";
  };

  strictDeps = true;
  __structuredAttrs = true;

  nativeBuildInputs = [ makeWrapper ];

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    # classify.js reads ./package.json through import.meta.url for its version
    # string, so the two have to land in the same directory.
    install -Dm644 -t $out/lib/classifier-dev cli/classify.js cli/package.json

    # Without this the CLI polls the npm registry on startup and nags to
    # `npm i -g` itself, which cannot work for a store copy.
    makeWrapper ${lib.getExe nodejs} $out/bin/classify \
      --add-flags $out/lib/classifier-dev/classify.js \
      --set-default CLASSIFY_NO_UPDATE_CHECK 1

    # skills/ also holds a README, helper scripts and a _rejected/ tree. A
    # SKILL.md is what makes a directory an actual skill.
    mkdir -p $out/share/classifier-dev/skills
    for skill in skills/*/; do
      [ -e "$skill/SKILL.md" ] || continue
      cp -r "$skill" $out/share/classifier-dev/skills/
    done

    runHook postInstall
  '';

  meta = {
    description = "CLI and agent skills for classifier.dev zero-shot text classification";
    homepage = "https://classifier.dev";
    license = lib.licenses.mit;
    mainProgram = "classify";
    platforms = lib.platforms.all;
  };
})
