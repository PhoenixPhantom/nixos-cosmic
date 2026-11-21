{
  lib,
  fetchFromGitHub,
  rustPlatform,
  libcosmicAppHook,
  stdenv,
  glib,
  just,
  nix-update-script,
}:

rustPlatform.buildRustPackage rec {
  pname = "cosmic-files";
  version = "1.11.0-unstable-2026-11-19";

  src = fetchFromGitHub {
     owner = "pop-os";
     repo = "cosmic-files";
     rev = "84a32e1eed33b1e017c8a653bfe1c2d5a13a711a";
     hash = "sha256-bp2z2Pmb6NZDJEbZFCAag1SmjSWmUGVUhKdVF3nGvAc=";
  };

  cargoHash = "sha256-H0T/5PP9RSOUG7OW+rD/7b6dAjDVePGDhJN1ENr76Pc="; 

  nativeBuildInputs = [
    libcosmicAppHook
    just
    rustPlatform.bindgenHook
  ];
  buildInputs = [ 
    glib
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

  buildPhase = ''
    runHook preBuild

    baseCargoBuildFlags="$cargoBuildFlags"

    cargoBuildFlags="$baseCargoBuildFlags --package cosmic-files"
    runHook cargoBuildHook

    cargoBuildFlags="$baseCargoBuildFlags --package cosmic-files-applet"
    runHook cargoBuildHook

    runHook postBuild
  '';

  checkPhase = ''
    runHook preCheck

    baseCargoTestFlags="$cargoTestFlags"

    cargoTestFlags="$baseCargoTestFlags --package cosmic-files"
    runHook cargoCheckHook

    cargoTestFlags="$baseCargoTestFlags --package cosmic-files-applet"
    runHook cargoCheckHook

    runHook postCheck
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "epoch-(.*)"
    ];
  };

  meta = {
    homepage = "https://github.com/pop-os/cosmic-files";
    description = "File Manager for the COSMIC Desktop Environment";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [
      # lilyinstarlight
    ];
    platforms = lib.platforms.linux;
    mainProgram = "cosmic-files";
  };
}
