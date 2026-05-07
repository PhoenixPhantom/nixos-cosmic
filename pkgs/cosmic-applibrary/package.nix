{
  lib,
  fetchFromGitHub,
  rustPlatform,
  libcosmicAppHook,
  just,
  stdenv,
  nix-update-script,
}:

rustPlatform.buildRustPackage {
  pname = "cosmic-applibrary";
  version = "1.0.12-unstable-2026-04-28";

  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "cosmic-applibrary";
    rev = "f2024ce95574cc3222ff6668ef378a63bee8993c";
    hash = "sha256-deE9xXvRSZWSEdKPJr1HuA/gVs0a22lAVRmUnhwpDJM=";
  };

  cargoHash = "sha256-uR0wm2+zmcec3esfYwgq4pRqSHkZnd3O8XhgnANf/1Q=";

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
    homepage = "https://github.com/pop-os/cosmic-applibrary";
    description = "Application Template for the COSMIC Desktop Environment";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [
      # lilyinstarlight
    ];
    platforms = lib.platforms.linux;
    mainProgram = "cosmic-app-library";
  };
}
