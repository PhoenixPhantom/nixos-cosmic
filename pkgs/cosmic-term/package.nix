{
  lib,
  fetchFromGitHub,
  libcosmicAppHook,
  fontconfig,
  freetype,
  just,
  libinput,
  pkg-config,
  rustPlatform,
  stdenv,
  nix-update-script,
}:

rustPlatform.buildRustPackage {
  pname = "cosmic-term";
  version = "1.0.4-unstable-2026-01-27";

  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "cosmic-term";
    rev = "cdeaeeddc930ae9e2901377e6faf414c2767bc13";
    hash = "sha256-ilGVJtht3/xgKjhlolkmcU2x9odYwnjRwJqHxCkh1Lg=";
  };

  cargoHash = "sha256-cg9eMaxWcxdw2uFWvtUU2zwCkr92WoJF92/Dryk9moA=";

  nativeBuildInputs = [
    libcosmicAppHook
    just
    pkg-config
  ];

  buildInputs = [
    fontconfig
    freetype
    libinput
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
    homepage = "https://github.com/pop-os/cosmic-term";
    description = "Terminal for the COSMIC Desktop Environment";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [
      # lilyinstarlight
    ];
    platforms = lib.platforms.linux;
    mainProgram = "cosmic-term";
  };
}
