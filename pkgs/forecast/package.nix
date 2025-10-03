{
  lib,
  fetchFromGitHub,
  libcosmicAppHook,
  rustPlatform,
  just,
  openssl,
  pkg-config,
  stdenv,
  nix-update-script,
}:

rustPlatform.buildRustPackage {
  pname = "forecast";
  version = "0-unstable-2025-10-02";

  src = fetchFromGitHub {
    owner = "cosmic-utils";
    repo = "forecast";
    rev = "e8a67baa0022c606cf53ae3772cf107c140d416f";
    hash = "sha256-/58EGC0asbLSDAMAUmqcxSBAgEERc65/lH8h3IY4nzk=";
  };

  cargoHash = "sha256-aiKxgUnW711c2vhXDKVt0USTUZD6CyWB3tT6UzjqNSg=";

  nativeBuildInputs = [
    libcosmicAppHook
    just
    pkg-config
  ];

  buildInputs = [
    openssl
  ];

  dontUseJustBuild = true;
  dontUseJustCheck = true;

  justFlags = [
    "--set"
    "prefix"
    (placeholder "out")
    "--set"
    "bin-src"
    "target/${stdenv.hostPlatform.rust.cargoShortTarget}/release/cosmic-ext-forecast"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    homepage = "https://github.com/cosmic-utils/forecast";
    description = "Weather forecast for the COSMIC Desktop Environment";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [
      # lilyinstarlight
    ];
    platforms = lib.platforms.linux;
    mainProgram = "cosmic-ext-forecast";
  };
}
