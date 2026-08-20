{ lib, pkgs }:

allInstances: currentLinksFile:
pkgs.writeShellApplication {
  name = "saves-folders-check";
  runtimeInputs = [
    pkgs.coreutils
    pkgs.findutils
  ];
  text = ''
        # replace a link at a saves path with a normal directory
        setup_normal_saves() {
          # path to saves folder
          saves=$1
          # user+group to own destination
          user=$2
          group=$3

          if [ ! -L "$saves" ]; then
            # echo "$saves is not a link. Don't need to delete."
    	return 0
          fi

          # echo "Deleting saves link at: $saves"
          rm -- "$saves"
          mkdir -p -- "$saves"
          chown -R "$user":"$group" "$saves"
        }

        # sets up a link to tmpfs for a saves folder
        setup_tmpfs_saves() {
          # path to saves folder
          saves=$1
          # path to tmpfs destination
          destination=$2
          # user+group to own destination
          user=$3
          group=$4

          if [ -L "$saves" ]; then
            # echo "$saves already a link. No need to delete."
            return 0
          fi

          if [ ! -e "$saves" ]; then
            # echo "$saves doesn't exist. No need to delete existing folder/link."
            return 0
          fi

          if [ -n "$(find "$saves" -mindepth 1 -maxdepth 1 ! -type l -print -quit)" ]; then
            echo "Real world folders in $saves. Move or delete them before linking." >&2
            return 1
          fi

          echo "Deleting empty $saves to make room for link."
          rm -r -- "$saves"
          echo "Creating saves folder at $destination."
          mkdir -p -- "$destination"
          chown "$user":"$group" "$destination"
          echo "Linking $saves to tmpfs location."
          ln -sfn "$destination" "$saves"
        }

        # remove links from a previous generation that are no longer declared
        delete_undeclared_links() {
          # previous declared links
          previous=$1
          # currently declared links
          current=$2
        
          if [ ! -f "$previous" ]; then
            return 0
          fi
        
        # diffing files with proper order. nix sorts them but ig just sort them again
          comm -23 \
            <(LC_ALL=C sort "$previous") \
            <(LC_ALL=C sort "$current") |
          while IFS= read -r link; do
            if [ -L "$link" ]; then
              echo "Removing link from previous generation: $link"
              rm -- "$link"
            fi
          done
        }

        create_link() {
          # link to create
          link=$1
          # target for link
          target=$2

          if [ ! -e "$target" ]; then
            echo "create_link: missing target, skipping: $target" >&2
    	return 0
          fi

          ln -sfn "$target" "$link"
        }

        links_state_file=/var/lib/tmpfs-symlink/current-links
        delete_undeclared_links "$links_state_file" ${currentLinksFile}

        ${lib.concatMapStringsSep "\n" (
          instance:
          let
            saves = lib.escapeShellArg instance.saves-path;
            user = lib.escapeShellArg instance.user;
            group = lib.escapeShellArg instance.group;
            dest = lib.escapeShellArg instance.saves-destination;
          in
          ''
            # ${instance.user}/${instance.name}
            ${
              if instance.tmpfs then
                "setup_tmpfs_saves ${saves} ${lib.escapeShellArg instance.tmpfs-path} ${user} ${group}"
              else
                "setup_normal_saves ${saves} ${user} ${group}"
            }

            ${lib.concatMapStringsSep "\n" (
              world: "create_link ${lib.escapeShellArg world.link-path} ${lib.escapeShellArg world.real-path}"
            ) instance.worlds}
          ''
        ) allInstances}

        install -Dm644 ${currentLinksFile} "$links_state_file"
  '';
}
