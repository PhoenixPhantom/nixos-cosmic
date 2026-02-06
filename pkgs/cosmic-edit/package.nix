{
  lib,
  fetchFromGitHub,
  rustPlatform,
  libcosmicAppHook,
  fontconfig,
  freetype,
  glib,
  just,
  libinput,
  pkg-config,
  stdenv,
  nix-update-script,
}:

rustPlatform.buildRustPackage rec {
  pname = "cosmic-edit";
  version = "1.0.5-unstable-2026-02-02";

  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "cosmic-edit";
    rev = "021a8e614eff652ee33c8923da6200649ff7f8e1";
    hash = "sha256-ico9i7NqNtmvz+mptuOc/d34WBxsJ4HI5A/daX/we/A=";
  };

  cargoHash = "sha256-c7TEjrGCop1KL6gGjXSXg0lmZi7xgpqxrjorrlnKwb4=";

  nativeBuildInputs = [
    libcosmicAppHook
    just
    pkg-config
  ];
  buildInputs = [
    glib
    libinput
    fontconfig
    freetype
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

  postPatch = ''
    substituteInPlace justfile --replace-fail '#!/usr/bin/env' "#!$(command -v env)"
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "epoch-(.*)"
    ];
  };

  meta = {
    homepage = "https://github.com/pop-os/cosmic-edit";
    description = "Text Editor for the COSMIC Desktop Environment";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [
      # lilyinstarlight
    ];
    platforms = lib.platforms.linux;
    mainProgram = "cosmic-edit";
  };
}
