# After editing this file, test with: nix build .#glfw-mcsr --rebuild
# The output is fixed by its hash, so a plain build reuses the old result and skips your edit
{
  dpkg,
  fetchFromGitHub,
  fetchurl,
  lib,
  stdenvNoCC,
  version ? "3.5.1",
}:
let
  # libglfw.so rows of legal-dlls.csv, built by r0hkx/mcsr-glfw CI on ubuntu-24.04.
  # This package repeats that CI job; each "CI:" comment below names the step it replaces:
  # https://github.com/r0hkx/mcsr-glfw/blob/f0bd862aade75a2a8d80d3fd94fa2135b11bd3d8/.github/workflows/glfw-3.5.1-waywall.yml
  # sha512 is the legal hash from the csv; the build fails unless the .so matches it
  releases = {
    "3.4" = {
      sha512 = "5aa9dc21354770202efd01180c6925fd9bdbe6f1fdddd0b4c23fd7a65de3c287a96d290862094ecdbff3061c7d3d341b3891ea7ced402d4957247882828c6278";
      srcHash = "sha256-FcnQPDeNHgov1Z07gjFze0VMz2diOrpbKZCsI96ngz0=";
      narHash = "sha256-IIBny2O1Mqu4fOQhE8Bdh9SUtz53asv8Xa20JUgZEDw=";
    };
    "3.5.1" = {
      sha512 = "9c6f51924ca376ba13936157778de2e7e35be34c69ab904241db32266161f3184974e08daba73eeea91afbab329b23c8e088985845562946e3c015faca9ab036";
      srcHash = "sha256-Vwi7MbzrQmcsENez987/Ju7H0pz0tSV6YC0DqwGeQ+w=";
      narHash = "sha256-P9Q96QUsTBrUgbrHec/KMcJd3qQB3QCG89DaTBc0ctM=";
    };
  };
  release = releases.${version} or (throw "glfw-mcsr: no legal build for ${version}");

  # src/CMakeLists.txt order, which is the link order
  sources = [
    "context"
    "init"
    "input"
    "monitor"
    "platform"
    "vulkan"
    "window"
    "egl_context"
    "osmesa_context"
    "null_init"
    "null_monitor"
    "null_window"
    "null_joystick"
    "posix_module"
    "posix_time"
    "posix_thread"
    "x11_init"
    "x11_monitor"
    "x11_window"
    "xkb_unicode"
    "glx_context"
    "wl_init"
    "wl_monitor"
    "wl_window"
    "linux_joystick"
    "posix_poll"
  ];

  protocols = [
    "wayland"
    "viewporter"
    "xdg-shell"
    "idle-inhibit-unstable-v1"
    "pointer-constraints-unstable-v1"
    "relative-pointer-unstable-v1"
    "fractional-scale-v1"
    "xdg-activation-v1"
    "xdg-decoration-unstable-v1"
  ];

  # Only what changes the output bytes or runs the toolchain; hex sha256 as in the Packages index
  ubuntuDebs =
    lib.mapAttrsToList
      (
        path: sha256:
        fetchurl {
          # Launchpad keeps every published deb if the snapshot host goes away
          urls = [
            "https://snapshot.ubuntu.com/ubuntu/20261019T000000Z/pool/main/${path}"
            "https://launchpad.net/ubuntu/+archive/primary/+files/${baseNameOf path}"
          ];
          inherit sha256;
        }
      )
      {
        "b/binutils/binutils-x86-64-linux-gnu_2.42-4ubuntu2.10_amd64.deb" =
          "1e510a15f30208d39edcd840e48f26a77bbca7c417805eeccb1e3f7de198ef29";
        "b/binutils/libbinutils_2.42-4ubuntu2.10_amd64.deb" =
          "064dce00ce94e1fc2d33779cb0071088f4c8aac79e85345f2e78a020f7d14699";
        "b/binutils/libctf0_2.42-4ubuntu2.10_amd64.deb" =
          "7ec86d697c3668503c85f308a6832f092075b5880ad002f22185264da0bd4645";
        "b/binutils/libsframe1_2.42-4ubuntu2.10_amd64.deb" =
          "72093fb456864db55f1352bfa5e952a94f7abaff64e71dff1fbf001db1984564";
        "e/expat/libexpat1_2.6.1-2ubuntu0.6_amd64.deb" =
          "494b8e672f722130c6bca6a7bc4cc31a43ca891a31d60d868bfdd699a3c20b13";
        "g/gcc-13/cpp-13-x86-64-linux-gnu_13.3.0-6ubuntu2~24.04.1_amd64.deb" =
          "2ca48bf0c2d6465bc39322899715a85d934b4d7442dd5586a7bebbe3ce0f806b";
        "g/gcc-13/gcc-13-x86-64-linux-gnu_13.3.0-6ubuntu2~24.04.1_amd64.deb" =
          "a134b0319a82d14581b3a14820d2832af4ec9778ed8b9b4ddaeecfb0555ec325";
        "g/gcc-13/libgcc-13-dev_13.3.0-6ubuntu2~24.04.1_amd64.deb" =
          "cd689db2691edaa10f37329307292796bb599e722e0505c79e14caaa1fe9a93a";
        "g/gcc-14/libgcc-s1_14.2.0-4ubuntu2~24.04.1_amd64.deb" =
          "aa7fadbe33b78bcf99885318040601c550c208929565b179891d9a3cc2aa68cd";
        "g/gcc-14/libstdc++6_14.2.0-4ubuntu2~24.04.1_amd64.deb" =
          "a51f8de7829211db961a31f02158058ad1a95f92ac6d0a5dff6350e2821c54c0";
        "g/glibc/libc6-dev_2.39-0ubuntu8.9_amd64.deb" =
          "e13d5fcc1b2a86f75bca8e0026a8e39f24fe97ca86e92be79991f8697eb1306f";
        "g/glibc/libc6_2.39-0ubuntu8.9_amd64.deb" =
          "ff5557d99b51f761c4b7c92368b9cc45565eda17df9bf9eb4b134d09825008be";
        "g/gmp/libgmp10_6.3.0+dfsg-2ubuntu6.1_amd64.deb" =
          "285f8a505dfa8e1b33f357a9d8d3477ad35bf18c0b34771a6df4c25923f3ae0d";
        "i/icu/libicu74_74.2-1ubuntu3.1_amd64.deb" =
          "c9a70989678660eed9a1e904c74fa043da8bec8e2036856fc16e31ced79b04f8";
        "i/isl/libisl23_0.26-3build1.1_amd64.deb" =
          "4e040926e50fb961fae9bf95660189d468336a4a17bc321872c434fc8f777e7f";
        "j/jansson/libjansson4_2.14-2build2_amd64.deb" =
          "0cf79113f5d193ce9af2be2ff4b2c3b30dd4e55a0b6c47f7d28f6c849ff3aa60";
        "l/linux/linux-libc-dev_6.8.0-147.147_amd64.deb" =
          "fec8e4a308c03cd98dace67370a8d5a8031c36741796065c9f6e3f9548ab0cd2";
        "libx/libx11/libx11-dev_1.8.7-1ubuntu0.1_amd64.deb" =
          "467e28dafc2a51a59bf8615325e2e6bd42da63d3e346580a5baf14fdfde8a8e1";
        "libx/libxcursor/libxcursor-dev_1.2.1-1build1_amd64.deb" =
          "f49821ee3023c74dd5a612881d44bcc0ed4f08723124e7e56b57ad615e8e240e";
        "libx/libxext/libxext-dev_1.3.4-1build2_amd64.deb" =
          "b5bdb6724f228cb8eee8cf39cbbe1289dd3f8f06dd022748312df7844c94dcf2";
        "libx/libxfixes/libxfixes-dev_6.0.0-2build1_amd64.deb" =
          "069723527566ef0fc12738f63b789110c211b85bf96c3dbe9a94d9e77f5c479b";
        "libx/libxi/libxi-dev_1.8.1-1build1_amd64.deb" =
          "a1f0f0b4a8c1c43e5300871464080920859d3fa466ef46a584fec800fe890860";
        "libx/libxinerama/libxinerama-dev_1.1.4-3build1_amd64.deb" =
          "13a73fa50f9c575a04f64c8fa3df590c9ad81f3227a12832fca5caf63c2304b3";
        "libx/libxkbcommon/libxkbcommon-dev_1.6.0-1build1_amd64.deb" =
          "e0b2b61efbadc516303d3bf27ee7b397cfbff120a178f938dd6570d5b53bc359";
        "libx/libxml2/libxml2_2.9.14+dfsg-1.3ubuntu3.10_amd64.deb" =
          "c5a065f85c1e6f605741e365e40cad71c3ceb0e85e2791400bd35b8896e12ad1";
        "libx/libxrandr/libxrandr-dev_1.5.2-2build1_amd64.deb" =
          "8c0ee697a9052f36103529ebe4ace096da845e2b517f39d206302f3c7709ec6f";
        "libx/libxrender/libxrender-dev_0.9.10-1.1build1_amd64.deb" =
          "839558c9de049636e13e22e409c04f3226614abf176c4a3b7088058576d74848";
        "libz/libzstd/libzstd1_1.5.5+dfsg2-2build1.1_amd64.deb" =
          "dfcf25061e07aad7efd3f4f880ba5ad4d4d09ebe7fc8cc77ab6b8a161d6d4727";
        "m/mpclib3/libmpc3_1.3.1-1build1.1_amd64.deb" =
          "cebe6098bb3d66fdacac9dc6fe406a651216d9c00f27c3f9c159d15d96cdf864";
        "m/mpfr4/libmpfr6_4.2.1-1build1.1_amd64.deb" =
          "aebc1c8b69a1f98bb43dfc268daecd181116dbf40b13ee4e822eb4bdd52b493a";
        "w/wayland/libwayland-bin_1.22.0-2.1build1_amd64.deb" =
          "9562788fd1d795f703bac4c50187b08071521d58c113b18d598df82e0ebe7ff6";
        "w/wayland/libwayland-dev_1.22.0-2.1build1_amd64.deb" =
          "7e03d8f017d364c7e08d3e294f53ec993e9ffd71e4975cbad11ad07f55047ebe";
        "x/xorgproto/x11proto-dev_2023.2-1_all.deb" =
          "3bf13a2ffb79ecd4014d438936014e5863f79eb59ebf76e8f43356271c90e7ce";
        "x/xz-utils/liblzma5_5.6.1+really5.4.5-1ubuntu0.3_amd64.deb" =
          "d2eabd41ca77d2c2dd9d5d4ef478cccb64ffde6279c47cf4699a857d46785a52";
        "z/zlib/zlib1g_1.3.dfsg-3.1ubuntu2.2_amd64.deb" =
          "84b9cf5752b29c9f92c27cd4c4ba9bbcc70b5ccf9b1b515421a28ae23212e273";
      };
in
stdenvNoCC.mkDerivation {
  pname = "glfw-mcsr";
  inherit version;

  # CI: git clone glfw && git checkout <version>
  src = fetchFromGitHub {
    owner = "glfw";
    repo = "glfw";
    rev = version;
    hash = release.srcHash;
  };

  # CI: curl glfw.patch && git apply glfw.patch
  patches = [
    (fetchurl {
      url = "https://raw.githubusercontent.com/tesselslate/waywall/ad569de1ddae6b034c7095795a42f044746a55a7/contrib/glfw.patch";
      hash = "sha256-kl3DFYVfUe4CPBSuh3DJxDpYvg8vFxq8F+RR9sG+EHE=";
    })
  ];

  nativeBuildInputs = [ dpkg ];

  # Fixed output: the store path ignores nixpkgs, so lock updates never rebuild it.
  # It also skips edits while the path exists; test changes with nix-build --check
  outputHashMode = "recursive";
  outputHash = release.narHash;

  # CI: sudo apt install ...
  # Unpacks Ubuntu's compiler and headers into a plain folder instead of installing them
  configurePhase = ''
    runHook preConfigure

    # Extract every deb into ./ubuntu, like a mini Ubuntu filesystem
    root=$NIX_BUILD_TOP/ubuntu
    for deb in ${toString ubuntuDebs}; do
      dpkg-deb -x "$deb" "$root"
    done
    # Ubuntu's /lib -> /usr/lib links; the linker looks for libc under /lib
    ln -s usr/lib "$root/lib"
    ln -s usr/lib64 "$root/lib64"

    # Ubuntu's programs can't start here: they look for Ubuntu's system libraries in /lib.
    # wrap renames a program to .real and puts a tiny script in its place that starts it
    # with Ubuntu's own loader and the libraries from ./ubuntu (patchelf would corrupt gcc)
    ubuntuLibs=$root/usr/lib/x86_64-linux-gnu
    wrap() {
      mv "$1" "$1.real"
      printf '#!%s\nexec %s --library-path %s --argv0 "$0" %s "$@"\n' \
        ${stdenvNoCC.shell} "$ubuntuLibs/ld-linux-x86-64.so.2" "$ubuntuLibs" "$1.real" > "$1"
      chmod +x "$1"
    }
    gcc=$root/usr/bin/x86_64-linux-gnu-gcc-13
    scanner=$root/usr/bin/wayland-scanner
    wrap "$gcc"
    wrap "$scanner"
    wrap "$root/usr/libexec/gcc/x86_64-linux-gnu/13/cc1"
    wrap "$root/usr/libexec/gcc/x86_64-linux-gnu/13/collect2"
    wrap "$root/usr/bin/x86_64-linux-gnu-as"
    wrap "$root/usr/bin/x86_64-linux-gnu-ld.bfd"

    # gcc looks up the assembler and linker by their plain names
    mkdir "$NIX_BUILD_TOP/bin"
    ln -s "$root/usr/bin/x86_64-linux-gnu-as" "$NIX_BUILD_TOP/bin/as"
    ln -s "$root/usr/bin/x86_64-linux-gnu-ld.bfd" "$NIX_BUILD_TOP/bin/ld"
    export PATH=$NIX_BUILD_TOP/bin:$PATH

    runHook postConfigure
  '';

  # CI: cmake -S . -B build ... && make
  # The commands make would run, written out by hand. Every flag comes from
  # src/CMakeLists.txt in the glfw tag: https://github.com/glfw/glfw/blob/3.5.1/src/CMakeLists.txt
  buildPhase = ''
    runHook preBuild

    # 1. Turn Wayland's XML protocol files into C headers GLFW includes
    mkdir -p build
    for p in ${toString protocols}; do
      "$scanner" client-header "deps/wayland/$p.xml" "build/$p-client-protocol.h"
      "$scanner" private-code "deps/wayland/$p.xml" "build/$p-client-protocol-code.h"
    done

    # 2. Compile each .c file. --sysroot uses Ubuntu's headers from ./ubuntu, and the
    #    prefix map stores the CI's folder path in the binary instead of ours
    for s in ${toString sources}; do
      "$gcc" --sysroot="$root" \
        -fmacro-prefix-map="$PWD=/home/runner/work/mcsr-glfw/mcsr-glfw/glfw" \
        -D_DEFAULT_SOURCE -D_GLFW_BUILD_DLL -D_GLFW_WAYLAND -D_GLFW_X11 -DHAVE_MEMFD_CREATE \
        -I"$PWD/include" -I"$PWD/src" -I"$PWD/build" \
        -fPIC -fvisibility=hidden -Wall -std=c99 \
        -c "$PWD/src/$s.c" -o "build/$s.o"
    done

    # 3. Link them into the shared library
    "$gcc" --sysroot="$root" -fPIC -shared -Wl,-soname,libglfw.so.3 \
      -o build/libglfw.so ${lib.concatMapStringsSep " " (s: "build/${s}.o") sources} -lm -lrt -ldl

    # 4. Fail unless it's byte-identical to the legal build
    echo "${release.sha512}  build/libglfw.so" | sha512sum -c

    runHook postBuild
  '';

  # CI: upload glfw/build/src/libglfw.so
  installPhase = ''
    runHook preInstall
    install -Dm755 build/libglfw.so $out/lib/libglfw.so
    runHook postInstall
  '';

  # strip/patchelf would change the legal bytes
  dontFixup = true;

  meta = {
    description = "Speedrun-legal waywall-patched GLFW, rebuilt from source";
    platforms = [ "x86_64-linux" ];
  };
}
