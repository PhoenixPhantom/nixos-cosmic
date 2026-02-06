{
  lib,
  fetchFromGitHub,
  libcosmicAppHook,
  fontconfig,
  freetype,
  just,
  libinput,
  pkg-config,
  rustPlatform,
  stdenv,
  nix-update-script,
}:

rustPlatform.buildRustPackage {
  pname = "cosmic-term";
  version = "1.0.5-unstable-2026-02-06";

  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "cosmic-term";
    rev = "d7dcb707c0d8be3ab5aed3378de261c52708a253";
    hash = "sha256-HVrBLdiyghJ8DVnuaKRDPjPBgZd4jgf7XfoIew0uIv8=";
  };

  cargoHash = "sha256-eWa3TLYxzUd8xS9M5BUFEwZznQxIyBfbxGJtUBPaEAM=";

  nativeBuildInputs = [
    libcosmicAppHook
    just
    pkg-config
  ];

  buildInputs = [
    fontconfig
    freetype
    libinput
  ];

  dontUseJustBuild = true;
  dontUseJustCheck = true;

  justFlags = [
    "--set"
    "prefix"
    (placeholder "out")
    "--set"
    "cargo-target-dir"
    "target/${stdenv.hostPlatform.rust.cargoShortTarget}"
  ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "epoch-(.*)"
    ];
  };

  meta = {
    homepage = "https://github.com/pop-os/cosmic-term";
    description = "Terminal for the COSMIC Desktop Environment";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [
      # lilyinstarlight
    ];
    platforms = lib.platforms.linux;
    mainProgram = "cosmic-term";
  };
}
