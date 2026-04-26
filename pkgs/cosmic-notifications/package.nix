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
  version = "1.0.11-unstable-2026-04-14";

  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "cosmic-notifications";
    rev = "dbd0658f0dc2671f32f514261bd9b3fa664264bd";
    hash = "sha256-/q+OIkKxqsLK2b9jjwDyVEkdNy0Xav3t4DicD3GeQD8=";
  };

  cargoHash = "sha256-+yNXOKZYWoR3yK1ulNRStJZbNTEDsKErL1N1wNiYsOM=";

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
