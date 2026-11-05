{
  fetchurl,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation {
  pname = "glfw-mcsr";
  version = "3.5.1";

  # Tracked build (rule A.8.4): waywall-patched glfw, not patchelf'd; Prism's LD_LIBRARY_PATH covers its dlopens.
  # sha512 matches hash for libglfw.so 3.5.1 in https://github.com/Minecraft-Java-Edition-Speedrunning/legal-builds/blob/main/legal-dlls.csv
  src = fetchurl {
    url = "https://github.com/JamiKettunen/mcsr-glfw/releases/download/20261019-v3.5.1/libglfw-x86_64.so";
    sha512 = "9c6f51924ca376ba13936157778de2e7e35be34c69ab904241db32266161f3184974e08daba73eeea91afbab329b23c8e088985845562946e3c015faca9ab036";
  };

  dontUnpack = true;
  # strip/patchelf would change the tracked binary
  dontFixup = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 $src $out/lib/libglfw.so
    runHook postInstall
  '';

  meta.platforms = [ "x86_64-linux" ];
}
