{
  lib,
  fetchFromGitHub,
  rustPlatform,
  libcosmicAppHook,
  nix-update-script,
  pkg-config,
  libxkbcommon,
  fontconfig,
  libclang,
  glib,
  glibc,
  clang-tools,
  clang,
  poppler,
  mupdf,
  gumbo,
  leptonica,
  tesseract,
  harfbuzz,
  jbig2dec,
  just,
  stdenv,
}:

rustPlatform.buildRustPackage {
  pname = "cosmic-reader";
  version = "0-unstable-2026-11-24";

  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "cosmic-reader";
    rev = "34e36871d628cb35db7dcf89d6066593c2568382";
    hash = "sha256-vKEs0Is2GcLMbLEXeopX1GNJj1waDIjtXksZZh3+3AQ=";
  };

  cargoHash = "sha256-DPGpGWzAgdpHp3qzksLtLnfqk+DJsaukdT2ekFFiGaM=";

  nativeBuildInputs = [
    libcosmicAppHook
    pkg-config
    libclang.lib
    clang
    glibc
    just
   ];

  buildInputs = [
    fontconfig
    glib
    clang-tools
    libxkbcommon
    gumbo
    tesseract
    leptonica
    jbig2dec
    harfbuzz
    poppler
    mupdf
  ];

  LIBCLANG_PATH="${libclang.lib}/lib";
  BINDGEN_EXTRA_CLANG_ARGS = "-isystem ${libclang.lib}/lib/clang/${lib.getVersion clang}/include";

  dontUseJustBuild = true;
  dontUseJustCheck = true;

  justFlags = [
    "--set"
    "prefix"
    (placeholder "out")

    "--set"
    "bin-src"
    "./target/${stdenv.hostPlatform.rust.cargoShortTarget}/release/cosmic-reader"
  ];


  passthru.updateScript = nix-update-script {
    # TODO: uncomment when there are actual tagged releases
    #extraArgs = [ "--version-regex" "epoch-(.*)" ];
  };

  meta = {
    homepage = "https://github.com/pop-os/cosmic-reader";
    description = "PDF reader for the COSMIC Desktop Environment";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [
      # lilyinstarlight
    ];
    platforms = lib.platforms.linux;
    mainProgram = "cosmic-reader";
  };
}
