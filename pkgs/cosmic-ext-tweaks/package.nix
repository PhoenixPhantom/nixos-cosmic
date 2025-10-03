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
  pname = "cosmic-ext-tweaks";
  version = "0.2.0-unstable-2025-10-03";

  src = fetchFromGitHub {
    owner = "cosmic-utils";
    repo = "tweaks";
    rev = "61379bcea2da343683e62255627fdbce3baa60c2";
    hash = "sha256-jQQHVWWcagrGwBCd1l/i0YBO9Go4zUFuYj2HGKcQev0=";
  };

  cargoHash = "sha256-yjif793almqWKLQS+r8BMXqrJqjBRYIvaQV3xsW66Lw=";

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
    "target/${stdenv.hostPlatform.rust.cargoShortTarget}/release/cosmic-ext-tweaks"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    homepage = "https://github.com/cosmic-utils/tweaks";
    description = "Tweaking tool for the COSMIC Desktop Environment";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [
      # lilyinstarlight
    ];
    platforms = lib.platforms.linux;
    mainProgram = "cosmic-ext-tweaks";
  };
}
