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
  version = "0-unstable-2025-08-25";

  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "cosmic-reader";
    rev = "d59faa6935122932c69a215d304e6f4882ac0727";
    hash = "sha256-J31z0bcrMw+vGDforOHFrBnQxYqmnZezqka1G1ktzfY=";
  };

  cargoHash = "sha256-whbFCj5r0+WfkKoOlzO/Y45UZgoNQ6HXdCbaaBcxtmI=";

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
