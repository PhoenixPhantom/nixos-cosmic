{
  lib,
  fetchFromGitHub,
  rustPlatform,
  libcosmicAppHook,
  just,
  stdenv,
  which,
  nix-update-script,
}:

rustPlatform.buildRustPackage {
  pname = "cosmic-notifications";
  version = "1.0.0-beta.4-unstable-2025-10-20";

  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "cosmic-notifications";
    rev = "32c94572eb9d65b27afac37e791c31213cb5dc55";
    hash = "sha256-cr8nG9Mj2CZNj+SgOYFScPVAvj71z3jTxCfbQoTJjqs=";
  };

  cargoHash = "sha256-kLvfZBHJbVSceqKuB9XFshTH4Sl54hKfm8H90RUszKk=";

  nativeBuildInputs = [
    libcosmicAppHook
    just
    which
  ];

  dontUseJustBuild = true;
  dontUseJustCheck = true;

  justFlags = [
    "--set"
    "prefix"
    (placeholder "out")
    "--set"
    "bin-src"
    "target/${stdenv.hostPlatform.rust.cargoShortTarget}/release/cosmic-notifications"
  ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "epoch-(.*)"
    ];
  };

  meta = {
    homepage = "https://github.com/pop-os/cosmic-notifications";
    description = "Notifications for the COSMIC Desktop Environment";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [
      # lilyinstarlight
    ];
    platforms = lib.platforms.linux;
    mainProgram = "cosmic-notifications";
  };
}
