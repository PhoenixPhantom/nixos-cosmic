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
  version = "1.0.3-unstable-2026-01-16";

  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "cosmic-applibrary";
    rev = "6806d2c10406667830e4b1e9bc4d70c10c679b6f";
    hash = "sha256-3vIp+Vs4prsFFiTmjrUXoYqH27y6ccVlUQcP5ICFq3g=";
  };

  cargoHash = "sha256-I6C5PrIymU8vZ7LvmnSlFFIp0cvlP1umiFMyrAyYf4A=";

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
