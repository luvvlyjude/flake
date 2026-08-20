{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.symlink-worlds;
in
{
  options = {
    programs.symlink-worlds = {
      enable = lib.mkEnableOption "symlink-worlds";

      common-worlds = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        example = [ "mcsr/worlds/Portal Practice v2" ];
        description = ''
          	  World folders linked into all declared instances.

          	  List should be paths relative to $HOME.
          	'';
      };

      instances = lib.mkOption {
        type = lib.types.attrsWith {
          placeholder = "relative-instance-saves-path";
          elemType = (
            lib.types.submodule ({
              options.link = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                default = null;
                example = "/home/alice/mcsr/tmpfs";
                description = ''
                  		    Path to symlink this instance's saves folder to.

                  		    Path should be absolute.

                  		    Make sure this path is writable by your user.

                  		    This option can clobber your existing saves folder so
                  		    make sure you backup worlds from there that you want.

                  		    If the location is a mount, the mount must be active before
                  		    home-manager activation runs.
                  		    You can write a service in your NixOS configuration to ensure this:

                  		      systemd.services.home-manager-<user> = {
                  		        after = [ "<escaped-mount-path>.mount" ];
                  		        wants = [ "<escaped-mount-path>.mount" ];
                  		      };

                  		    Get the unit name:
                  		      'systemd-escape -p --suffix=mount /your/mount/point'
                  	          '';
              };

              options.worlds = lib.mkOption {
                type = lib.types.listOf lib.types.str;
                default = [ ];
                example = [ "mcsr/worlds/Instance Exclusive World" ];
                description = ''
                  	            World folders linked only into this instance.

                  	            List should be paths relative to $HOME.
                  	          '';
              };
            })
          );
        };
        default = { };
        example = {
          ".local/share/PrismLauncher/instances/seedqueue/minecraft/saves" = {
            link = "/home/alice/mcsr/tmpfs/seedqueue";
            worlds = [
              "mcsr/worlds/SeedQueue Exclusive World"
            ];
          };
        };
        description = ''
          	  Declare instances to link worlds into.

          	  Instances should be declared as a path to the instance's saves folder relative to $HOME.

          	  All instances declared will receive links to `programs.symlink-worlds.common-worlds`.
          	  Instances may have more specific worlds linked with the nested `worlds` list.
          	  Instances' saves folders may be linked to a different path using `link`.
          	'';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.user.tmpfiles.rules = builtins.concatLists (
      lib.mapAttrsToList
        # loop over instances
        (
          relative-instance-saves-path: attrs:
          let
            saves-path = "${config.home.homeDirectory}/${relative-instance-saves-path}";
            # normal saves dir or the linked dir depending on if `link` is declared or not
            saves-destination = if attrs.link != null then attrs.link else saves-path;
          in
          [ "d= \"${saves-destination}\" - - - - -" ]
          ++ lib.optionals (attrs.link != null) [ "L+ \"${saves-path}\" - - - - ${attrs.link}" ]
          ++
            map
              # create links for all worlds in this instance
              (
                relative-world-path:
                let
                  world-path = "${config.home.homeDirectory}/${relative-world-path}";
                  world-name = builtins.baseNameOf relative-world-path;
                in
                "L+ \"${saves-destination}/${world-name}\" - - - - ${world-path}"
              )
              (attrs.worlds ++ cfg.common-worlds)
        )
        cfg.instances
    );

    # clean old links and check for permission problems
    home.activation.symlinkWorldsCheck =
      lib.hm.dag.entryBetween [ "onFilesChange" ] [ "linkGeneration" ]
        (
          # post writeBoundary
          lib.concatStringsSep "\n" (
            lib.mapAttrsToList
              # loop over instances
              (
                relative-instance-saves-path: attrs:
                let
                  saves-path = "${config.home.homeDirectory}/${relative-instance-saves-path}";
                  saves-destination = if attrs.link != null then attrs.link else saves-path;
                in
                # delete all current links in `saves-destination`
                ''
                  	    saves_destination=${lib.escapeShellArg saves-destination}
                  	    if [ -d "$saves_destination" ]; then
                  	      run find "$saves_destination" -mindepth 1 -maxdepth 1 -type l -delete
                  	    fi
                  	  ''
                # check for any saves that might be clobbered and for bad permissions
                + lib.optionalString (attrs.link != null) ''
                  	    saves_path=${lib.escapeShellArg saves-path}
                  	    if [ -L "$saves_path" ]; then
                  	      :
                  	    elif [ -d "$saves_path" ] && [ -n "$(find "$saves_path" -mindepth 1 -maxdepth 1 ! -type l -print -quit)" ]; then
                  	      errorEcho "symlink-worlds: $saves_path contains worlds that would be clobbered!"
                  	      errorEcho "  Please check and clear the directory manually."
                  	      exit 1
                  	    fi
                  	    link_parent_path=$(dirname ${lib.escapeShellArg attrs.link})
                  	    if [ ! -d "$link_parent_path" ]; then
                  	      warnEcho "symlink-worlds: $link_parent_path doesn't exist. Mount may not be up yet."
                  	      warnEcho "  Rerunning tmpfiles linking may be required: 'systemd-tmpfiles --user --create'"
                  	    elif [ ! -w "$link_parent_path" ]; then
                  	      errorEcho "symlink-worlds: $link_parent_path is not writable by $USER."
                  	      errorEcho "  If it's a mount, mount with uid=/gid= for your user, otherwise 'chown' this folder."
                  	      exit 1
                  	    fi
                  	  ''
              )
              cfg.instances
          )
          # rerun tmpfiles rules to reapply all declared linked worlds
          + ''
            run ${pkgs.systemd}/bin/systemd-tmpfiles --user --create
          ''
        );
  };
}
