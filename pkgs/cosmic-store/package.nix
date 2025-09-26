{
  lib,
  fetchFromGitHub,
  rustPlatform,
  libcosmicAppHook,
  flatpak,
  glib,
  just,
  openssl,
  pkg-config,
  stdenv,
  nix-update-script,
}:

rustPlatform.buildRustPackage {
  pname = "cosmic-store";
  version = "1.0.0-beta.1.1-unstable-2025-09-24";

  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "cosmic-store";
    rev = "57542dcafe41a575c9353d9286e53504768dd601";
    hash = "sha256-KlXFFoUEa0YTQDEJHMrbWOIEsSnXvJNzzaEFYR83t9s=";
  };

  cargoHash = "sha256-xdNYQB/zmndnMAkstwJ6Z2uk0fXli3gIYHchUq/3u6k=";

  nativeBuildInputs = [
    libcosmicAppHook
    just
    pkg-config
  ];
  buildInputs = [
    glib
    flatpak
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
    "target/${stdenv.hostPlatform.rust.cargoShortTarget}/release/cosmic-store"
  ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "epoch-(.*)"
    ];
  };

  meta = {
    homepage = "https://github.com/pop-os/cosmic-store";
    description = "App Store for the COSMIC Desktop Environment";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [
      # lilyinstarlight
    ];
    platforms = lib.platforms.linux;
    mainProgram = "cosmic-store";
  };
}
