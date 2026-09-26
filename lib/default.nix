# PLEASE PARDON THIS FILE
# while most of the functions in this file were originally written by me
# claude helped abstracting them out of their original locations into this
# lib file and took it upon herself to generate docs-slop for everything
# i can not vouch for the docs-slop or any small changes made elsewhere
# but all functions were working flawlessly when i originally wrote them! :3

# System agnostic on purpose: helpers that need a package take it as an argument.
{ lib, ... }:

let
  inherit (lib)
    attrNames
    attrValues
    concatMap
    concatStringsSep
    count
    filter
    hasSuffix
    isFunction
    mapAttrsToList
    mergeAttrsList
    pathExists
    readDir
    removeSuffix
    toLower
    unique
    ;
in
rec {
  jay = importWith { inherit lib; } ./jay.nix;

  # import a file, applying `args` only if it is a function
  importWith =
    args: path:
    let
      value = import path;
    in
    if isFunction value then value args else value;

  # merge attrsets, throwing on a repeated name
  # only reads names, never values, so it is safe inside an overlay
  mergeDisjoint =
    context: parts:
    let
      shared = filter (name: count (part: part ? ${name}) parts > 1) (unique (concatMap attrNames parts));
    in
    if shared == [ ] then
      mergeAttrsList parts
    else
      throw "${context}: ${concatStringsSep ", " shared} defined more than once";

  # flat `name -> path` set of the .nix files under `directory`
  #   - a subdirectory holding `marker` is one entry named after it
  #   - any other .nix file is one entry named after the file
  #   - other subdirectories are flattened
  #   - default.nix is never an entry, whatever `marker` is
  # names come from paths only, so an overlay can be built from this without
  # going circular
  collectNixFiles =
    {
      directory,
      marker ? "default.nix",
    }:
    let
      isNixFile = hasSuffix ".nix";
      removeNixSuffix = removeSuffix ".nix";

      processDirectory =
        directory:
        let
          markerPath = directory + "/${marker}";
        in
        if pathExists markerPath then
          { "${baseNameOf directory}" = markerPath; }
        else
          processContents directory;

      # the entries of a directory that only holds entries, and is not one itself
      processContents =
        directory:
        mergeDisjoint "collectNixFiles: ${toString directory}" (
          mapAttrsToList (
            name: type:
            let
              path = directory + "/${name}";
            in
            if type == "directory" then
              processDirectory path
            else if type == "regular" then
              processFile path
            else
              throw ''
                collectNixFiles: Unsupported file type ${type} at path ${toString path}
              ''
          ) (readDir directory)
        );

      processFile =
        path:
        let
          file = baseNameOf path;
        in
        if !isNixFile file || file == "default.nix" then { } else { "${removeNixSuffix file}" = path; };
    in
    processContents directory;

  # every module under `directory`, plus `default` importing them all
  collectModules =
    directory:
    let
      modules = collectNixFiles { inherit directory; };
    in
    modules
    // {
      default.imports = attrValues modules;
    };

  # `$out/icons/<name>.png` inside `package`
  iconPath = package: name: "${package}/icons/${toLower name}.png";

  # iconPath in the escaped form fuzzel wants for a dmenu entry icon
  escapedIconPath = package: name: ''\0icon\x1f${iconPath package name}'';
}
