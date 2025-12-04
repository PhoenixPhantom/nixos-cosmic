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
  version = "1.0.0-beta.9-unstable-2025-12-04";

  src = fetchFromGitHub {
     owner = "pop-os";
     repo = "cosmic-files";
     rev = "083afbe0287c4755f4e85cfd83cd1824b3268a1e";
     hash = "sha256-DHmWXKd0EoiPj1mcuW74Pqo6SK7lFdKYrYQ7kb2CdDg=";
  };

  cargoHash = "sha256-WPBK7/7l+Z69AFrqnDL6XszUcBHuZdKsNZ31HS+Ol4o="; 

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
