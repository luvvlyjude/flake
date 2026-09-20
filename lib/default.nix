# PLEASE PARDON THIS FILE
# while most of the functions in this file were originally written by me
# claude helped abstracting them out of their original locations into this
# lib file and took it upon herself to generate docs-slop for everything
# i can not vouch for the docs-slop or any small changes made elsewhere
# but all functions were working flawlessly when i originally wrote them! :3

# Flake-wide helper functions.
#
# Everything here is system agnostic: nothing takes a package, so this set can
# be built once from `nixpkgs.lib` and shared by the flake outputs, the
# overlays, the modules and the packages alike. Helpers that need a package
# take it as an argument instead, see `iconPath`.
{ lib, ... }:

let
  inherit (lib)
    attrNames
    attrValues
    concatMap
    concatMapStringsSep
    concatStringsSep
    count
    escapeShellArg
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

  /**
    Import a file, applying `args` to it only if it turns out to be a function.

    Lets a set of files be imported uniformly when some of them need arguments
    and some are plain values, so a file that stops needing its arguments does
    not become a call site change. Named after `callPackageWith`, not to be
    confused with `lib.modules.importApply`, which is module specific.

    Takes `args` first so it can be bound once and reused:
    `importWith commonArgs`.

    # Type
    ```
    importWith :: AttrSet -> Path -> Any
    ```

    # Example
    ```nix
    # ./takes-args.nix is `{ inputs, ... }: { ... }`
    # ./plain.nix      is `{ imports = [ ]; }`
    map (importWith commonArgs) [ ./takes-args.nix ./plain.nix ]
    => [ { ... } { imports = [ ]; } ]
    ```
  */
  importWith =
    args: path:
    let
      value = import path;
    in
    if isFunction value then value args else value;

  /**
    Merge a list of attribute sets, throwing if any name is claimed twice.

    Use wherever separate pieces each contribute part of one set and nothing
    else is there to catch an accidental overlap: the jay settings parts, or a
    package collector merging one set per directory entry.

    The check only reads attribute names, never values, so it is safe to use
    while building an overlay.

    # Type
    ```
    mergeDisjoint :: String -> [ AttrSet ] -> AttrSet
    ```

    # Example
    ```nix
    mergeDisjoint "jay config" [ { a = 1; } { b = 2; } ]
    => { a = 1; b = 2; }

    mergeDisjoint "jay config" [ { a = 1; } { a = 2; } ]
    => error: jay config: a defined more than once
    ```
  */
  mergeDisjoint =
    context: parts:
    let
      shared = filter (name: count (part: part ? ${name}) parts > 1) (unique (concatMap attrNames parts));
    in
    if shared == [ ] then
      mergeAttrsList parts
    else
      throw "${context}: ${concatStringsSep ", " shared} defined more than once";

  /**
    Walk a directory into a flat attribute set of `.nix` files, named by path.

    The shared half of this flake's two collectors: it decides what exists and
    what it is called, never what it becomes, so the caller maps the paths to
    modules, packages or anything else. `marker` is the file that makes a
    directory a single entry rather than a container.

    Rules:
      - a subdirectory holding `marker` is one entry, named after the
        directory, and is not descended into
      - any other `.nix` file is one entry, named after the file
      - other subdirectories are flattened, so nesting is for organization only
      - `default.nix` is never an entry, so the recipe calling this does not
        collect itself
      - duplicate names throw, see [`mergeDisjoint`](#mergeDisjoint)

    The collected directory is always a container, never an entry itself.

    Names come from paths only, no value is ever read. That is what makes this
    safe to build an overlay from: an overlay's attribute names have to be
    knowable without evaluating any package, or the package set goes circular.

    # Type
    ```
    collectNixFiles :: { directory :: Path, marker :: String } -> AttrSet
    ```

    # Example
    ```nix
    # ./packages holds default.nix, glfw-waywall/package.nix and
    # jay-scripts/jay-tray-power.nix
    collectNixFiles {
      directory = ./packages;
      marker = "package.nix";
    }
    => {
         glfw-waywall = ./packages/glfw-waywall/package.nix;
         jay-tray-power = ./packages/jay-scripts/jay-tray-power.nix;
       }
    ```
  */
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

  /**
    Collect every module under a directory, plus a `default` importing them all.

    The module equivalent of `composeManyExtensions`: each file becomes its own
    named module so it can be consumed on its own, and `default` is the whole
    directory at once. See [`collectNixFiles`](#collectNixFiles) for how a
    directory is named and flattened.

    Modules stay unimported paths, so nothing is evaluated until the module
    system reaches it and every error message keeps its file name. The module
    system keys modules by path, so a module listed here that is also imported
    by one of its neighbours is only evaluated once.

    # Type
    ```
    collectModules :: Path -> AttrSet
    ```

    # Example
    ```nix
    # ./modules/nixos holds default.nix, gaming.nix and steam/default.nix
    collectModules ./modules/nixos
    => {
         gaming = ./modules/nixos/gaming.nix;
         steam = ./modules/nixos/steam/default.nix;
         default = {
           imports = [ ./modules/nixos/gaming.nix ./modules/nixos/steam/default.nix ];
         };
       }
    ```
  */
  collectModules =
    directory:
    let
      modules = collectNixFiles { inherit directory; };
    in
    modules
    // {
      default.imports = attrValues modules;
    };

  /**
    Quote a list of shell arguments and join them with spaces.

    For building a command line inside a shell script without worrying about
    spaces or quotes in any single argument.

    # Type
    ```
    mkShellArgs :: [ String ] -> String
    ```

    # Example
    ```nix
    mkShellArgs [ "--expire-time=5000" "two words" ]
    => "'--expire-time=5000' 'two words'"
    ```
  */
  mkShellArgs = concatMapStringsSep " " escapeShellArg;

  /**
    Path to an icon inside a package laid out as `$out/icons/<name>.png`.

    Takes the package rather than closing over one, so this stays free of
    anything system specific. Partially apply it once per script:
    `getIcon = iconPath luvvly-assets;`.

    # Type
    ```
    iconPath :: Package -> String -> String
    ```

    # Example
    ```nix
    iconPath luvvly-assets "Poweroff"
    => "/nix/store/...-luvvly-assets/icons/poweroff.png"
    ```
  */
  iconPath = package: name: "${package}/icons/${toLower name}.png";

  /**
    An icon path in the escaped form fuzzel expects for a dmenu entry, so an
    entry can carry its own icon.

    # Type
    ```
    escapedIconPath :: Package -> String -> String
    ```

    # Example
    ```nix
    escapedIconPath luvvly-assets "Reboot"
    => "\0icon\x1f/nix/store/...-luvvly-assets/icons/reboot.png"
    ```
  */
  escapedIconPath = package: name: ''\0icon\x1f${iconPath package name}'';
}
