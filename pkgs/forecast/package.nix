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
  version = "0-unstable-2025-09-04";

  src = fetchFromGitHub {
    owner = "cosmic-utils";
    repo = "forecast";
    rev = "9671eb42c35da6ceb8196db41a58b7d0929876cd";
    hash = "sha256-lwNjdblE/pRxhwAtRQiaXvx/UV6VbDiQeg/HZOZ2BYw=";
  };

  cargoHash = "sha256-mZ6nVQo83/o1fAVcHJGPqulBaQtE/8MJk3eLBAUoMmc=";

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
