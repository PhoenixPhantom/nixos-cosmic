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
  version = "0.1.3-unstable-2025-09-21";

  src = fetchFromGitHub {
    owner = "cosmic-utils";
    repo = "tweaks";
    rev = "0abd94eb76b6018bee9adddb345a55745d659af4";
    hash = "sha256-JWWKjaIxaq2XCOzht2Nl5oErG6D3xcJSYXlgSy0S42s=";
  };

  cargoHash = "sha256-ZFaL6qEKzSGZzOtcJX32wti0ivdA7CbYGREPFWZvxmc=";

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
