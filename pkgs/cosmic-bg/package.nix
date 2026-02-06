{
  lib,
  fetchFromGitHub,
  cosmic-wallpapers,
  rustPlatform,
  libcosmicAppHook,
  just,
  nasm,
  stdenv,
  nix-update-script,
}:

rustPlatform.buildRustPackage {
  pname = "cosmic-bg";
  version = "1.0.5-unstable-2026-01-31";

  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "cosmic-bg";
    rev = "808a50e383685c2c8f3f41e7b96c14c96145327e";
    hash = "sha256-lD5lTYXBy+keee+VArtNHgCS9n737YKaW8Kg3tu+8o0=";
  };

  cargoHash = "sha256-+NkraWjWHIMIyktAUlp3q2Ot1ib1QRsBBvfdbr5BXto=";

  nativeBuildInputs = [
    libcosmicAppHook
    just
    nasm
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
    substituteInPlace config/src/lib.rs data/v1/all \
      --replace-fail '/usr/share/backgrounds/cosmic/orion_nebula_nasa_heic0601a.jpg' \
      "${cosmic-wallpapers}/share/backgrounds/cosmic/orion_nebula_nasa_heic0601a.jpg"
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "epoch-(.*)"
    ];
  };

  meta = {
    homepage = "https://github.com/pop-os/cosmic-bg";
    description = "Applies Background for the COSMIC Desktop Environment";
    license = lib.licenses.mpl20;
    maintainers = with lib.maintainers; [
      # lilyinstarlight
    ];
    platforms = lib.platforms.linux;
    mainProgram = "cosmic-bg";
  };
}
