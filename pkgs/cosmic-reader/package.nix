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
  version = "0-unstable-2026-08-24";

  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "cosmic-reader";
    rev = "42ea9431705e665b9daf7681ded5f726e1b0389e";
    hash = "sha256-Lu0kiEP7JOa9SLkg/VcYDAgmgURyzQ8HnOuxPWaI1nk=";
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
