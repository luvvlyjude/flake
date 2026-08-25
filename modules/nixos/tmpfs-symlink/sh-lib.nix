{ lib }:

{
  deleteLinksFromFile = file: ''
    if [ -f ${lib.escapeShellArg file} ]; then
      while IFS= read -r line; do
        if [ -L "$line" ]; then
          printf "Removing link: %s\n" "$line"
          rm -- "$line"
        fi
      done < ${lib.escapeShellArg file}
    fi
  '';

  createUserOwnedDirectory = user: directory: ''
    mkdir -p -- ${lib.escapeShellArg directory}
    chown ${lib.escapeShellArg user.name}:${lib.escapeShellArg user.group} ${lib.escapeShellArg directory}
  '';

  deleteEmptyDirectory = directory: ''
    if [ ! -L ${lib.escapeShellArg directory} ] && [ -d ${lib.escapeShellArg directory} ]; then
      if ! rmdir -- ${lib.escapeShellArg directory}; then
        printf "Error: ${lib.escapeShellArg directory} saves folder not empty. Move or delete existing files and folders before linking.\n" >&2
        exit 1
      fi
    fi
  '';

  createLink = target: link: ''
    if [ ! -L ${lib.escapeShellArg link} ] && [ ! -e ${lib.escapeShellArg link} ]; then
      if [ ! -e ${lib.escapeShellArg target} ]; then
        printf "Warning: Target world ${lib.escapeShellArg target} does not exist!\n" >&2
      fi
      printf "Creating link: ${lib.escapeShellArg link} -> ${lib.escapeShellArg target}\n"
      ln -sn ${lib.escapeShellArg target} ${lib.escapeShellArg link}
    fi
  '';

  installFileToPath = file: path: ''
    install -Dm644 ${lib.escapeShellArg file} ${lib.escapeShellArg path}
  '';
}
