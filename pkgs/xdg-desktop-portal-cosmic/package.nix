{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  libcosmicAppHook,
  cosmic-wallpapers,
  coreutils,
  util-linux,
  libgbm,
  pipewire,
  pkg-config,
  gst_all_1,
  nix-update-script,
}:

rustPlatform.buildRustPackage {
  pname = "xdg-desktop-portal-cosmic";
  version = "1.0.0-beta.9-unstable-2025-11-21";

  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "xdg-desktop-portal-cosmic";
    rev = "31b7a1aa36f1a11c7bd1a14a6da3d87b9edca7d1";
    hash = "sha256-4rNHZcAq/LafUPywZ9XdpXr9wVFOBWkUvnCFwT+3lFA=";
  };

  cargoHash = "sha256-0PsiB/xvePSi5o1eRUgCq02UAGzuBQEe8+LlFJi5814=";

  separateDebugInfo = true;

  nativeBuildInputs = [
    libcosmicAppHook
    rustPlatform.bindgenHook
    pkg-config
    util-linux
  ];
  buildInputs = [
    libgbm
    pipewire
  ];
  checkInputs = [ gst_all_1.gstreamer ];

  postPatch = ''
    substituteInPlace src/screenshot.rs src/widget/screenshot.rs \
      --replace-fail '/usr/share/backgrounds/pop/kate-hazen-COSMIC-desktop-wallpaper.png' '${cosmic-wallpapers}/share/backgrounds/cosmic/orion_nebula_nasa_heic0601a.jpg'
  '';

  dontCargoInstall = true;

  makeFlags = [
    "CARGO_TARGET_DIR=target/${stdenv.hostPlatform.rust.cargoShortTarget}"
    "prefix=${placeholder "out"}"
  ];
  
  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "epoch-(.*)"
    ];
  };

  meta = {
    homepage = "https://github.com/pop-os/xdg-desktop-portal-cosmic";
    description = "XDG Desktop Portal for the COSMIC Desktop Environment";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [
      # lilyinstarlight
    ];
    mainProgram = "xdg-desktop-portal-cosmic";
    platforms = lib.platforms.linux;
  };
}
