{
  lib,
  fetchFromGitHub,
  rustPlatform,
  libcosmicAppHook,
  bash,
  just,
  stdenv,
  nix-update-script,
}:

rustPlatform.buildRustPackage {
  pname = "cosmic-idle";
  version = "1.0.7-unstable-2026-02-13";

  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "cosmic-idle";
    rev = "c95d066b5b640509a6369634b669ca60dc50e168";
    hash = "sha256-0tcrOfVT5b57ev3b5F2U78F2QPGFwp94bqFVNyKH0Yk=";
  };

  cargoHash = "sha256-wAjFC6qAC3nllbnZf0KVaZTEztNYo6GTvwcp5FYmXLw=";

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

  postPatch = ''
    substituteInPlace src/main.rs --replace-fail '"/bin/sh"' '"${lib.getExe' bash "sh"}"'
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "epoch-(.*)"
    ];
  };

  meta = {
    homepage = "https://github.com/pop-os/cosmic-idle";
    description = "Idle daemon for the COSMIC Desktop Environment";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [
      # lilyinstarlight
    ];
    platforms = lib.platforms.linux;
    mainProgram = "cosmic-idle";
  };
}
