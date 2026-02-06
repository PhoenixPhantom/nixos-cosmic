{
  lib,
  fetchFromGitHub,
  libcosmicAppHook,
  rustPlatform,
  just,
  stdenv,
  nix-update-script,
}:

rustPlatform.buildRustPackage {
  pname = "cosmic-ext-calculator";
  version = "0.2.0-unstable-2026-02-03";

  src = fetchFromGitHub {
    owner = "cosmic-utils";
    repo = "calculator";
    rev = "46b4401641047cba1d429e7a99dcc8dd83bb8ac9";
    hash = "sha256-+5W42snEtRO3QmtnVAy/5FOtfihvtr5KLwb4Z2uiFN4=";
  };

  cargoHash = "sha256-8VJM393w6UINv5WAfBWPfCPut5Y4sk7tO75sv59wGF0=";

  nativeBuildInputs = [
    libcosmicAppHook
    just
  ];

  dontUseJustBuild = true;
  dontUseJustCheck = true;

  justFlags = [
    "--set"
    "prefix"
    (placeholder "out")
    "--set"
    "bin-src"
    "target/${stdenv.hostPlatform.rust.cargoShortTarget}/release/cosmic-ext-calculator"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    homepage = "https://github.com/cosmic-utils/calculator";
    description = "Calculator for the COSMIC Desktop Environment";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [
      # lilyinstarlight
    ];
    platforms = lib.platforms.linux;
    mainProgram = "cosmic-ext-calculator";
  };
}
