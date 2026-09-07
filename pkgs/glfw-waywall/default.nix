# MOSTLY COPIED FROM NIXPKGS GLFW3 PACKAGE MODIFIED WITH HELP FROM CLAUDE
{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  pkg-config,
  wayland,
  wayland-scanner,
  libxkbcommon,
  libGL,
  vulkan-loader,
  libdecor,
  # libdecor is only dlopen'd to draw client-side decorations. Under waywall (and
  # under Jay generally) nothing ever sees them, and GLFW falls back to plain
  # xdg-shell when the module is missing. Off = one less runtime closure entry.
  withLibdecor ? false,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "glfw-waywall";
  version = "3.5.0-unstable-2026-07-09";

  src = fetchFromGitHub {
    owner = "glfw";
    repo = "glfw";
    rev = "463cf73610d911e8eff95ae345143137cf610be4";
    hash = "sha256-euVfSX/g1xVtz3FGieXcFHH/TC+jfxWXg151iqWXGoo=";
  };

  patches = [ ./glfw-waywall.patch ];

  outputs = [
    "out"
    "dev"
  ];

  # GLFW dlopens these by bare soname. There is no rpath involved, so on NixOS
  # they have to be rewritten to absolute store paths or nothing resolves.
  postPatch = ''
    substituteInPlace src/wl_init.c \
      --replace-fail '"libwayland-client.so.0"' '"${lib.getLib wayland}/lib/libwayland-client.so.0"' \
      --replace-fail '"libwayland-cursor.so.0"' '"${lib.getLib wayland}/lib/libwayland-cursor.so.0"' \
      --replace-fail '"libwayland-egl.so.1"' '"${lib.getLib wayland}/lib/libwayland-egl.so.1"' \
      --replace-fail '"libxkbcommon.so.0"' '"${lib.getLib libxkbcommon}/lib/libxkbcommon.so.0"'
  ''
  + lib.optionalString withLibdecor ''
    substituteInPlace src/wl_init.c \
      --replace-fail '"libdecor-0.so.0"' '"${lib.getLib libdecor}/lib/libdecor-0.so.0"'
  '';

  strictDeps = true;
  __structuredAttrs = true;

  nativeBuildInputs = [
    cmake
    pkg-config
    wayland-scanner
  ];

  # No wayland-protocols: the protocol XML files GLFW needs are vendored in
  # deps/wayland and generate_wayland_protocol() reads them from the source tree.
  buildInputs = [
    wayland
    libxkbcommon
  ];

  cmakeFlags = [
    (lib.cmakeBool "BUILD_SHARED_LIBS" true)
    (lib.cmakeBool "GLFW_BUILD_WAYLAND" true)
    (lib.cmakeBool "GLFW_BUILD_X11" false)
    (lib.cmakeBool "GLFW_BUILD_EXAMPLES" false)
    (lib.cmakeBool "GLFW_BUILD_TESTS" false)
    (lib.cmakeBool "GLFW_BUILD_DOCS" false)
  ];

  # Same problem as the wayland dlopens, but these are compile-time defines
  # rather than string literals. _GLFW_GLX_LIBRARY is deliberately absent: GLX
  # is X11-only and that backend isn't built.
  env.NIX_CFLAGS_COMPILE = toString [
    "-D_GLFW_EGL_LIBRARY=\"${lib.getLib libGL}/lib/libEGL.so.1\""
    "-D_GLFW_OPENGL_LIBRARY=\"${lib.getLib libGL}/lib/libGL.so.1\""
    "-D_GLFW_GLESV2_LIBRARY=\"${lib.getLib libGL}/lib/libGLESv2.so.2\""
    "-D_GLFW_VULKAN_LIBRARY=\"${lib.getLib vulkan-loader}/lib/libvulkan.so.1\""
  ];

  meta = {
    description = "Wayland-only GLFW with tesselslate's waywall patch, for Minecraft under waywall";
    homepage = "https://www.glfw.org/";
    license = lib.licenses.zlib;
    platforms = lib.platforms.linux;
  };
})
