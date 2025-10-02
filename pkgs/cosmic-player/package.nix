{
  lib,
  fetchFromGitHub,
  rustPlatform,
  libcosmicAppHook,
  alsa-lib,
  ffmpeg,
  glib,
  gst_all_1,
  libgbm,
  libglvnd,
  just,
  pkg-config,
  stdenv,
  pipewire,
  nix-update-script,
}:

rustPlatform.buildRustPackage {
  pname = "cosmic-player";
  version = "1.0.0-beta.1.1-unstable-2025-10-02";

  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "cosmic-player";
    rev = "c2ecc9cd6bab23399e1ba0d90f1dce496f872fc7";
    hash = "sha256-zifLjMNOgAui5SE4MT/xI7zskopZPFXP7gUv9DGIAk4=";
  };

  cargoHash = "sha256-DodFIfthiGFSvXWfPsPjFhNY6G7z3lb6pfc5HtUXhMo=";

  postPatch = ''
    substituteInPlace justfile --replace-fail '#!/usr/bin/env' "#!$(command -v env)"
  '';

  nativeBuildInputs = [
    libcosmicAppHook
    rustPlatform.bindgenHook
    just
    pkg-config
  ];

  buildInputs = [
    alsa-lib
    pipewire
    ffmpeg
    glib
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    libgbm
    libglvnd
  ];

  dontUseJustBuild = true;
  dontUseJustCheck = true;

  justFlags = [
    "--set"
    "prefix"
    (placeholder "out")
    "--set"
    "bin-src"
    "target/${stdenv.hostPlatform.rust.cargoShortTarget}/release/cosmic-player"
  ];

  postInstall = ''
    libcosmicAppWrapperArgs+=(--prefix GST_PLUGIN_SYSTEM_PATH_1_0 : "$GST_PLUGIN_SYSTEM_PATH_1_0")
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "epoch-(.*)"
    ];
  };

  meta = {
    homepage = "https://github.com/pop-os/cosmic-player";
    description = "Media player for the COSMIC Desktop Environment";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [
      # lilyinstarlight
    ];
    platforms = lib.platforms.linux;
    mainProgram = "cosmic-player";
  };
}
