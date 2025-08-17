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
  stdenv,
}:

rustPlatform.buildRustPackage {
  pname = "cosmic-reader";
  version = "0-unstable-2025-08-14";

  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "cosmic-reader";
    rev = "28ca9c41c763f79d5c0cd7d2e2d39c3877a5fcc7";
    hash = "sha256-TrbbznrV30XQ2ioEWXzF3ymz7LBsuoJ+RW/McFRnG98=";
  };

  cargoHash = "sha256-1+YmX3PpgUEodU6xRhEGW+G7dqHwzigIfvfTVvc2nPE=";

  nativeBuildInputs = [
    libcosmicAppHook
    pkg-config
    libclang.lib
    clang
    glibc
   ];

  buildInputs = [
    fontconfig
    glib
    clang-tools
    libxkbcommon
    poppler
    mupdf
  ];

  LIBCLANG_PATH="${libclang.lib}/lib";
  BINDGEN_EXTRA_CLANG_ARGS = "-isystem ${libclang.lib}/lib/clang/${lib.getVersion clang}/include";


  postInstall = ''
    cp target/${stdenv.hostPlatform.rust.cargoShortTarget}/release/cosmic-reader $out
    mkdir -p $out/share/applications
    echo "
[Desktop Entry]
Name=COSMIC Reader
Exec=cosmic-reader %u
Terminal=false
Type=Application
StartupNotify=true
Icon=com.system76.CosmicReader
Categories=COSMIC;Office;
Keywords=PDF;Reader;Viewer;
MimeType=application/pdf;application/epub+zip;
" >>  $out/share/applications/com.system76.CosmicReader.desktop
  '';


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
