{
  lib,
  fetchFromGitHub,
  rustPlatform,
  libcosmicAppHook,
  flatpak,
  glib,
  just,
  openssl,
  pkg-config,
  stdenv,
  nix-update-script,
}:

rustPlatform.buildRustPackage {
  pname = "cosmic-store";
  version = "1.0.5-unstable-2026-02-06";

  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "cosmic-store";
    rev = "e1be45d002bdbb5c657afc60e29b809c909f41cd";
    hash = "sha256-352fPCHn4DFKuEglx+7RzU+pVqb1K2sNHRFNQbVeRCc=";
  };

  cargoHash = "sha256-0cn7/Mow9uAOAQZEUh7CZXNk9r4tvOeqjyCyJGtE2m4=";

  nativeBuildInputs = [
    libcosmicAppHook
    just
    pkg-config
  ];
  buildInputs = [
    glib
    flatpak
    openssl
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
    homepage = "https://github.com/pop-os/cosmic-store";
    description = "App Store for the COSMIC Desktop Environment";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [
      # lilyinstarlight
    ];
    platforms = lib.platforms.linux;
    mainProgram = "cosmic-store";
  };
}
