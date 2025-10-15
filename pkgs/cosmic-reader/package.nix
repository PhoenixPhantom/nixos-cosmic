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
  version = "0-unstable-2025-10-12";

  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "cosmic-reader";
    rev = "35bf8c556bbff415e1149d7cbf267d2b6ff6f300";
    hash = "sha256-721Y1VbBPWMXcH8rt5AyO2GFV1Q70kHnG4TAPmeX414=";
  };

  cargoHash = "sha256-4ofAtZN3FpYwNahinldALbdEJA5lDwa+CUsVIISnSTc=";

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
