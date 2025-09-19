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
  version = "0-unstable-2025-09-17";

  src = fetchFromGitHub {
    owner = "cosmic-utils";
    repo = "forecast";
    rev = "eb09f7131a0e6e31229a01c83892ef489bed917a";
    hash = "sha256-aNMt4CK6k/pepxSq6s8SLu4l2qXdpbMUaQ0AJ5KvU+E=";
  };

  cargoHash = "sha256-rSl09TD844DK5/8+wjQ07uvMMEwRznjyLSwWXvgnsn8=";

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
