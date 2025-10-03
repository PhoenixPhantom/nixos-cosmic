{
  lib,
  fetchFromGitHub,
  libcosmicAppHook,
  rustPlatform,
  just,
  stdenv,
  nix-update-script,
}:

rustPlatform.buildRustPackage rec {
  pname = "cosmic-ext-applet-clipboard-manager";
  version = "0.1.0-unstable-2025-09-29";

  src = fetchFromGitHub {
    owner = "cosmic-utils";
    repo = "clipboard-manager";
    rev = "da0a8b5dca84e8bd6018b72f9ab80da901fc956d";
    hash = "sha256-FK6GNSl8LDKl6AAJTvOffbG9RdUbufmWxd8nI8Uxw6A=";
  };

  cargoHash = "sha256-cEP4R5AlMLL7mTX6qH7hVLqX83lsQda0lxipQ/FjNkQ=";

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
    "env-dst"
    "${placeholder "out"}/etc/profile.d/cosmic-ext-applet-clipboard-manager.sh"
    "--set"
    "CLIPBOARD_MANAGER_COMMIT"
    "${src.rev}"
    "--set"
    "bin-src"
    "target/${stdenv.hostPlatform.rust.cargoShortTarget}/release/cosmic-ext-applet-clipboard-manager"
  ];

  preCheck = ''
    export XDG_RUNTIME_DIR="$TMP"
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    homepage = "https://github.com/cosmic-utils/clipboard-manager";
    description = "Clipboard manager for the COSMIC Desktop Environment";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [
      # lilyinstarlight
    ];
    platforms = lib.platforms.linux;
    mainProgram = "cosmic-ext-applet-clipboard-manager";
  };
}
