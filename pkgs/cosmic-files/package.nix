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
  version = "1.9.0-unstable-2026-09-23";

  src = fetchFromGitHub {
     owner = "pop-os";
     repo = "cosmic-files";
     rev = "d1f0af78e64f9e8ddb52c486913d53a234ce3cf2";
     hash = "sha256-QtCiyTkPPnN2fWTlX0y4Pxn43sn3djYN9IIv+O9ihKs=";
  };

  cargoHash = "sha256-cqDRvByVLR3pcoTvQUeEjtAx+E2NSJQoZRlp6jOkfoI="; 

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
