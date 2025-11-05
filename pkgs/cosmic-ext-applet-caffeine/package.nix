{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
  libcosmicAppHook,
  just,
  nix-update-script,
}:

rustPlatform.buildRustPackage {
  pname = "cosmic-ext-applet-caffeine";
  version = "0-unstable-2025-11-04";

  src = fetchFromGitHub {
    owner = "tropicbliss";
    repo = "cosmic-ext-applet-caffeine";
    rev = "1a4ab86d1db1ef294b2cfb24a07f068da0f715ae";
    hash = "sha256-8bu9a7CNAtxXV7VKw232ZwgMGOLwvPKVXWoVtX7RKKc=";
  };

  cargoHash = "sha256-9EUrO8JNU0FPrqT6WDE+jfVgQSgODK8rbNZLgUb26EQ=";

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
    "bin-src"
    "target/${stdenv.hostPlatform.rust.cargoShortTarget}/release/cosmic-ext-applet-caffeine"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    homepage = "https://github.com/tropicbliss/cosmic-ext-applet-caffeine";
    description = "Caffeine Applet for the COSMIC desktop";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [
      # lilyinstarlight
      HeitorAugustoLN
    ];
    platforms = lib.platforms.linux;
    mainProgram = "cosmic-ext-applet-caffeine";
  };
}
